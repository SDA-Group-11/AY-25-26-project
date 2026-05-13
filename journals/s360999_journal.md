# s360999 Journal
# Week 0 (2026-04-17 → 2026-04-23)
## 1. Activities
During the preparatory week, I focused on the operational setup required before any technical analysis of Podman could begin. I drafted the project plan, allocating the available time across the four C4 levels and a final wrap-up phase: one week for the context level, two weeks for the container level, one week for the component level, one week for design patterns and dependencies, and one week of safety buffer. I defined concrete per-sprint tasks consistent with the team size (5 members) so that work could proceed in parallel. On the tooling side, I set up the team's Notion workspace and designed the underlying database used to track sprints, tasks, ownership, and progress throughout the project.
## 2. Effort
- Project planning and sprint allocation: ~1.5 hours
- Notion workspace setup: ~1 hour
- Database schema and task structure: ~1 hour
- Documenting the plan and assigning initial tasks: ~0.5 hours

**Total:** ~4 hours
## 3. Contribution to Report / Project
My contribution this week was infrastructural rather than technical. I established the planning framework and the Notion environment that the team would use throughout the project to coordinate work, distribute tasks across sprints, and record progress in a single shared source of truth.

# Week 1 (2026-04-24 → 2026-05-01)
## 1. Activities
During the first week, I focused on building a working understanding of Podman's context. I studied the official Podman documentation and complemented it with material on Docker, since several of Podman's architectural choices (daemonless design, fork-exec runtime model, first-class rootless support) are most clearly understood as deliberate departures from Docker's client-server model. I identified the four main external interfaces of the system (CLI, REST API exposed by `podman system service`, remote client over SSH, and the official language bindings) and the main external entities Podman interacts with (OCI registries, Kubernetes clusters, Docker-compatible tooling, CI/CD systems, and the hypervisor stack on non-Linux hosts via `podman machine`). On this basis, I produced an independent draft of the C4 Level 1 context diagram for later comparison and consolidation with the rest of the team.
## 2. Effort
- Reading Podman official documentation: ~2 hours
- Studying Docker fundamentals and contrasting it with Podman: ~1 hour
- Mapping interfaces, personas, and external systems: ~0.5 hours
- Drafting the C4 Level 1 context diagram: ~1 hour

**Total:** ~4.5 hours
## 3. Contribution to Report / Project
My contribution focused on building a shared understanding of Podman's external context. I produced an independent draft of the first level of the C4 model, which fed into the team's consolidation discussion at the start of the following week.

# Week 2 (2026-05-02 → 2026-05-08)
## 1. Activities
During the second week, the team agreed on the final draft of the C4 Level 1 diagram and moved on to the container-level analysis. I studied Podman's internal structure at the container level, mapping the main runtime processes and the external binaries Podman invokes during normal operation (`conmon`, OCI runtimes such as `crun` and `runc`, `netavark`, `aardvark-dns`, and `gvproxy` on non-Linux hosts). The most significant analytical question that emerged was a system-boundary issue: where to draw the line between *Podman* (the forked `containers/podman` repository) and *Podman's ecosystem* (sister projects under the `containers` GitHub organization, in particular Buildah and Skopeo, together with the supporting binaries listed above). The distinction is non-trivial because Podman statically links Go libraries from Buildah and shares the `containers/image` and `containers/storage` libraries with Skopeo, so the same dependencies appear as "internal code" or "external systems" depending on the chosen scope. To make the trade-off explicit rather than commit to a scope implicitly, I drafted two versions of the C4 Level 2 container diagram: one corresponding to the narrow scope (Podman repository only, with sister projects and supporting binaries shown as external) and one corresponding to the broad scope (the ecosystem treated as part of the system under analysis).
## 2. Effort
- Team meeting on C4 Level 1 finalization and Level 2 planning: ~1.5 hours
- Studying Podman's container-level structure: ~2 hours
- Drafting the two C4 Level 2 container diagrams: ~1.5 hours

**Total:** ~5 hours
## 3. Contribution to Report / Project
My contribution this week was the container-level architectural analysis and, in particular, the explicit framing of the "Podman vs Podman's ecosystem" boundary question, supported by two alternative container diagrams that let the team evaluate the trade-off on its merits before committing to a scope for the rest of the analysis.