# core/config.py
$config = @"
"""
Application Configuration

Single source of truth for all application settings.
Loaded from environment variables via pydantic-settings.

Rules:
- Never hardcode secrets here.
- Never use YAML for runtime config.
- All settings must have explicit types.
- All settings must have sensible defaults where safe.
"""

from typing import List
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
    )

    # --- Project ---
    PROJECT_NAME: str = "ClauseIQ"
    PROJECT_DESCRIPTION: str = "AI-powered Document Intelligence Platform"
    VERSION: str = "0.1.0"
    ENVIRONMENT: str = "development"  # development | staging | production

    # --- API ---
    API_V1_PREFIX: str = "/api/v1"
    ALLOWED_ORIGINS: List[str] = ["http://localhost:3000"]

    # --- Database ---
    DATABASE_URL: str = "postgresql+asyncpg://user:password@localhost:5432/clauseiq"
    DATABASE_POOL_SIZE: int = 10
    DATABASE_MAX_OVERFLOW: int = 20

    # --- Security ---
    SECRET_KEY: str = "change-this-in-production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30

    # --- Storage ---
    STORAGE_BACKEND: str = "local"  # local | s3
    STORAGE_ROOT: str = "storage"
    MAX_UPLOAD_SIZE_MB: int = 50

    # --- AI Providers ---
    OPENAI_API_KEY: str = ""
    OPENAI_MODEL: str = "gpt-4o"
    EMBEDDING_MODEL: str = "text-embedding-3-small"

    # --- Vector Store ---
    VECTOR_STORE_BACKEND: str = "chroma"  # chroma | pinecone | weaviate
    CHROMA_HOST: str = "localhost"
    CHROMA_PORT: int = 8001

    # --- Workers ---
    CELERY_BROKER_URL: str = "redis://localhost:6379/0"
    CELERY_RESULT_BACKEND: str = "redis://localhost:6379/0"

    # --- Logging ---
    LOG_LEVEL: str = "INFO"
    LOG_FORMAT: str = "json"  # json | text

settings = Settings()
"@
Set-Content -Path "D:\CLAUSEIQ\backend\app\core\config.py" -Value $config

# core/constants.py
$constants = @"
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
"@
Set-Content -Path "D:\CLAUSEIQ\backend\app\core\constants.py" -Value $constants

# core/exceptions.py
$exceptions = @"
"""
Application Exception Hierarchy

All custom exceptions are defined here.
Exception handlers are registered in main.py via register_exception_handlers().

Design rules:
- Every exception has a clear name that describes what went wrong.
- Every exception carries a user-safe message and an HTTP status code.
- Never expose internal details in exception messages.
"""

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

# --- Base ---

class ClauseIQException(Exception):
    """Base exception for all ClauseIQ application errors."""
    status_code: int = 500
    message: str = "An unexpected error occurred."

    def __init__(self, message: str | None = None):
        self.message = message or self.message
        super().__init__(self.message)

# --- Domain Exceptions ---

class DocumentNotFoundError(ClauseIQException):
    status_code = 404
    message = "Document not found."

class DocumentProcessingError(ClauseIQException):
    status_code = 422
    message = "Document could not be processed."

class UnsupportedFileTypeError(ClauseIQException):
    status_code = 415
    message = "File type is not supported."

class FileTooLargeError(ClauseIQException):
    status_code = 413
    message = "File exceeds the maximum allowed size."

class DomainNotFoundError(ClauseIQException):
    status_code = 404
    message = "Domain configuration not found."

class PluginLoadError(ClauseIQException):
    status_code = 500
    message = "Failed to load domain plugin."

# --- Auth Exceptions ---

class AuthenticationError(ClauseIQException):
    status_code = 401
    message = "Authentication failed."

class AuthorizationError(ClauseIQException):
    status_code = 403
    message = "You do not have permission to perform this action."

class TokenExpiredError(ClauseIQException):
    status_code = 401
    message = "Session has expired. Please log in again."

# --- AI Exceptions ---

class AIProviderError(ClauseIQException):
    status_code = 502
    message = "AI provider returned an error."

class EmbeddingError(ClauseIQException):
    status_code = 502
    message = "Failed to generate embeddings."

class VectorStoreError(ClauseIQException):
    status_code = 502
    message = "Vector store operation failed."

