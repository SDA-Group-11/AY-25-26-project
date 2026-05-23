# Podman's Overview

## Purpose and Stakeholders

Podman (the Pod Manager) is an open-source, daemonless and Linux-native tool designed to manage and run Open Container Initiative (OCI) containers. Its primary purpose is to provide a more lightweight and secure alternative to traditional container engines, such as Docker, by removing the central daemon requirement and supporting "rootless" mode.

Based on the C4 context level diagram, the system serves several key stakeholers:

- **System Administrators:** Rely on Podman to manage containerized services;
- **DevOps Engineers:** Utilize Podman within CI/CD pipelines (e.g., GitHub Actions, Cirrus CLI) to build and test images in containerized environments;
- **Software Architects:** Design containerized architectures;
- **Software Systems:** Podman interacts directly with the Operating System via syscalls and integrates with external tools like Kubernetes for orchestration and VS Code for local development.

![c4-context-level](charts/media/c4_context.png)

## System Description

Podman is part of a modular suite of tools (including Buildah and Skopeo) that follow the philosophy of "doing one thing and doing it well." Unlike engines that require a background process (a "daemon") to manage containers, Podman launches containers as child processes of its own. This architecture allows for:

1.  **Daemonless execution:** No single point of failure or "fat" process managing the lifecycle.
2.  **Rootless operation:** Users can run containers without administrative privileges, significantly reducing attack surface.
3.  **Kubernetes compatibility:** It can generate Kubernetes YAML from running containers and vice versa, bridging the gap between local development and production orchestration.

## Basic Code Statistics

In this project we will analyze the status of the repo as of 2026/04/16. The following statistics provide a snapshot of the project's scale as of early 2026:

| Metric             | Value      |
| :----------------- | :--------- |
| LOCs               | ~2.000.000 |
| Primary Language   | Go (95%)   |
| Repository Files   | 9054       |
| Modules/Packages   | TODO       |
| Total Contributors | 853        |

As a mature project under the **Containers** organization on GitHub Podman is a rapidly evolving repository. The main branch sees commits ~10 times/day, of which 3+ are pull requests.

## Tools used for analysis

Antigravity+gemini models
NotebookLM for architectural consultations
goplantuml
PlantUML
Structurizr
