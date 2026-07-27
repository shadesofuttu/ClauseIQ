# ClauseIQ Backend

**FastAPI application for document intelligence**

---

## Overview

This is the backend service for ClauseIQ, built with FastAPI, SQLAlchemy, and async Python.

### Technology Stack

- **Web Framework:** FastAPI
- **Database:** PostgreSQL + SQLAlchemy 2.0 (async)
- **Migrations:** Alembic
- **AI:** OpenAI API (GPT-4, embeddings)
- **Vector Store:** ChromaDB
- **Workers:** Celery + Redis
- **Testing:** pytest + pytest-asyncio
- **Linting:** ruff + mypy

---

## Setup

### 1. Prerequisites

- Python 3.11+
- PostgreSQL 15+
- Redis 7+

### 2. Create Virtual Environment

```bash
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
```

### 3. Install Dependencies

```bash
# Development install (includes dev dependencies)
pip install -e ".[dev]"

# Production install
pip install -e ".[prod]"
```

### 4. Configure Environment

```bash
cp .env.example .env
```

Edit `.env` and set:
- `DATABASE_URL`
- `OPENAI_API_KEY`
- `SECRET_KEY` (generate with `openssl rand -hex 32`)

### 5. Run Migrations

```bash
alembic upgrade head
```

### 6. Start the Server

```bash
uvicorn app.main:app --reload
```

API available at: `http://localhost:8000`  
Docs available at: `http://localhost:8000/api/docs`

---

## Project Structure

```
backend/
├── app/
│   ├── api/              # HTTP layer
│   │   ├── v1/
│   │   │   ├── routes/   # Endpoints
│   │   │   └── dependencies/  # FastAPI Depends()
│   │   └── middleware/
│   │
│   ├── services/         # Business logic
│   │   ├── document/     # Parsing, chunking, ingestion
│   │   ├── analysis/     # Risk analysis, retrieval
│   │   └── ai/           # Embeddings, generation, vector store
│   │
│   ├── repositories/     # Database access
│   ├── models/           # SQLAlchemy ORM models
│   ├── schemas/          # Pydantic schemas
│   ├── plugins/          # Domain plugin system
│   ├── workers/          # Celery tasks
│   ├── core/             # Config, logging, security, exceptions
│   ├── utils/            # Pure utilities
│   └── main.py           # Application entry point
│
├── tests/                # Test suite
│   ├── unit/
│   ├── integration/
│   ├── e2e/
│   └── fixtures/
│
├── alembic/              # Database migrations
├── configs/              # Domain YAML configs
├── storage/              # Runtime file storage (gitignored)
├── requirements/         # Lockfiles (generated)
├── pyproject.toml        # Dependencies + tooling
└── .env.example          # Environment template
```

---

## Development

### Running Tests

```bash
# All tests
pytest

# Specific test types
pytest tests/unit
pytest tests/integration
pytest tests/e2e

# With coverage
pytest --cov=app --cov-report=html

# Watch mode
pytest --watch
```

### Code Quality

```bash
# Linting
ruff check .

# Auto-fix
ruff check --fix .

# Formatting
ruff format .

# Type checking
mypy app
```

### Pre-commit Hooks

```bash
pre-commit install
pre-commit run --all-files
```

### Database Migrations

```bash
# Create a new migration
alembic revision --autogenerate -m "Add users table"

# Apply migrations
alembic upgrade head

# Rollback
alembic downgrade -1

# View history
alembic history
```

### Adding a New Endpoint

1. Define Pydantic schemas in `app/schemas/`
2. Create route handler in `app/api/v1/routes/`
3. Implement business logic in `app/services/`
4. Add database queries in `app/repositories/`
5. Write tests in `tests/`

### Adding a New Domain

1. Create YAML config in `configs/domains/`
2. Define clause types, risk rules, prompts
3. (Optional) Add Python plugin in `app/plugins/`
4. Restart application

See [docs/architecture/domain-plugin-system.md](../docs/architecture/domain-plugin-system.md) for details.

---

## API Documentation

Once the server is running:

- **Swagger UI:** `http://localhost:8000/api/docs`
- **ReDoc:** `http://localhost:8000/api/redoc`
- **OpenAPI JSON:** `http://localhost:8000/api/openapi.json`

---

## Configuration

All configuration comes from environment variables. See `.env.example` for available options.

### Key Variables

- `ENVIRONMENT` — development | staging | production
- `DATABASE_URL` — PostgreSQL connection string
- `SECRET_KEY` — JWT signing key
- `OPENAI_API_KEY` — OpenAI API key
- `LOG_LEVEL` — INFO | DEBUG | WARNING | ERROR
- `LOG_FORMAT` — json | text

---

## Deployment

### Docker

```bash
docker build -f ../infra/docker/Dockerfile.backend -t clauseiq-backend .
docker run -p 8000:8000 --env-file .env clauseiq-backend
```

### Production Checklist

- [ ] Set `ENVIRONMENT=production`
- [ ] Generate secure `SECRET_KEY`
- [ ] Use managed PostgreSQL (RDS, Cloud SQL, etc.)
- [ ] Use managed Redis
- [ ] Set up log aggregation (Datadog, CloudWatch)
- [ ] Enable API rate limiting
- [ ] Configure CORS for production frontend
- [ ] Set up SSL/TLS
- [ ] Run migrations
- [ ] Set up monitoring and alerting

---

## Troubleshooting

### Database Connection Issues

```bash
# Check PostgreSQL is running
pg_isready -h localhost -p 5432

# Test connection
psql $DATABASE_URL
```

### Migration Conflicts

```bash
# Reset to a clean state (CAREFUL: destroys data)
alembic downgrade base
alembic upgrade head
```

### Import Errors

Ensure you installed the package in editable mode:

```bash
pip install -e ".[dev]"
```

---

## Architecture

For detailed architecture documentation, see:

- [ARCHITECTURE.md](../ARCHITECTURE.md) — Overall system design
- [docs/architecture/backend.md](../docs/architecture/backend.md) — Backend-specific details
- [docs/adr/](../docs/adr/) — Architecture Decision Records

---

## Questions?

For backend-specific questions:
1. Check [docs/architecture/backend.md](../docs/architecture/backend.md)
2. Review relevant ADRs in [docs/adr/](../docs/adr/)
3. Open an issue

**Maintainer:** Backend Team  
**Last Updated:** Sprint 0
