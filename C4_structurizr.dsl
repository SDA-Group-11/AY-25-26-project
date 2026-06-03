workspace "Podman" "C4 diagrams (Levels 1-3) for Podman, a daemonless OCI container engine." {

    !identifiers hierarchical

    model {

        # ── People / Actors ──────────────────────────────────────────────
        developer = person "Developer / User" "Builds, runs, and manages containers locally or via REST API."
        devops    = person "DevOps Engineer" "Designs and maintains containerised infrastructure, pipelines, and deployment workflows."

        # ── System in scope ───────────────────────────────────────────────
        podman = softwareSystem "Podman" "Daemonless OCI container engine. Manages container lifecycle, images, pods, volumes, and networking without a background daemon." {
            tags "Podman"

            # ── L2: Container "Podman CLI" with L3 components ────────────
            cli = container "Podman CLI" "Frontend command-line interface. Parses commands via Cobra." "Go binary" {
                tags "Internal"

                entry = component "Process Entry & Root Command (CLI-C1)" "The entry point of the CLI process. It is used to initialise the application and assemble the root command from which all subcommands are reached." "Go package: cmd/podman" {
                    tags "CliComponent" "CliInfra"
                }

                registryComp = component "Command Registry & Engine Binding (CLI-C2)" "A registry that holds all available commands. It is used to bind commands to the appropriate container or image engine depending on the execution mode." "Go package: cmd/podman/registry" {
                    tags "CliComponent" "CliInfra"
                }

                verbs = component "Per-Resource Verb Packages (CLI-C3)" "A collection of subcommands grouped by resource type. It is used to expose operations on containers, pods, images, volumes, networks, and other resources to the user." "Go packages: cmd/podman/{containers,pods,images,…}" {
                    tags "CliComponent" "CliVerbs"
                }

                helpers = component "Shared CLI Helpers (CLI-C4)" "A set of shared utilities for the CLI. It is used to provide common flag definitions, argument validation, and output formatting across all subcommands." "Go packages: cmd/podman/{common,validate,parse,utils,inspect,diff}" {
                    tags "CliComponent" "CliInfra"
                }

                serviceEntry = component "REST API Service Entry (CLI-C5)" "The subcommand responsible for starting the REST API server. It is used to initialise and hand off control to the HTTP server when the user runs the service command." "Go package: cmd/podman/system" {
                    tags "CliComponent" "CliInfra"
                }

                machineCmd = component "Machine VM Management (CLI-C6)" "A subcommand group for managing virtual machines. It is used to create, start, stop, and interact with VMs that host Podman on non-Linux operating systems." "Go package: cmd/podman/machine" {
                    tags "CliComponent" "CliVerbs"
                }

                quadletCmd = component "Quadlet Command Surface (CLI-C7)" "A subcommand group for managing Quadlet unit files. It is used to install, list, print, and remove systemd unit files generated from container definitions." "Go package: cmd/podman/quadlet" {
                    tags "CliComponent" "CliVerbs"
                }

                completionCmd = component "Completion Command (CLI-C8)" "A subcommand for generating shell completion scripts. It is used to emit completion definitions for supported shells so users can enable tab-completion for Podman commands." "Go package: cmd/podman/completion" {
                    tags "CliComponent" "CliInfra"
                }
            }

            # ── L2: Container "Podman REST API Service" ──────────────────
            api = container "Podman REST API Service" "HTTP server exposing Docker-compatible and Podman APIs." "Go binary, HTTP/JSON" {
                tags "Internal"
            }

            # ── L2: Container "libpod" with L3 components ────────────────
            libpod = container "libpod (Engine)" "Core container engine logic. Manages Runtime and all container/pod/volume lifecycle, OCI invocation, state persistence, locking, events, healthchecks and logging" "Go library" {
                tags "Internal"

                runtime = component "Runtime (LP-C1)" "The central component of the engine. It is used to initialise and coordinate all other engine subsystems, and serves as the main entry point for container, pod, and volume operations." "Go: libpod (runtime.go and siblings)" {
                    tags "LibpodComponent" "LibpodCore"
                }

                containerComp = component "Container (LP-C2)" "The component representing a single container. It is used to manage the full lifecycle of a container, including creation, execution, inspection, and removal." "Go: libpod (~25 files)" {
                    tags "LibpodComponent" "LibpodDomain"
                }

                podComp = component "Pod (LP-C3)" "The component representing a pod. It is used to group and manage a set of containers that share namespaces and are operated together as a unit." "Go: libpod (pod.go and siblings)" {
                    tags "LibpodComponent" "LibpodDomain"
                }

                volumeComp = component "Volume (LP-C4)" "The component representing a volume. It is used to manage persistent storage that can be attached to containers." "Go: libpod (volume.go and siblings)" {
                    tags "LibpodComponent" "LibpodDomain"
                }

                stateComp = component "State Persistence (LP-C5)" "The component responsible for persisting engine state. It is used to store and retrieve metadata about containers, pods, volumes, and exec sessions across process invocations." "Go: libpod (state.go, sqlite_state.go)" {
                    tags "LibpodComponent" "LibpodInfra"
                }

                ociRuntimeComp = component "OCI Runtime Adapter (LP-C6)" "The component that abstracts the OCI runtime. It is used to delegate low-level container execution operations such as creation, start, kill, and attach to an external OCI-compliant runtime." "Go: libpod (oci*.go)" {
                    tags "LibpodComponent" "LibpodExecution"
                }

                networkingComp = component "Networking (LP-C7)" "The component responsible for container networking. It is used to configure and manage network interfaces, port bindings, and connectivity for containers and pods." "Go: libpod (networking_*.go)" {
                    tags "LibpodComponent" "LibpodExecution"
                }

                healthcheckComp = component "Healthcheck (LP-C8)" "The component responsible for container health monitoring. It is used to periodically execute health probes against running containers and report their status." "Go: libpod (healthcheck*.go)" {
                    tags "LibpodComponent" "LibpodExecution"
                }

                eventsComp = component "Events (LP-C9)" "The component responsible for lifecycle event reporting. It is used to publish events when containers, pods, and volumes change state, allowing external consumers to observe engine activity." "Go: libpod/events" {
                    tags "LibpodComponent" "LibpodInfra"
                }

                lockComp = component "Locking (LP-C10)" "The component responsible for concurrency control. It is used to coordinate access to shared resources across multiple processes operating on the same engine state." "Go: libpod/lock" {
                    tags "LibpodComponent" "LibpodInfra"
                }

                logsComp = component "Logs (LP-C11)" "The component responsible for container log access. It is used to read and stream log output produced by running or stopped containers." "Go: libpod/logs" {
                    tags "LibpodComponent" "LibpodExecution"
                }

                defineComp = component "Define — Shared Types (LP-C12)" "A package of shared type definitions. It is used to provide common enumerations, error variables, and data structures referenced across the engine and the CLI." "Go: libpod/define" {
                    tags "LibpodComponent" "LibpodInfra"
                }

                volumePluginComp = component "Volume Plugin Client (LP-C13)" "The component responsible for third-party volume driver integration. It is used to communicate with external volume plugins so that containers can use storage managed by those drivers." "Go: libpod/plugin" {
                    tags "LibpodComponent" "LibpodInfra"
                }

                shutdownComp = component "Process Shutdown (LP-C14)" "The component responsible for graceful process termination. It is used to register and invoke cleanup handlers when the process receives a shutdown signal." "Go: libpod/shutdown" {
                    tags "LibpodComponent" "LibpodInfra"
                }

                namesComp = component "Names Generator (LP-C17)" "The component responsible for automatic name assignment. It is used to generate a random human-readable name for containers and pods that are created without an explicit name." "Go: libpod/namesgenerator" {
                    tags "LibpodComponent" "LibpodInfra"
                }

                infoComp = component "System Info (LP-C20)" "The component responsible for system introspection. It is used to collect and expose information about the host environment, storage configuration, and runtime versions." "Go: libpod (info*.go) + libpod/linkmode" {
                    tags "LibpodComponent" "LibpodInfra"
                }

                kubeComp = component "Kube & Service Containers (LP-C21)" "The component responsible for Kubernetes interoperability. It is used to generate Kubernetes YAML from running pods and to create containers and pods from Kubernetes manifest files." "Go: libpod (kube.go, service.go)" {
                    tags "LibpodComponent" "LibpodDomain"
                }
            }

            # ── L2: Container "State Database" ───────────────────────────
            state = container "State Database" "Local SQLite database persisting metadata about containers, pods, volumes, exec sessions and runtime." "SQLite" {
                tags "Database"
            }
        }

        # ── External software systems ─────────────────────────────────────

        cicd = softwareSystem "CI/CD System" "Automated pipeline platform (GitHub Actions, Jenkins, GitLab CI, …) that triggers container build, test, and deploy workflows." {
            tags "External"
        }

        registry = softwareSystem "Container Registry" "Stores and distributes OCI container images. Examples: Docker Hub, quay.io." {
            tags "External"
        }

        localStorage = softwareSystem "Local Storage" "Host filesystem persisting image layers, container root filesystems, and volume data. Accessed via the containers/storage library (linked into libpod) using overlayfs for copy-on-write." {
            tags "External"
        }

        networkBackend = softwareSystem "Container Network Backend" "External network binaries spawned at runtime. Netavark + aardvark-dns for rootful; pasta for rootless (slirp4netns legacy)." {
            tags "External"
        }

        conmon = softwareSystem "conmon" "Per-container OCI monitor process (separate C binary). Supervises the OCI runtime, captures logs, relays exit codes, keeps the container alive after the CLI exits." {
            tags "External"
        }

        ociRuntime = softwareSystem "OCI Runtime" "Reads the OCI Runtime Spec bundle and calls Linux kernel features to spawn the container process. Default: crun; legacy: runc." {
            tags "External"
        }

        systemd = softwareSystem "systemd" "Host init system. Integration: socket activation (podman.socket), sd-notify (mode-dependent), journald event backend, healthcheck/auto-update timers, Quadlet-generated units." {
            tags "External"
        }

        desktop = softwareSystem "Podman Desktop" "Cross-platform GUI frontend (separate project). Communicates with the Podman REST API." {
            tags "External"
        }

        # ── Relationships ─────────────────────────────────────────────────

        # ── People → CLI components / Desktop / CI/CD ────────────────────
        developer -> podman.cli.entry "Runs container commands" "CLI flags"
        devops    -> podman.cli.entry "Operates and scripts container workflows" "CLI flags"
        devops    -> cicd             "Configures and triggers pipelines"
        cicd      -> podman.cli.entry "Executes automated container workflows" "CLI flags / scripts"
        developer -> desktop          "Uses GUI to manage containers"
        devops    -> desktop          "Uses GUI to manage containers"

        # ── Desktop → REST API ───────────────────────────────────────────
        desktop -> podman.api "Manages containers, images, pods, volumes" "REST API (HTTP/JSON over Unix socket)"

        # ── systemd → REST API (socket activation) ───────────────────────
        systemd -> podman.api "Activates the API service on demand" "socket activation (podman.socket)"

        # ── CLI internal wiring ──────────────────────────────────────────
        podman.cli.entry          -> podman.cli.registryComp     "Builds Cobra root; engines lazily constructed in PreRun" "Go API"
        podman.cli.entry          -> podman.cli.verbs            "Attaches subcommands via registry.Commands slice" "Go init() registration"
        podman.cli.entry          -> podman.cli.helpers          "Uses validators, parse, utils" "Go API"
        podman.cli.verbs          -> podman.cli.registryComp     "Obtains ContainerEngine() / ImageEngine() handles" "Go API"
        podman.cli.verbs          -> podman.cli.helpers          "Uses shared flag sets, autocomplete, inspect, diff" "Go API"
        podman.cli.serviceEntry   -> podman.cli.registryComp     "Registered as 'system service' subcommand" "Go init()"
        podman.cli.machineCmd     -> podman.cli.registryComp     "Registered as 'machine' subcommand subtree" "Go init()"
        podman.cli.quadletCmd     -> podman.cli.registryComp     "Registered as 'quadlet' subcommand subtree" "Go init()"
        podman.cli.completionCmd  -> podman.cli.registryComp     "Registered as 'completion' subcommand" "Go init()"

        # ── CLI components → libpod components (cross-container) ─────────
        podman.cli.verbs        -> podman.libpod.runtime  "Delegates lifecycle operations via ABI bridge" "Go API (pkg/domain/infra/abi)"
        podman.cli.serviceEntry -> podman.libpod.runtime  "Constructs *libpod.Runtime and hands it to pkg/api/server" "Go API (direct, in-process)"
        podman.cli.entry        -> podman.libpod.defineComp   "Imports error vars and constants" "Go import"
        podman.cli.verbs        -> podman.libpod.defineComp   "Imports error vars and constants" "Go import"
        podman.cli.entry        -> podman.libpod.shutdownComp "Registers shutdown handlers; calls Stop()" "Go API"
        podman.cli.machineCmd   -> podman.libpod.eventsComp   "Imports event type constants" "Go import"

        # ── REST API → libpod ────────────────────────────────────────────
        podman.api -> podman.libpod.runtime "Delegates lifecycle operations" "Go API (in-process, pkg/api/handlers)"

        # ── libpod internal wiring: Runtime as composition root ──────────
        podman.libpod.runtime -> podman.libpod.containerComp   "Creates and looks up containers" "Go API"
        podman.libpod.runtime -> podman.libpod.podComp         "Creates and looks up pods" "Go API"
        podman.libpod.runtime -> podman.libpod.volumeComp      "Creates and looks up volumes" "Go API"
        podman.libpod.runtime -> podman.libpod.stateComp       "Reads/writes persistent state" "Go API (State interface)"
        podman.libpod.runtime -> podman.libpod.ociRuntimeComp  "Holds default and per-runtime OCIRuntime instances" "Go API (OCIRuntime interface)"
        podman.libpod.runtime -> podman.libpod.lockComp        "Allocates per-object locks" "Go API (lock.Manager)"
        podman.libpod.runtime -> podman.libpod.eventsComp      "Writes lifecycle events" "Go API (events.Eventer)"
        podman.libpod.runtime -> podman.libpod.shutdownComp    "Registers store-close handler" "Go API"
        podman.libpod.runtime -> podman.libpod.healthcheckComp "Entry point Runtime.HealthCheck — delegates to Container" "Go API"
        podman.libpod.runtime -> podman.libpod.networkingComp  "Sets up pod-level network namespaces" "Go API"
        podman.libpod.runtime -> podman.libpod.namesComp       "Generates names for unnamed containers/pods" "Go API"
        podman.libpod.runtime -> podman.libpod.infoComp        "Builds 'podman info' report" "Go API"
        podman.libpod.runtime -> podman.libpod.kubeComp        "Backs 'kube generate' and 'kube play' operations" "Go API"
        podman.libpod.runtime -> podman.libpod.volumePluginComp "Loads third-party volume drivers when configured" "Go API"
        podman.libpod.runtime -> podman.libpod.defineComp      "Uses shared types and error vars" "Go import"

        # ── libpod internal wiring: domain objects → services ────────────
        podman.libpod.containerComp -> podman.libpod.stateComp        "Persists container state transitions" "Go API"
        podman.libpod.containerComp -> podman.libpod.lockComp         "Locks before state access" "Go API"
        podman.libpod.containerComp -> podman.libpod.eventsComp       "Publishes lifecycle events" "Go API"
        podman.libpod.containerComp -> podman.libpod.ociRuntimeComp   "Delegates create/start/kill/exec/attach" "Go API"
        podman.libpod.containerComp -> podman.libpod.networkingComp   "Requests network setup/teardown" "Go API"
        podman.libpod.containerComp -> podman.libpod.logsComp         "Reads container log files" "Go API"
        podman.libpod.containerComp -> podman.libpod.healthcheckComp  "Executes scheduled health probes" "Go API"
        podman.libpod.containerComp -> podman.libpod.defineComp       "Uses shared types and error vars" "Go import"

        podman.libpod.podComp -> podman.libpod.containerComp "Coordinates member containers via infra container" "Go API"
        podman.libpod.podComp -> podman.libpod.stateComp     "Persists pod state" "Go API"
        podman.libpod.podComp -> podman.libpod.lockComp      "Locks before state access" "Go API"
        podman.libpod.podComp -> podman.libpod.eventsComp    "Publishes lifecycle events" "Go API"

        podman.libpod.volumeComp -> podman.libpod.stateComp        "Persists volume metadata" "Go API"
        podman.libpod.volumeComp -> podman.libpod.volumePluginComp "Delegates to plugin driver when configured" "Go API"

        podman.libpod.kubeComp -> podman.libpod.podComp       "Creates pods from YAML manifests" "Go API"
        podman.libpod.kubeComp -> podman.libpod.containerComp "Creates service containers wrapping pod lifecycles" "Go API"

        # ── libpod components → State Database container ────────────────
        podman.libpod.stateComp -> podman.state "Reads and writes persisted state" "SQL (modernc.org/sqlite, CGO-free)"

        # ── libpod components → external systems ─────────────────────────
        podman.libpod.runtime         -> registry       "Pulls and pushes OCI images" "HTTPS / OCI Distribution Spec (containers/image)"
        podman.libpod.runtime         -> localStorage   "Reads/writes image layers, container filesystems, volume data" "filesystem (containers/storage)"
        podman.libpod.containerComp   -> localStorage   "Mounts container rootfs" "filesystem (containers/storage)"
        podman.libpod.networkingComp  -> networkBackend "Spawns network binaries to configure container networking" "subprocess + JSON stdio (libnetwork)"
        podman.libpod.ociRuntimeComp  -> conmon         "Spawns one monitor process per container" "double fork/exec + named pipes"
        podman.libpod.healthcheckComp -> systemd        "Schedules healthcheck timers" "D-Bus"
        podman.libpod.eventsComp      -> systemd        "Writes lifecycle events via journald backend" "journald"
        podman.libpod.containerComp   -> systemd        "Sends sd-notify in healthy/proxy modes" "sd-notify (notifyproxy)"

        # ── Chained external delegation (carried into all views) ─────────
        conmon -> ociRuntime "Launches runtime with OCI bundle" "fork/exec + config.json (OCI Runtime Spec)"
    }

    views {

        # ── Level 1: System Context ───────────────────────────────────────
        systemContext podman "L1_SystemContext" "Level 1 — System Context diagram for Podman." {
            include *
            autoLayout lr
        }

        # ── Level 2: Containers ───────────────────────────────────────────
        container podman "L2_Containers" "Level 2 — Container diagram for Podman." {
            include *
            autoLayout lr
        }

        # ── Level 3a: Components of the CLI container ─────────────────────
        component podman.cli "L3_Components_CLI" "Level 3 — Components inside the Podman CLI." {
            include *
            autoLayout lr
        }

        # ── Level 3b: Components of the libpod container ──────────────────
        component podman.libpod "L3_Components_Libpod" "Level 3 — Components inside libpod (engine)." {
            include *
            autoLayout lr
        }

        styles {
            element "Element" {
                shape RoundedBox
                background #e6f1fb
                color #0c447c
                stroke #378add
                strokeWidth 3
                fontSize 14
            }

            element "Person" {
                shape Person
                background #1d9e75
                color #ffffff
                stroke #0f6e56
                strokeWidth 3
            }

            element "Podman" {
                background #378add
                color #ffffff
                stroke #0c447c
                strokeWidth 4
            }

            element "Internal" {
                background #378add
                color #ffffff
                stroke #0c447c
                strokeWidth 3
            }

            element "Database" {
                shape Cylinder
                background #378add
                color #ffffff
                stroke #0c447c
                strokeWidth 3
            }

            element "External" {
                background #f1efe8
                color #2c2c2a
                stroke #888780
                strokeWidth 2
            }

            element "CliComponent" {
                background #5dade2
                color #ffffff
                stroke #0c447c
            }

            element "CliInfra" {
                background #2874a6
                color #ffffff
                stroke #0c447c
            }

            element "CliVerbs" {
                background #5dade2
                color #ffffff
                stroke #0c447c
            }

            element "LibpodComponent" {
                background #5dade2
                color #ffffff
                stroke #0c447c
            }

            element "LibpodCore" {
                background #154360
                color #ffffff
                stroke #0c447c
            }

            element "LibpodDomain" {
                background #1a5276
                color #ffffff
                stroke #0c447c
            }

            element "LibpodInfra" {
                background #148f77
                color #ffffff
                stroke #0e6655
            }

            element "LibpodExecution" {
                background #7d3c98
                color #ffffff
                stroke #5b2c6f
            }

            element "Boundary" {
                strokeWidth 4
            }

            relationship "Relationship" {
                thickness 2
                color #5f5e5a
                style dashed
            }
        }
    }

    configuration {
        scope softwaresystem
    }
}
