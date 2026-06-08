# Podman Overview

## Purpose and Stakeholders

### Purpose

Podman (POD MANager) is an open-source tool for managing OCI-compliant containers, pods, images, and volumes. Its primary goal is to provide a daemonless, rootless container engine that offers a Docker-compatible CLI while eliminating the security risks associated with a privileged central daemon. Podman enables developers and operations teams to build, run, and manage containerized applications across Linux, macOS, and Windows.

### Main Stakeholders

| Stakeholder | Role |
| --- | --- |
| DevOps Engineers | Primary users who build, deploy, and orchestrate containers in CI/CD pipelines |
| System Administrators | Manage multi-user environments where rootless containers improve security isolation |
| Software Developers | Use containers for local development and testing, especially Kubernetes-targeted workloads |
| Security Teams | Benefit from the daemonless architecture and rootless execution model |
| Open-Source Contributors | ~951 developers who maintain and extend the codebase |
| Red Hat / IBM | Primary corporate sponsor and maintainer |
| Enterprise Organizations | Adopt Podman for production workloads requiring enhanced security compliance |


## System Description and Code Statistics

### System Description

Podman is written primarily in Go and follows a modular library-based architecture. At its core lies `libpod`, a library that manages the full container lifecycle (creation, execution, checkpointing, and removal). Unlike Docker, Podman has no central daemon process - each container runs as a direct child process of the invoking user, monitored by a lightweight `conmon` process.

The system integrates with several companion projects:

- Buildah - image building
- Netavark / Aardvark - container networking
- containers/storage - image and container storage
- containers/image - image transport and verification
- crun / runc - OCI runtime execution

Podman natively supports pods (groups of containers sharing a network namespace), mirroring Kubernetes pod semantics and enabling local development that closely matches production cluster behavior.

### Code Statistics (cutoff 24th May 2026)

| Metric | Value |
| --- | --- |
| Programming Language | Go (primary) |
| Total Source Files (excl. vendor) | 2,946 |
| Go Source Files (excl. vendor) | 1,441 |
| Lines of Go Code (excl. vendor) | ~242,800 |
| Directories/Packages (excl. vendor) | 331 |
| Total Commits | 27,310 |
| Unique Contributors | ~951 |
| Current Version | v5.8.2 |
| License | Apache 2.0 |
| Repository | github.com/containers/podman |

As a mature project under the Containers organization on GitHub Podman is a rapidly evolving repository. The main branch sees commits ~10 times/day, of which 3+ are pull requests being accepted.

### Key Modules

| Module | Responsibility |
| --- | --- |
| `cmd/podman/` | CLI entry point and Cobra command definitions |
| `libpod/` | Core runtime: container, pod, and volume lifecycle management |
| `pkg/api/` | HTTP REST API server (Docker-compatible + Podman-native) |
| `pkg/bindings/` | REST API client library |
| `pkg/domain/` | Glue layer between CLI and core operations |
| `pkg/machine/` | Virtual machine management for macOS/Windows |
| `pkg/domain/infra/abi/` | Local execution backend |
| `pkg/domain/infra/tunnel/` | Remote execution backend (podman-remote) |

---

### Quick Benchmark: Podman vs Docker

| Aspect | Podman | Docker |
| --- | --- | --- |
| Architecture | Daemonless (fork-exec) | Client-server (dockerd daemon) |
| Root Privileges | Rootless by default | Requires root or docker group membership |
| Idle Resource Usage | Near zero (no background process) | Daemon consumes memory continuously |
| Single Point of Failure | None - containers survive CLI exit | Daemon crash stops all containers |
| Pod Support | Native (Kubernetes-style pods) | Not supported natively |
| Build System | Delegates to Buildah | Integrated BuildKit |
| Compose Support | podman-compose / Docker Compose v2 | Docker Compose (native) |
| Kubernetes Integration | `podman generate kube` / `podman kube play` | Requires additional tooling |
| Security Model | User namespaces + SELinux + no daemon | Daemon runs as root by default |
| Ecosystem Maturity | Growing (23% enterprise market share) | Dominant (larger community, more tooling) |

In terms of raw container execution performance, both tools are comparable since they use the same OCI runtimes (crun/runc). The key differentiator is architectural: Podman's daemonless model provides better security isolation and resource efficiency at idle, while Docker's daemon model offers a more centralized management experience with broader third-party ecosystem support.

## Tools used for analysis

All three documents inside this repository have been written with the help of the following tools:

- Notion: task and people management
- Antigravity: source code analysis
- Claude code: source code analysis
- Gemini: support for analysis and report preparation
- NotebookLM: slides and document consultation