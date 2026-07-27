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
