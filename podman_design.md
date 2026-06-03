# Podman Software Design

## Code Dependencies

Code dependencies were evaluated statically by inspecting `import` statements across various Podman modules, encompassing both the Command Line Interface (CLI) surface and the `libpod` backend runtime engine.

### Highest Code Dependencies

Files with the highest number of imports generally serve as major initialization hubs, centralized engines, or core shared-utility aggregators. The 4 files with the most dependencies were found to be:

* `libpod/container_internal_common.go` (59 imports): It acts as the internal helper dumping ground for shared container operations. It must coordinate lock state, systemd integration, CNI/Netavark networking, container storage layers, and journald events.
* `libpod/container_internal.go` (52 imports): Coordination file managing container execution states, mount logic, and process teardown.
* `libpod/runtime.go` (38 imports): This file acts as the centralized engine facade responsible for initializing the entire daemonless lifecycle. It coordinates the abstract state backend, rootless storage, process discovery, and synchronous event forwarder channels.
* `cmd/podman/root.go` (26 imports): Serving as the process bootstrap for every Podman invocation, it initializes logging, signal handling, SSH mode, credential helpers, and storage. Its breadth of concerns makes it the single wiring point for the entire CLI layer.

### Lowest Code Dependencies

Files with minimal imports are intentionally isolated to maintain stability, enforce clean boundaries, or act as simple delegators. The 4 files with the least dependencies were found to be:

* `libpod/namesgenerator/names-generator.go` (2 imports): It acts as a pure, decoupled utility component dedicated exclusively to resource identification. It operates completely isolated from the container lifecycle, leveraging only primitive language features to combine deterministic dictionaries and resolve naming omissions without introducing system or third-party dependencies.
* `cmd/podman/completion/completion.go` (2 imports): The completion command does exactly one thing: call Cobra’s built-in `GenBashCompletion` / `GenZshCompletion` / `GenFishCompletion`. It needs only `github.com/spf13/cobra` (external) and `cmd/podman/registry` (internal, to register itself). No domain logic, no flag sets, no I/O beyond stdout. This is by design, shell completion scripts must be stable and reproducible, so the command is intentionally isolated from the rest of the engine.
* `cmd/podman/machine/stop.go` (3 imports): `stop.go` is a thin verb that delegates entirely to `shim.Stop()`; `quadlet.go` is merely the parent command definition that registers the subtree.
* `libpod/oci.go` (4 imports): Defines the `OCIRuntime` interface. To preserve a clean boundary, it only imports minimum data types (like OCI specs and resize structs).

## Knowledge Dependencies

Knowledge dependencies were extracted via commit history to identify implicit logical coupling. Knowledge dependencies were computed using `git log` to identify commits that touch two files simultaneously. Several notable inconsistencies exist where files frequently change together despite having few or zero direct code dependencies.

### `common/create_opts.go` / verb files:

`common/create_opts.go` defines the shared flag sets (e.g. `--name`, `--volume`, `--network`) reused by `containers/run.go`, `containers/create.go`, and others. These verb files do not import `create_opts.go` directly; they both import `common`, but have no direct import edge between each other. Despite this, they co-change ~12 times because every new container feature (a new flag) requires updating `create_opts.go` and the corresponding `RunE` in the verb file within the same commit. This is feature-driven logical coupling invisible to the import graph: the compiler does not enforce it, but developers know they must touch both files together.

### `options.go` / `sqlite_state.go`

There are no code dependencies between these two files as the functional options file is strictly isolated at the compiler level from the physical storage engine implementations. Yet, there is high logical coupling because any newly introduced user configuration flag or lifecycle parameter that needs to persist across reboots requires a dual modification within the same commit. Specifically, `options.go` must accept and validate the new option, while `sqlite_state.go` must simultaneously update its relational SQL tables to store it.

### `machine/init.go` / `machine/start.go`

`start.go` does not import `init.go`, yet they have a 100% co-change ratio from `init`'s perspective. `init` often introduces flags that `start` must handle, establishing tight logical coupling.

### `oci_missing.go` / `runtime_ctr.go`
There are no code dependencies between the 2 files, yet they have 5 co-changes `oci_missing.go` is essentially a tiny stub implementation of the `OCIRuntime` interface (used for dead containers where exit files need preservation). When `runtime_ctr.go` or the interface definition in `oci.go` changes (e.g., adding features or changing method signatures), developers are forced to update the stub implementation in `oci_missing.go` to keep the codebase compiling.


## Design Patterns