# --- Exception Handlers ---

def register_exception_handlers(app: FastAPI) -> None:
    """Register all exception handlers on the FastAPI app."""

    @app.exception_handler(ClauseIQException)
    async def clauseiq_exception_handler(
        request: Request, exc: ClauseIQException
    ) -> JSONResponse:
        return JSONResponse(
            status_code=exc.status_code,
            content={
                "error": type(exc).__name__,
                "message": exc.message,
            },
        )

    @app.exception_handler(Exception)
    async def unhandled_exception_handler(
        request: Request, exc: Exception
    ) -> JSONResponse:
        return JSONResponse(
            status_code=500,
            content={
                "error": "InternalServerError",
                "message": "An unexpected error occurred.",
            },
        )
"@
Set-Content -Path "D:\CLAUSEIQ\backend\app\core\exceptions.py" -Value $exceptions

# core/logging.py
$logging = @"
"""
Logging Configuration

Structured JSON logging via structlog.
In development: human-readable colored output.
In production: machine-readable JSON for log aggregators (Datadog, CloudWatch, etc).
"""

import logging
import sys

import structlog

from app.core.config import settings

def configure_logging() -> None:
    """
    Configure structured logging for the application.
    Called once at application startup in main.py lifespan.
    """
    shared_processors = [
        structlog.contextvars.merge_contextvars,
        structlog.stdlib.add_logger_name,
        structlog.stdlib.add_log_level,
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.StackInfoRenderer(),
    ]

    if settings.LOG_FORMAT == "json":
        processors = shared_processors + [
            structlog.processors.dict_tracebacks,
            structlog.processors.JSONRenderer(),
        ]
    else:
        processors = shared_processors + [
            structlog.dev.ConsoleRenderer(colors=True),
        ]

    structlog.configure(
        processors=processors,
        wrapper_class=structlog.make_filtering_bound_logger(
            logging.getLevelName(settings.LOG_LEVEL)
        ),
        context_class=dict,
        logger_factory=structlog.PrintLoggerFactory(sys.stdout),
        cache_logger_on_first_use=True,
    )

    # Suppress noisy third-party loggers in production
    if settings.ENVIRONMENT == "production":
        logging.getLogger("uvicorn.access").setLevel(logging.WARNING)

def get_logger(name: str = __name__) -> structlog.BoundLogger:
    """Return a bound logger for use in any module."""
    return structlog.get_logger(name)
"@
Set-Content -Path "D:\CLAUSEIQ\backend\app\core\logging.py" -Value $logging

# core/security.py
$security = @"
"""
Security Utilities

Handles:
- Password hashing and verification
- JWT token creation and decoding

This module is a utility layer only.
It does not handle HTTP requests or FastAPI dependencies.
Those belong in api/v1/dependencies/.
"""

from datetime import datetime, timedelta, timezone

from jose import JWTError, jwt
from passlib.context import CryptContext

from app.core.config import settings
from app.core.exceptions import AuthenticationError, TokenExpiredError

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    """Hash a plain-text password."""
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify a plain-text password against a hashed password."""
    return pwd_context.verify(plain_password, hashed_password)

def create_access_token(subject: str) -> str:
    """
    Create a signed JWT access token.

    Args:
        subject: The user identifier (typically user ID as string).

    Returns:
        A signed JWT string.
    """
    expire = datetime.now(timezone.utc) + timedelta(
        minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES
    )
    payload = {"sub": subject, "exp": expire}
    return jwt.encode(payload, settings.SECRET_KEY, algorithm=settings.ALGORITHM)

def decode_access_token(token: str) -> str:
    """
    Decode and validate a JWT access token.

    Args:
        token: The JWT string to decode.

    Returns:
        The subject (user ID) from the token.

    Raises:
        TokenExpiredError: If the token has expired.
        AuthenticationError: If the token is invalid.
    """
    try:
        payload = jwt.decode(
            token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM]
        )
        subject: str | None = payload.get("sub")
        if subject is None:
            raise AuthenticationError("Token missing subject.")
        return subject
    except JWTError as e:
        if "expired" in str(e).lower():
            raise TokenExpiredError()
        raise AuthenticationError("Invalid token.")
"@
Set-Content -Path "D:\CLAUSEIQ\backend\app\core\security.py" -Value $security

Write-Host "All core files written."