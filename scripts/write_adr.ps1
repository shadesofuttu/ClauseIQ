# ADR-001
$adr001 = @'
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
'@
Set-Content -Path "D:\CLAUSEIQ\docs\adr\ADR-001-repository-structure.md" -Value $adr001

# ADR-005
$adr005 = @'
# ADR-005: Backend Architecture

**Status:** Accepted  
**Date:** 2024-07-24  
**Deciders:** Engineering Team

---

## Context

ClauseIQ backend must support:
- Multiple domains (legal, HR, finance)
- AI-powered document analysis
- Background processing (async ingestion)
- Authentication and multi-tenancy (future)
- High test coverage
- Easy onboarding for new developers

We need a clear, maintainable architecture that will scale to 20,000+ lines of code.

## Decision

We will use a **feature-adjacent layered architecture** inside `backend/app/`:

```
backend/app/
├── api/              # Transport layer (HTTP)
├── services/         # Business logic (grouped by concern)
├── repositories/     # Data access layer
├── models/           # SQLAlchemy ORM models
├── schemas/          # Pydantic request/response schemas
├── plugins/          # Domain plugin system
├── workers/          # Background tasks
├── core/             # Cross-cutting concerns
├── utils/            # Pure utilities
└── main.py           # Application entry point
```

## Rationale

### Why This Structure?