We choose to present here 5 patterns, each one found by a different member of the group:

### Command Pattern

* Roles: * *Command:* `cobra.Command` struct with a `RunE` handler.
* *Concrete Command:* Verb files (e.g., `completion.go`, `run.go`, `init.go`).
* *Invoker:* Cobra's `Execute()` dispatcher.
* *Receiver:* `registry.ContainerEngine()`.

This pattern solves the architectural challenge of decoupling CLI parsing from command execution. By treating commands as objects, it allows the Cobra framework to uniformly generate --help menus, shell completions, and manage hierarchical subcommands without relying on massive, unmaintainable switch-case statements. As an alternative, developers could implement a direct function dispatch table (e.g., a map[string]func). While this approach would be simpler and completely remove the dependency on a third-party framework, it ultimately loses built-in help generation, advanced flag parsing, and the ability to easily nest commands.

### Adapter Pattern

* Roles:
* *Abstraction Interface:* `OCIRuntime`.
* *Adapters:* `ConmonOCIRuntime`, `oci_missing`.

The adapter pattern is used to separate the high-level container lifecycle state from the low-level execution mechanics of OCI runtimes like crun or runc. An alternative implementation would involve hardcoding system commands directly to crun within the lifecycle methods. Although a hardcoded approach eliminates the overhead and indirection introduced by the adapter interface, it strictly violates the Open/Closed Principle and prevents the system from seamlessly plugging in alternative virtual machine runtimes, such as Kata Containers, or gracefully handling missing runtimes during state recovery.

### Factory Pattern

* Roles:
* *Factory:* `namesgenerator/names-generator.go`.
* *Client:* `runtime.go` / `options.go`.

By encapsulating the randomized, dictionary-based name generation algorithm, this pattern keeps the core runtime engine completely unaware of the underlying word dictionaries when users fail to explicitly provide a container name. If this were instead implemented via inline generation directly within the container creation routines, it would marginally reduce the project's package and directory overhead. However, this inline alternative would break the Single Responsibility Principle, reduce code reusability across other resources, and significantly hinder the independent unit testing of the naming dictionaries.

### Singleton Pattern

* Roles:
* *Singleton Instance:* Package-level `containerEngine` variables.
* *Access Point:* `registry.ContainerEngine()`.

The singleton pattern ensures that the heavy and expensive initialization of the container engine occurs exactly once, allowing that single instance to be safely shared across all verb packages during a single CLI invocation. An architectural alternative would be utilizing dependency injection via function parameters. While dependency injection successfully eliminates global state and creates highly testable, explicit code, it would require complex workarounds to thread the initialized engine through Cobra's rigid `RunE` function signatures, which do not natively support custom parameters.

#### Pattern 5: Registry (Named Shutdown Handlers)

**Roles:**
- Registry: package-level map `handlers` at `map[string]func(os.Signal) error`.
- Registration: `Register(name, handler)` at `shutdown/handler.go:124-140` - adds a named handler and prepends it to `handlerOrder` (LIFO).
- Deregistration: `Unregister(name)` at `shutdown/handler.go:143-166`.
- Invocation: `Start()` at `shutdown/handler.go:41-90` - listens for SIGINT/SIGTERM, then iterates `handlerOrder` invoking each handler by name from the map.
- Inhibit/Uninhibit: `Inhibit()` / `Uninhibit()` at `:112-119` - RWMutex that temporarily blocks signal handling during critical sections.
- Clients:
  - `runtime.go:206-213` registers the store-close handler.
  - `container_internal.go` / `container_copy_common.go` call
    `Inhibit()`/`Uninhibit()` during file copies.
  - `healthcheck.go` calls `Inhibit()` during health execs.
  - `cmd/podman/root.go:151` calls `shutdown.Stop()`.

The Registry pattern solves the problem of multiple independent subsystems—such as storage, containers, and health timers, requiring ordered cleanup upon process termination without needing to be directly aware of one another. Because Go's `signal.Notify` overrides previous handlers, a central registry guarantees that all registered cleanups execute reliably in a defined Last-In-First-Out (LIFO) order. Alternatively, the system could rely on a single, hardcoded shutdown function that explicitly calls all cleanup steps in a row. While this would offer explicit visual ordering, eliminate map lookup overhead, and simplify the code structure, it introduces severe architectural drawbacks. It creates tight coupling by forcing every new subsystem to modify the central function, introduces circular import risks, prevents dynamic addition or removal of handlers during operations like container copying, and makes isolated testing extremely difficult since the entire subsystem state must be constructed at once.
