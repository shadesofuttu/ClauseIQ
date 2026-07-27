"""
SQLAlchemy Declarative Base

All ORM models inherit from Base.
Provides common columns: id, created_at, updated_at.

Rules:
- This file defines structure only. No business logic.
- All models use UUID primary keys.
- All timestamps are timezone-aware UTC.
"""

import uuid
from datetime import datetime, timezone

from sqlalchemy import DateTime
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column

class Base(DeclarativeBase):
    """Declarative base for all ORM models."""
    pass

class TimestampMixin:
    """Mixin that adds created_at and updated_at to any model."""
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        nullable=False,
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
        nullable=False,
    )

class UUIDMixin:
    """Mixin that adds a UUID primary key to any model."""
    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        nullable=False,
    )
