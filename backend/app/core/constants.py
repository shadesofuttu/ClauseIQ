"""
Application-wide Constants

Only truly constant values belong here.
No configuration. No environment-specific values.
No magic strings that belong in config.
"""

from enum import Enum

class Environment(str, Enum):
    DEVELOPMENT = "development"
    STAGING = "staging"
    PRODUCTION = "production"

class StorageBackend(str, Enum):
    LOCAL = "local"
    S3 = "s3"

class VectorStoreBackend(str, Enum):
    CHROMA = "chroma"
    PINECONE = "pinecone"
    WEAVIATE = "weaviate"

class DocumentStatus(str, Enum):
    PENDING = "pending"
    PROCESSING = "processing"
    READY = "ready"
    FAILED = "failed"

class DomainType(str, Enum):
    LEGAL = "legal"
    HR = "hr"
    FINANCE = "finance"
    INSURANCE = "insurance"
    COMPLIANCE = "compliance"
    PRIVACY = "privacy"
    PROCUREMENT = "procurement"
    EMPLOYMENT = "employment"

class RiskLevel(str, Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"

# File handling
ALLOWED_MIME_TYPES = {
    "application/pdf",
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    "text/plain",
}

ALLOWED_EXTENSIONS = {".pdf", ".docx", ".txt"}

# Chunking defaults
DEFAULT_CHUNK_SIZE = 512
DEFAULT_CHUNK_OVERLAP = 64
MAX_CHUNK_SIZE = 2048

# API
DEFAULT_PAGE_SIZE = 20
MAX_PAGE_SIZE = 100
