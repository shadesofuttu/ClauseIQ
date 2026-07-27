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
