# .gitignore
$gitignore = @'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
pip-wheel-metadata/
share/python-wheels/
*.egg-info/
.installed.cfg
*.egg

# Virtual environments
.venv/
venv/
ENV/
env/

# IDE
.vscode/
.idea/
*.swp
*.swo
*~
.DS_Store

# Environment variables
.env
.env.local
.env.*.local

# Testing
.pytest_cache/
.coverage
htmlcov/
.tox/
.hypothesis/

# Logs
*.log
logs/

# Database
*.db
*.sqlite
*.sqlite3

# Storage (runtime files)
backend/storage/documents/*
backend/storage/processed/*
backend/storage/cache/*
!backend/storage/documents/.gitkeep
!backend/storage/processed/.gitkeep
!backend/storage/cache/.gitkeep

# Alembic
backend/alembic/versions/*.pyc

# Node (frontend future)
node_modules/
.next/
out/
.nuxt/
dist/
.cache/

# Docker
*.pid
*.seed
*.pid.lock

# OS
Thumbs.db
.DS_Store

# Jupyter
.ipynb_checkpoints/
*.ipynb

# MyPy
.mypy_cache/
.dmypy.json
dmypy.json

# Ruff
.ruff_cache/
'@
Set-Content -Path "D:\CLAUSEIQ\.gitignore" -Value $gitignore

# legal.yaml (sample domain config)
$legal_yaml = @'
# ============================================================
# ClauseIQ Domain Configuration: Legal Contracts
# ============================================================
# This file defines how ClauseIQ analyzes legal contracts.
# Modify this file to change analysis behavior without code changes.
# ============================================================

domain: legal
name: Legal Contracts
description: Analysis of legal agreements, contracts, and terms of service
version: "1.0"

# ============================================================
# Clause Types
# ============================================================
# Define what clauses to extract from documents.
# Each clause type has an ID, name, and extraction prompt.

clause_types:
  - id: termination
    name: Termination Clause
    description: Clauses describing how the contract can be terminated
    prompt: |
      Identify and extract all clauses related to contract termination,
      including notice periods, termination conditions, and penalties.

  - id: liability
    name: Liability and Indemnification
    description: Clauses limiting liability or requiring indemnification
    prompt: |
      Identify clauses related to liability limitations, indemnification
      requirements, and damages caps.

  - id: confidentiality
    name: Confidentiality
    description: Non-disclosure and confidentiality requirements
    prompt: |
      Identify confidentiality obligations, non-disclosure requirements,
      and exceptions to confidentiality.

  - id: intellectual_property
    name: Intellectual Property
    description: IP ownership and licensing terms
    prompt: |
      Identify clauses related to intellectual property ownership,
      licensing, and assignment of rights.

  - id: payment_terms
    name: Payment Terms
    description: Payment schedules, amounts, and conditions
    prompt: |
      Identify payment amounts, schedules, late fees, and payment conditions.

  - id: dispute_resolution
    name: Dispute Resolution
    description: Arbitration, jurisdiction, and dispute handling
    prompt: |
      Identify dispute resolution mechanisms including arbitration clauses,
      jurisdiction, and governing law.

# ============================================================
# Risk Rules
# ============================================================
# Define what constitutes a risk in this domain.
# Rules are evaluated after clause extraction.

risk_rules:
  - id: missing_termination
    severity: high
    condition: "clause:termination is missing"
    title: Missing Termination Clause
    description: |
      No termination clause was found. This creates uncertainty about
      how the contract can be ended.

  - id: unlimited_liability
    severity: critical
    condition: "clause:liability contains 'unlimited' or 'uncapped'"
    title: Unlimited Liability Exposure
    description: |
      The contract appears to contain unlimited or uncapped liability,
      creating significant financial risk.

  - id: missing_confidentiality
    severity: medium
    condition: "clause:confidentiality is missing"
    title: No Confidentiality Protection
    description: |
      No confidentiality clause was found. Sensitive information may
      not be protected.

  - id: unfavorable_jurisdiction
    severity: medium
    condition: "clause:dispute_resolution contains 'foreign jurisdiction'"
    title: Unfavorable Jurisdiction
    description: |
      Dispute resolution requires a potentially unfavorable jurisdiction.

  - id: automatic_renewal
    severity: low
    condition: "clause:termination contains 'automatic renewal'"
    title: Automatic Renewal Clause
    description: |
      Contract includes automatic renewal. Ensure calendar reminders
      are set for opt-out deadlines.

# ============================================================
# Prompts
# ============================================================
# AI prompts for different analysis tasks.

prompts:
  summary: |
    Summarize this legal contract in 3-5 sentences. Include:
    - What type of contract this is
    - The parties involved
    - The key obligations
    - The term/duration

  risk_analysis: |
    Analyze this legal contract for potential risks and red flags.
    Consider:
    - Liability exposure
    - Unfavorable terms
    - Missing standard protections
    - Ambiguous language
    - Unusual or one-sided clauses

  key_obligations: |
    Extract the key obligations for each party from this contract.
    Present them as a structured list.

  compliance_check: |
    Review this contract for common legal compliance issues:
    - GDPR/privacy compliance (if applicable)
    - Employment law compliance (if applicable)
    - Industry-specific regulations

# ============================================================
# Metadata
# ============================================================

metadata:
  author: ClauseIQ Engineering Team
  created: "2024-07-24"
  last_updated: "2024-07-24"
  requires_review: false
'@
Set-Content -Path "D:\CLAUSEIQ\backend\configs\domains\legal.yaml" -Value $legal_yaml

# .editorconfig
$editorconfig = @'
# EditorConfig is awesome: https://EditorConfig.org

root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

[*.{py,pyi}]
indent_style = space
indent_size = 4

[*.{js,jsx,ts,tsx,json,yml,yaml}]
indent_style = space
indent_size = 2

[*.md]
trim_trailing_whitespace = false

[Makefile]
indent_style = tab
'@
Set-Content -Path "D:\CLAUSEIQ\.editorconfig" -Value $editorconfig

Write-Host "Configuration files written."