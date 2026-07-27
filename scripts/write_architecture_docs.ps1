# ARCHITECTURE.md
$architecture = @'
# ClauseIQ — Architecture Documentation

**Status:** Sprint 0 — Repository Foundation  
**Last Updated:** 2025-01-XX  
**Maintainer:** Engineering Team

---

## Table of Contents

1. [Overview](#overview)
2. [Architectural Decisions](#architectural-decisions)
3. [Repository Structure](#repository-structure)
4. [Backend Architecture](#backend-architecture)
5. [Domain Plugin System](#domain-plugin-system)
6. [Configuration Strategy](#configuration-strategy)
7. [Testing Strategy](#testing-strategy)
8. [Storage Design](#storage-design)
9. [Future Considerations](#future-considerations)
10. [ADR Index](#adr-index)

---

## Overview

### What is ClauseIQ?

ClauseIQ is a production-grade AI-powered Document Intelligence platform designed to analyze domain-specific documents (initially legal contracts) with extensibility to support multiple domains:

- Legal
- HR
- Finance
- Insurance
- Compliance
- Privacy Policies
- Procurement
- Employment Agreements

### Design Philosophy

ClauseIQ is architected with the following principles:

1. **Production-first:** Every decision assumes the platform will serve real paying customers.
2. **Domain-adaptive:** Adding a new domain should not require restructuring the repository.
3. **Separation of concerns:** Every layer has one responsibility. No mixing.
4. **Explicit boundaries:** Clear interfaces between layers prevent coupling.
5. **Simplicity over cleverness:** The architecture should be immediately understandable to any senior engineer.

---

## Architectural Decisions

All major architectural decisions are recorded in [Architecture Decision Records (ADRs)](docs/adr/).

### Key Decisions

- **ADR-001:** Repository Structure — Monorepo with clear top-level separation
- **ADR-002:** Backend Architecture — Feature-adjacent layered architecture
- **ADR-003:** Testing Strategy — Tests at `backend/tests/`, mirroring app structure
- **ADR-004:** Storage Design — Runtime storage outside `app/`, subdivided by artifact type
- **ADR-005:** Configuration Strategy — Two-layer config (env vars + domain YAML)
- **ADR-006:** Domain Plugin System — Config-driven plugins with optional Python overrides
- **ADR-007:** Dependency Management — `pyproject.toml` as single source of truth
- **ADR-008:** Models vs Schemas — Hard separation between ORM and Pydantic

---

## Repository Structure

```
CLAUSEIQ/
├── backend/              # FastAPI application
│   ├── app/              # Application code
│   ├── tests/            # Test suite
│   ├── alembic/          # Database migrations
│   ├── configs/          # Domain configurations (YAML)
│   ├── storage/          # Runtime file storage
│   ├── requirements/     # Lockfiles (generated)
│   ├── pyproject.toml    # Dependencies + tooling config
│   └── .env.example      # Environment template
│
├── frontend/             # Future: Next.js app
│
├── docs/                 # Documentation
│   ├── architecture/     # High-level design docs
│   ├── adr/              # Architecture Decision Records
│   ├── api/              # API documentation
│   └── roadmap/          # Sprint plans
│
├── infra/                # Infrastructure as Code
│   ├── docker/           # Dockerfiles + compose
│   └── nginx/            # Reverse proxy config
│
├── scripts/              # Utility scripts
│
├── .github/
│   └── workflows/        # CI/CD pipelines
│
├── .vscode/              # Editor configuration
│
├── ARCHITECTURE.md       # This file
└── README.md             # Project overview
```

### Why a Monorepo?

- Atomic commits across backend, frontend, and infrastructure
- Shared tooling and CI/CD configuration
- Simpler developer onboarding
- Can be split into polyrepo later if needed

---

## Backend Architecture

### Layer Responsibilities

```
backend/app/
├── api/                  # Transport layer (HTTP)
│   ├── v1/
│   │   ├── routes/       # Endpoint definitions
│   │   └── dependencies/ # FastAPI Depends() functions
│   └── middleware/       # HTTP middleware
│
├── services/             # Business logic (grouped by concern)
│   ├── document/         # Document parsing, chunking, ingestion
│   ├── analysis/         # Risk analysis, retrieval
│   └── ai/               # Embeddings, generation, vector store
│
├── repositories/         # Data access layer (DB queries only)
│
├── models/               # SQLAlchemy ORM models
│
├── schemas/              # Pydantic request/response schemas
│
├── plugins/              # Domain plugin system
│
├── workers/              # Background task definitions (Celery)
│
├── core/                 # Cross-cutting concerns
│   ├── config.py         # Application settings
│   ├── logging.py        # Structured logging
│   ├── security.py       # Auth utilities
│   ├── exceptions.py     # Exception hierarchy
│   └── constants.py      # Application constants
│
├── utils/                # Pure utility functions
│
└── main.py               # Application entry point
```

### Data Flow

```
HTTP Request
    ↓
[api/v1/routes]         ← Endpoint definition
    ↓
[api/v1/dependencies]   ← Auth, DB session injection
    ↓
[services]              ← Business logic
    ↓
[repositories]          ← Database queries
    ↓
[models]                ← ORM layer
    ↓
Database
```

### Rules

1. **API layer never contains business logic.** It validates input, calls services, and formats responses.
2. **Services never import SQLAlchemy.** All DB access goes through repositories.
3. **Repositories return ORM models.** Services map them to Pydantic schemas if needed.
4. **Models and schemas are separate.** ORM models live in `models/`, API schemas in `schemas/`.
5. **No circular dependencies.** Services can call other services. Repositories cannot call services.

---

## Domain Plugin System

### Problem

ClauseIQ must support multiple document domains (legal, HR, finance, etc.) without hardcoding domain-specific logic into the core application. Adding a new domain should not require code changes.

### Solution

Domains are **configuration-driven plugins** with optional Python overrides.

### Structure

```
backend/
├── configs/domains/      # Domain configuration files (YAML)
│   ├── legal.yaml
│   ├── hr.yaml
│   └── finance.yaml
│
└── app/plugins/          # Plugin system implementation
    ├── base.py           # Plugin interface
    ├── registry.py       # Plugin registry (loads at startup)
    ├── loader.py         # YAML loader
    └── validators.py     # Domain config validators
```

### Domain Configuration (YAML)

```yaml
# configs/domains/legal.yaml
domain: legal
name: Legal Contracts
description: Analysis of legal agreements and contracts

clause_types:
  - id: termination
    name: Termination Clause
    prompt: "Identify clauses related to contract termination."
  - id: liability
    name: Liability Clause
    prompt: "Identify clauses related to liability and indemnification."

risk_rules:
  - id: missing_termination
    severity: high
    condition: "clause:termination is missing"
    message: "No termination clause found."

prompts:
  summary: "Summarize this legal contract in 3 sentences."
  risk_analysis: "Analyze this contract for legal risks."
```

### Plugin Lifecycle

1. **Startup:** `plugins/loader.py` reads all YAML files from `configs/domains/`
2. **Validation:** `plugins/validators.py` ensures each config is valid
3. **Registry:** `plugins/registry.py` stores all loaded plugins
4. **Runtime:** Services retrieve plugins by domain name

### Optional Python Overrides

If a domain needs custom logic (e.g., specialized parsing), create a Python plugin:

```python
# app/plugins/legal.py
from app.plugins.base import DomainPlugin

class LegalPlugin(DomainPlugin):
    def custom_risk_analysis(self, document: str) -> dict:
        # Custom logic here
        pass
```

Register it in `plugins/registry.py`.

---

## Configuration Strategy

### Two-Layer Configuration

**Layer 1: Application Configuration** (Runtime)
- Loaded from **environment variables** via `pydantic-settings`
- Defined in `core/config.py`
- Never in YAML
- Examples: `DATABASE_URL`, `OPENAI_API_KEY`, `SECRET_KEY`

**Layer 2: Domain Configuration** (Structural)
- Loaded from **YAML files** in `configs/domains/`
- Versioned in git
- Examples: Clause types, risk rules, prompts

### Why Two Layers?

- **Security:** Secrets belong in environment variables, never in git.
- **12-Factor App:** Environment-specific config comes from the environment.
- **Domain Flexibility:** Domain rules are structural data, not secrets. They belong in version control.

### Environment Variables

All environment variables are defined in `.env.example`. Copy it to `.env` and fill in your values.

```bash
cp backend/.env.example backend/.env
```

---

## Testing Strategy

### Structure

```
backend/tests/
├── unit/                 # Unit tests (isolated, no I/O)
│   ├── services/
│   ├── repositories/
│   └── plugins/
│
├── integration/          # Integration tests (DB, external services)
│   ├── api/
│   └── db/
│
├── e2e/                  # End-to-end tests (full user flows)
│
├── fixtures/             # Test data factories
│   ├── documents.py
│   └── users.py
│
└── conftest.py           # Pytest configuration
```

### Why `backend/tests/` and not `backend/app/tests/`?

1. Tests are not application code. They should not be importable.
2. Production Docker images can exclude `tests/` with a single rule.
3. Matches FastAPI, SQLModel, and other major Python projects.

### Running Tests

```bash
cd backend
pytest                    # Run all tests
pytest tests/unit         # Run unit tests only
pytest --cov=app          # Run with coverage
```

---

## Storage Design

### Structure

```
backend/storage/
├── documents/            # Raw uploaded files
├── processed/            # Parsed/extracted content
└── cache/                # Temporary processing cache
```

### Why Subdivide?

- **Retention policies:** Raw documents may be kept forever. Cache can be cleared.
- **Backup strategies:** Documents need backups. Cache does not.
- **Migration paths:** Different subdirectories can be migrated to S3 at different times.

### Why Outside `app/`?

- Storage is a runtime concern, not application code.
- It must be excluded from Python imports and Docker application layers.
- It must be ignored by git (`.gitignore`).

### Future: Cloud Storage

When migrating to S3/GCS:
1. Update `STORAGE_BACKEND` in `.env`
2. Implement `storage/s3.py` backend
3. No changes to services or repositories

---

## Future Considerations

### Planned Features

The architecture is designed to naturally support:

- **Authentication:** JWT-based auth with user roles
- **Multi-tenancy:** Organizations, teams, workspaces
- **Billing:** Stripe integration, usage tracking
- **AI Providers:** Support for multiple LLM providers (OpenAI, Anthropic, local models)
- **Background Workers:** Celery for async document processing
- **Evaluation Pipelines:** A/B testing domain configurations
- **Monitoring:** Structured logging → Datadog/CloudWatch
- **Analytics:** User behavior tracking, document insights

### Scale Considerations

- **Database:** PostgreSQL with connection pooling (asyncpg)
- **Vector Store:** Chroma initially, Pinecone/Weaviate for scale
- **File Storage:** Local initially, S3 for production
- **Workers:** Celery + Redis for background jobs
- **Caching:** Redis for hot data
- **API Rate Limiting:** slowapi or nginx-based

---

## ADR Index

All Architecture Decision Records are located in [`docs/adr/`](docs/adr/).

| ADR | Title | Status |
|-----|-------|--------|
| [ADR-001](docs/adr/ADR-001-repository-structure.md) | Repository Structure | Accepted |
| [ADR-002](docs/adr/ADR-002-configuration-strategy.md) | Configuration Strategy | Accepted |
| [ADR-003](docs/adr/ADR-003-testing-strategy.md) | Testing Strategy | Accepted |
| [ADR-004](docs/adr/ADR-004-storage-design.md) | Storage Design | Accepted |
| [ADR-005](docs/adr/ADR-005-backend-architecture.md) | Backend Architecture | Accepted |
| [ADR-006](docs/adr/ADR-006-domain-plugin-system.md) | Domain Plugin System | Accepted |
| [ADR-007](docs/adr/ADR-007-dependency-management.md) | Dependency Management | Accepted |
| [ADR-008](docs/adr/ADR-008-models-and-schemas.md) | Models and Schemas Separation | Accepted |

---

## Questions?

For questions about this architecture, see:
- [docs/architecture/](docs/architecture/) for detailed layer documentation
- [docs/adr/](docs/adr/) for decision rationale
- [backend/README.md](backend/README.md) for backend-specific setup

**Maintainer:** Engineering Team  
**Last Review:** Sprint 0
'@
Set-Content -Path "D:\CLAUSEIQ\ARCHITECTURE.md" -Value $architecture
Write-Host "ARCHITECTURE.md written."