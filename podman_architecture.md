# Podman’s Architecture

## Context Level

### Context diagram
![Context diagram](images/Context_diagram.png)

### System Boundary

The core principle of this diagram lies in the sharp separation between Podman's core engine and its supporting ecosystem. Specifically, the **System Boundary** has been defined according to this strict criterion:

- **System (inside it):** includes exclusively the source code hosted and compiled within the `containers/podman` repository (the CLI, the REST API service, and the *Libpod* library that contains the core business logic).
- **External Ecosystem (outside the System):** includes all runtimes (used to create and manage the containers), network backends, and several software utilities provided by external or third-party repositories. Therefore, even though they are indispensable for execution, they remain external entities that communicate with Podman through logical interfaces or commands.

This clear separation highlights Podman's **daemonless** architecture. Unlike Docker, Podman does not maintain a centralized, always-on background process: instead, it acts as an ephemeral orchestrator that activates upon user command, delegates the ongoing execution and monitoring to specialized utilities (such as `conmon`), and then terminates its own execution.

### Actors' Interactions

Interaction with Podman does not occur through a persistent daemon, but rather through direct invocations of its binary:

- **Developer / User:** sends commands to manage containers via the **local CLI** or makes calls to services and graphical interfaces (such as Podman Desktop) through the **native REST API**.
- **DevOps / CI/CD System:** engineers configure automated pipelines that directly invoke the Podman binary to start test, build, and deployment workflows.

### Ecosystem Interaction

When a command is issued, Podman activates and coordinates the various external components of the ecosystem:

- **Image management and Registries:** for building (`podman build`), the system interfaces with external **Buildah** APIs and shared *containers/image* libraries. It then communicates with external **Container Registries** (e.g., docker.io and quay.io registries) to *pull* and *push* OCI images. Podman also has the native capability to generate manifests for **Kubernetes** clusters.
- **Container Lifecycle (conmon and OCI Runtime):** upon starting a container, Podman performs a double fork and instantiates an external monitoring process called `conmon`. It is then `conmon` itself that launches the OCI Runtime (`crun` / `runc`), passing it the configuration package (OCI bundle). Once the container has started, Podman shuts down, while `conmon` remains active in the background to monitor the process and communicate its status to `systemd` (which acts as the native supervisor of the Linux Host by managing the automatic startup and restart of containers through persistence, cgroups, and system logging).
- **Networking and Security (Network Stack):** Podman doesn't directly manage networking. It delegates the creation of bridges and firewall rules to **Netavark**. In *rootless* mode (without root privileges), it leverages external tools like **pasta** to forward traffic securely.
- **Linux Host System:** the OCI Runtime translates the received commands into direct calls to native Linux kernel primitives (such as *Namespaces, Cgroups*, and *Seccomp*) to physically isolate the processes on the host system.



## Container Level
