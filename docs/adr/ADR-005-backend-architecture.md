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
