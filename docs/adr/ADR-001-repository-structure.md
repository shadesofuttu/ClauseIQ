# ADR-001: Repository Structure

**Status:** Accepted  
**Date:** 2024-07-24  
**Deciders:** Engineering Team

---

## Context

ClauseIQ is a production AI SaaS platform that will eventually include:
- FastAPI backend
- Frontend application (Next.js)
- Infrastructure as Code
- Documentation
- CI/CD pipelines

We need to decide on the repository structure before any implementation begins.

## Decision

We will use a **monorepo** with clear top-level separation:

```
CLAUSEIQ/
├── backend/
├── frontend/
├── docs/
├── infra/
├── scripts/
├── .github/
└── .vscode/
```

## Rationale

### Why Monorepo?

1. **Atomic commits:** Changes across backend, frontend, and infra can be committed together
2. **Shared tooling:** CI/CD, pre-commit hooks, and linters configured once
3. **Simpler onboarding:** One repository to clone
4. **Can be split later:** If we outgrow the monorepo, we can extract services

### Why This Structure?

- **backend/** — Contains the entire FastAPI application, isolated
- **frontend/** — Future frontend application, isolated
- **docs/** — Architecture, ADRs, API docs, roadmaps
- **infra/** — Docker, nginx, Terraform, K8s configs
- **scripts/** — Utility scripts for development
- **.github/** — CI/CD workflows
- **.vscode/** — Shared editor configuration

Each top-level directory is self-contained and has a clear purpose.

## Consequences

### Positive
- Single source of truth
- Easier refactoring across layers
- Simplified dependency management
- Better code review (see full context)

### Negative
- Larger repository size
- Potential for tighter coupling if boundaries are not respected
- Requires discipline to avoid mixing concerns

### Mitigation
- Strict folder responsibilities documented in ARCHITECTURE.md
- Code review enforcement of boundaries
- Linting rules to prevent cross-boundary imports

## Alternatives Considered

### Polyrepo (separate repos for backend, frontend, infra)

**Rejected because:**
- Adds overhead for a small team
- Makes atomic changes harder
- Complicates shared tooling
- Can revisit when team grows beyond 10 engineers

---

**Last Updated:** Sprint 0