**api/** — HTTP layer only. No business logic.
- Routes define endpoints
- Dependencies handle auth, DB sessions
- Middleware handles cross-cutting HTTP concerns

**services/** — All business logic lives here, grouped by concern:
- `services/document/` — Parsing, chunking, ingestion
- `services/analysis/` — Risk analysis, retrieval
- `services/ai/` — Embeddings, generation, vector store

Why grouped? Flat services directories become grab-bags after 20 files.

**repositories/** — Database queries only. No business logic.
- Services call repositories
- Repositories return ORM models
- Services map ORM → Pydantic if needed

**models/** — SQLAlchemy ORM models only.
**schemas/** — Pydantic schemas only.

Why separate? ORM models and API schemas evolve at different rates. Hard separation prevents coupling.

**plugins/** — Domain plugin system.
Domains are config-driven. No hardcoded domain logic.

**workers/** — Celery task definitions.
Background processing for long-running operations (ingestion, embeddings).

**core/** — Cross-cutting concerns:
- `config.py` — Settings (pydantic-settings)
- `logging.py` — Structured logging
- `security.py` — Auth utilities
- `exceptions.py` — Exception hierarchy
- `constants.py` — Application constants

**utils/** — Pure utility functions. No dependencies on other layers.

**main.py** — Application entry point. Creates FastAPI app, registers middleware, routers, exception handlers.

### Data Flow

```
HTTP Request
    ↓
api/v1/routes         ← Endpoint
    ↓
api/v1/dependencies   ← Auth, DB session
    ↓
services              ← Business logic
    ↓
repositories          ← DB queries
    ↓
models                ← ORM
    ↓
Database
```

### Rules

1. **API never contains business logic**
2. **Services never import SQLAlchemy** (use repositories)
3. **Repositories return ORM models**
4. **Models and schemas are separate**
5. **No circular dependencies**

## Consequences

### Positive
- Clear separation of concerns
- Easy to locate code
- Testable (mock repositories in service tests)
- Scalable (grouped services prevent flat directory sprawl)
- Onboarding-friendly (every folder has one job)

### Negative
- More directories than a flat structure
- Requires discipline to respect boundaries

### Mitigation
- Document rules in ARCHITECTURE.md
- Code review enforcement
- Linting rules (ruff) to prevent cross-boundary imports

## Alternatives Considered

### Full DDD (aggregates, value objects, domain events)

**Rejected because:**
- Over-engineered for current stage
- Adds complexity without clear benefit
- Can be introduced later inside services if needed

### Flat services/ directory

**Rejected because:**
- Becomes a grab-bag after 20 files
- No clear grouping principle
- Harder to navigate at scale

### SQLModel (combined ORM + Pydantic)

**Rejected because:**
- Reduces flexibility
- Makes it harder to evolve DB schema independently of API schema
- Good for small projects, wrong for a platform

---

**Last Updated:** Sprint 0
'@
Set-Content -Path "D:\CLAUSEIQ\docs\adr\ADR-005-backend-architecture.md" -Value $adr005

# ADR-006
$adr006 = @'
# ADR-006: Domain Plugin System

**Status:** Accepted  
**Date:** 2024-07-24  
**Deciders:** Engineering Team

---

## Context

ClauseIQ must support multiple document domains:
- Legal contracts
- HR documents
- Financial agreements
- Insurance policies
- Compliance documents
- And more...

Each domain has:
- Specific clause types to extract
- Unique risk rules
- Custom prompts for AI analysis

**Core Requirement:** Adding a new domain should NOT require code changes or repository restructuring.

## Decision

Domains are **configuration-driven plugins** with optional Python overrides.

### Structure

```
backend/
├── configs/domains/      # Domain YAML configs (outside app/)
│   ├── legal.yaml
│   ├── hr.yaml
│   └── finance.yaml
│
└── app/plugins/          # Plugin system (inside app/)
    ├── base.py           # Plugin interface
    ├── registry.py       # Plugin registry
    ├── loader.py         # YAML loader
    └── validators.py     # Config validators
```

### Domain Configuration (YAML)

```yaml
domain: legal
name: Legal Contracts
description: Analysis of legal agreements

clause_types:
  - id: termination
    name: Termination Clause
    prompt: "Identify termination clauses."

risk_rules:
  - id: missing_termination
    severity: high
    condition: "clause:termination is missing"
    message: "No termination clause found."

prompts:
  summary: "Summarize this contract."
  risk_analysis: "Analyze legal risks."
```

### Plugin Lifecycle

1. **Startup:** `loader.py` reads all YAML from `configs/domains/`
2. **Validation:** `validators.py` ensures configs are valid
3. **Registry:** `registry.py` stores loaded plugins
4. **Runtime:** Services retrieve plugins by domain name

### Optional Python Overrides

If a domain needs custom logic:

```python
# app/plugins/legal.py
from app.plugins.base import DomainPlugin

class LegalPlugin(DomainPlugin):
    def custom_risk_analysis(self, doc: str) -> dict:
        # Domain-specific logic
        pass
```

Register in `registry.py`.

## Rationale

### Why Config-Driven?

1. **No code changes:** Non-engineers can add domains
2. **Version control:** YAML in git = audit trail
3. **Easy testing:** Swap configs in tests
4. **Runtime flexibility:** Load/reload configs without restart (future)

### Why YAML?

- Human-readable
- Standard for configuration
- Easy validation with Pydantic
- Git-friendly (clear diffs)

### Why Outside `app/`?

- Configuration is data, not code
- Should not be packaged with the Python application
- Can be loaded from external sources (S3, database) in the future

### Why Optional Python Overrides?

- 80% of domains can be config-only
- 20% need custom logic (specialized parsing, complex rules)
- Python plugins provide escape hatch without compromising core architecture

## Consequences

### Positive
- Add new domains without code changes
- Domain rules versioned in git
- Easy A/B testing of rule changes
- Non-engineers can contribute domain configs
- Scales to 100+ domains

### Negative
- YAML validation complexity
- Requires discipline to avoid moving logic into YAML

### Mitigation
- Strong Pydantic validators for YAML
- Document when to use Python plugins vs config
- Code review for complex YAML logic

## Alternatives Considered

### Hardcoded Domain Modules

```python
app/domains/legal/
app/domains/hr/
app/domains/finance/
```

**Rejected because:**
- Violates core requirement (code changes to add domains)
- Harder to test (can't swap configs)
- No clear boundary between domain code and core code

### Python Entry Points Plugin System

**Rejected because:**
- Over-engineered for current stage
- Requires external packages for domain definitions
- Harder onboarding
- Config-driven is simpler and covers 80% of cases

### Database-Stored Configuration

**Rejected for now because:**
- Adds complexity (migrations, UI for editing)
- Loses git history
- Can be added later (configs can be loaded from DB)

---

**Last Updated:** Sprint 0
'@
Set-Content -Path "D:\CLAUSEIQ\docs\adr\ADR-006-domain-plugin-system.md" -Value $adr006

Write-Host "ADR files written."