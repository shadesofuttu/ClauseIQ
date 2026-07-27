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
