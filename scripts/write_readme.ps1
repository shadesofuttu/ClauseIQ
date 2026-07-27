# Root README.md
$root_readme = @'
# ClauseIQ

**AI-powered Document Intelligence Platform**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Python 3.11+](https://img.shields.io/badge/python-3.11+-blue.svg)](https://www.python.org/downloads/)
[![Code style: ruff](https://img.shields.io/badge/code%20style-ruff-000000.svg)](https://github.com/astral-sh/ruff)

---

## Overview

ClauseIQ is a production-grade platform for analyzing domain-specific documents using AI. Initially focused on legal contracts, it is architected to support multiple domains:

- Legal Contracts
- HR Documents
- Financial Agreements
- Insurance Policies
- Compliance Documents
- Privacy Policies
- Procurement Contracts
- Employment Agreements

### Key Features

- **Domain-Adaptive:** Add new document domains via configuration, not code changes
- **AI-Powered:** Leverages LLMs for intelligent document analysis
- **Production-Ready:** Built with scalability, security, and maintainability in mind
- **Extensible:** Plugin-based architecture for custom domain logic

---

## Architecture

ClauseIQ follows a layered, feature-adjacent architecture:

```
├── backend/          FastAPI application
├── frontend/         (Future) Next.js application
├── docs/             Architecture and API documentation
├── infra/            Docker, nginx, IaC
└── scripts/          Utility scripts
```

For detailed architecture documentation, see [ARCHITECTURE.md](ARCHITECTURE.md).

---

## Quick Start

### Prerequisites

- Python 3.11+
- PostgreSQL 15+
- Redis 7+ (for background workers)
- OpenAI API key

### Backend Setup

```bash
# Navigate to backend
cd backend

# Create virtual environment
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

# Install dependencies
pip install -e ".[dev]"

# Copy environment template
cp .env.example .env
# Edit .env with your configuration

# Run database migrations
alembic upgrade head

# Start the server
uvicorn app.main:app --reload
```

The API will be available at `http://localhost:8000`.

API documentation: `http://localhost:8000/api/docs`

### Docker Setup (Alternative)

```bash
# Start all services
docker-compose -f infra/docker/docker-compose.yml up
```

---

## Project Status

**Current Phase:** Sprint 0 — Repository Foundation

- [x] Repository structure design
- [x] Core architecture implementation
- [x] Configuration system
- [x] Domain plugin system foundation
- [x] Database models and migrations
- [x] Testing infrastructure
- [ ] Authentication & authorization
- [ ] Document upload & parsing
- [ ] AI analysis pipeline
- [ ] Frontend application
- [ ] Production deployment

See [docs/roadmap/](docs/roadmap/) for detailed sprint plans.

---

## Documentation

- **[ARCHITECTURE.md](ARCHITECTURE.md)** — System architecture and design decisions
- **[backend/README.md](backend/README.md)** — Backend setup and development guide
- **[docs/architecture/](docs/architecture/)** — Detailed architecture documentation
- **[docs/adr/](docs/adr/)** — Architecture Decision Records
- **[docs/api/](docs/api/)** — API documentation

---

## Development

### Running Tests

```bash
cd backend
pytest                    # All tests
pytest tests/unit         # Unit tests only
pytest --cov=app          # With coverage
```

### Code Quality

```bash
# Linting and formatting
ruff check .              # Lint
ruff format .             # Format
mypy app                  # Type checking

# Pre-commit hooks
pre-commit install
pre-commit run --all-files
```

### Adding a New Domain

1. Create a YAML config in `backend/configs/domains/`
2. Define clause types, risk rules, and prompts
3. (Optional) Add custom Python plugin in `backend/app/plugins/`
4. Restart the application

No code changes required for basic domains.

---

## Contributing

Contributions are welcome! Please:

1. Read [ARCHITECTURE.md](ARCHITECTURE.md) to understand the design
2. Follow the existing code style (enforced by ruff)
3. Write tests for new features
4. Update documentation as needed
5. Create an ADR for significant architectural changes

---

## License

MIT License. See [LICENSE](LICENSE) for details.

---

## Contact

For questions or discussions, open an issue or reach out to the maintainers.

**Maintainer:** Engineering Team  
**Project Start:** July 2024  
**Status:** Active Development
'@
Set-Content -Path "D:\CLAUSEIQ\README.md" -Value $root_readme

# Backend README.md
$backend_readme = @'
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
'@
Set-Content -Path "D:\CLAUSEIQ\backend\README.md" -Value $backend_readme

Write-Host "README files written."