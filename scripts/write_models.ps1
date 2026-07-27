# models/base.py
$base = @"
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
"@
Set-Content -Path "D:\CLAUSEIQ\backend\app\models\base.py" -Value $base

# models/user.py
$user = @"
"""
User ORM Model

Represents an authenticated user of the platform.
This is the ORM layer only - no business logic.
"""

from sqlalchemy import Boolean, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, TimestampMixin, UUIDMixin

class User(UUIDMixin, TimestampMixin, Base):
    __tablename__ = "users"

    email: Mapped[str] = mapped_column(
        String(255), unique=True, index=True, nullable=False
    )
    hashed_password: Mapped[str] = mapped_column(String(255), nullable=False)
    full_name: Mapped[str] = mapped_column(String(255), nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    is_superuser: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)

    # Relationships
    documents: Mapped[list["Document"]] = relationship(
        "Document", back_populates="owner", lazy="selectin"
    )

    def __repr__(self) -> str:
        return f"<User id={self.id} email={self.email}>"
"@
Set-Content -Path "D:\CLAUSEIQ\backend\app\models\user.py" -Value $user

# models/document.py
$document = @"
"""
Document ORM Model

Represents an uploaded document in the platform.
This is the ORM layer only - no business logic.
"""

import uuid

from sqlalchemy import ForeignKey, Integer, String, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, TimestampMixin, UUIDMixin
from app.core.constants import DocumentStatus, DomainType

class Document(UUIDMixin, TimestampMixin, Base):
    __tablename__ = "documents"

    # Identity
    filename: Mapped[str] = mapped_column(String(255), nullable=False)
    original_filename: Mapped[str] = mapped_column(String(255), nullable=False)
    mime_type: Mapped[str] = mapped_column(String(127), nullable=False)
    size_bytes: Mapped[int] = mapped_column(Integer, nullable=False)

    # Domain
    domain: Mapped[str] = mapped_column(
        String(64),
        nullable=False,
        default=DomainType.LEGAL.value,
    )

    # Processing
    status: Mapped[str] = mapped_column(
        String(32),
        nullable=False,
        default=DocumentStatus.PENDING.value,
        index=True,
    )
    error_message: Mapped[str | None] = mapped_column(Text, nullable=True)

    # Storage
    storage_path: Mapped[str] = mapped_column(String(512), nullable=False)

    # Ownership
    owner_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    owner: Mapped["User"] = relationship("User", back_populates="documents")

    def __repr__(self) -> str:
        return f"<Document id={self.id} filename={self.filename} status={self.status}>"
"@
Set-Content -Path "D:\CLAUSEIQ\backend\app\models\document.py" -Value $document

# models/__init__.py
$models_init = @"
"""ORM Models package. Import all models here for Alembic autodiscovery."""

from app.models.base import Base
from app.models.user import User
from app.models.document import Document

__all__ = ["Base", "User", "Document"]
"@
Set-Content -Path "D:\CLAUSEIQ\backend\app\models\__init__.py" -Value $models_init

Write-Host "Models written."

# schemas/common.py
$common = @"
"""
Shared Pydantic Schemas

Common response envelopes, pagination, and shared types.
Used across multiple API endpoints.
"""

import uuid
from datetime import datetime
from typing import Generic, List, TypeVar

from pydantic import BaseModel, ConfigDict

DataT = TypeVar("DataT")

class APIResponse(BaseModel, Generic[DataT]):
    """Standard API response envelope."""
    success: bool = True
    data: DataT

class PaginatedResponse(BaseModel, Generic[DataT]):
    """Paginated API response."""
    items: List[DataT]
    total: int
    page: int
    page_size: int
    pages: int

class PaginationParams(BaseModel):
    """Common pagination query parameters."""
    page: int = 1
    page_size: int = 20
"@
Set-Content -Path "D:\CLAUSEIQ\backend\app\schemas\common.py" -Value $common

# schemas/user.py
$user_schema = @"
"""
User Pydantic Schemas

Defines the API contract for user-related endpoints.
Completely separate from the ORM model.
"""

import uuid
from datetime import datetime

from pydantic import BaseModel, EmailStr, ConfigDict

class UserBase(BaseModel):
    email: EmailStr
    full_name: str

class UserCreate(UserBase):
    password: str

class UserUpdate(BaseModel):
    full_name: str | None = None
    password: str | None = None

class UserResponse(UserBase):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    is_active: bool
    created_at: datetime

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
"@
Set-Content -Path "D:\CLAUSEIQ\backend\app\schemas\user.py" -Value $user_schema

# schemas/document.py
$doc_schema = @"
"""
Document Pydantic Schemas

Defines the API contract for document-related endpoints.
Completely separate from the ORM model.
"""

import uuid
from datetime import datetime

from pydantic import BaseModel, ConfigDict

from app.core.constants import DocumentStatus, DomainType

class DocumentUploadResponse(BaseModel):
    """Returned immediately after a file is uploaded."""
    id: uuid.UUID
    filename: str
    domain: DomainType
    status: DocumentStatus
    created_at: datetime

class DocumentResponse(BaseModel):
    """Full document representation."""
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    filename: str
    original_filename: str
    mime_type: str
    size_bytes: int
    domain: DomainType
    status: DocumentStatus
    error_message: str | None
    created_at: datetime
    updated_at: datetime
"@
Set-Content -Path "D:\CLAUSEIQ\backend\app\schemas\document.py" -Value $doc_schema

# schemas/analysis.py
$analysis_schema = @"
"""
Analysis Pydantic Schemas

Defines the API contract for document analysis results.
"""

import uuid
from typing import List

from pydantic import BaseModel

from app.core.constants import RiskLevel

class ClauseResult(BaseModel):
    """A single identified clause."""
    clause_type: str
    text: str
    page_number: int | None
    confidence: float

class RiskFlag(BaseModel):
    """A single risk flag identified in the document."""
    title: str
    description: str
    level: RiskLevel
    clause_reference: str | None

class AnalysisResponse(BaseModel):
    """Full analysis result for a document."""
    document_id: uuid.UUID
    domain: str
    summary: str
    clauses: List[ClauseResult]
    risk_flags: List[RiskFlag]
    risk_score: float  # 0.0 - 1.0
"@
Set-Content -Path "D:\CLAUSEIQ\backend\app\schemas\analysis.py" -Value $analysis_schema

# schemas/__init__.py
$schemas_init = @"
"""Pydantic Schemas package."""

from app.schemas.common import APIResponse, PaginatedResponse, PaginationParams
from app.schemas.user import UserCreate, UserUpdate, UserResponse, TokenResponse
from app.schemas.document import DocumentUploadResponse, DocumentResponse
from app.schemas.analysis import AnalysisResponse, ClauseResult, RiskFlag

__all__ = [
    "APIResponse",
    "PaginatedResponse",
    "PaginationParams",
    "UserCreate",
    "UserUpdate",
    "UserResponse",
    "TokenResponse",
    "DocumentUploadResponse",
    "DocumentResponse",
    "AnalysisResponse",
    "ClauseResult",
    "RiskFlag",
]
"@
Set-Content -Path "D:\CLAUSEIQ\backend\app\schemas\__init__.py" -Value $schemas_init

Write-Host "Schemas written."

# repositories/base.py
$repo_base = @"
"""
Base Repository

Provides generic CRUD operations for all repositories.
All database access goes through repositories.
Services must never import SQLAlchemy directly.

Design:
- Async by default (asyncpg)
- Typed with generics
- No business logic here
"""

import uuid
from typing import Generic, List, Type, TypeVar

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.base import Base

ModelT = TypeVar("ModelT", bound=Base)

class BaseRepository(Generic[ModelT]):
    """Generic repository providing standard CRUD operations."""

    def __init__(self, model: Type[ModelT], session: AsyncSession) -> None:
        self.model = model
        self.session = session

    async def get_by_id(self, id: uuid.UUID) -> ModelT | None:
        """Fetch a single record by primary key."""
        result = await self.session.execute(
            select(self.model).where(self.model.id == id)
        )
        return result.scalar_one_or_none()

    async def get_all(self, limit: int = 100, offset: int = 0) -> List[ModelT]:
        """Fetch all records with pagination."""
        result = await self.session.execute(
            select(self.model).limit(limit).offset(offset)
        )
        return list(result.scalars().all())

    async def create(self, instance: ModelT) -> ModelT:
        """Persist a new record."""
        self.session.add(instance)
        await self.session.flush()
        await self.session.refresh(instance)
        return instance

    async def delete(self, instance: ModelT) -> None:
        """Delete a record."""
        await self.session.delete(instance)
        await self.session.flush()
"@
Set-Content -Path "D:\CLAUSEIQ\backend\app\repositories\base.py" -Value $repo_base

# repositories/user.py
$repo_user = @"
"""
User Repository

All database operations for the User model.
No business logic. Only queries.
"""

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.user import User
from app.repositories.base import BaseRepository

class UserRepository(BaseRepository[User]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(User, session)

    async def get_by_email(self, email: str) -> User | None:
        """Fetch a user by email address."""
        result = await self.session.execute(
            select(User).where(User.email == email)
        )
        return result.scalar_one_or_none()

    async def email_exists(self, email: str) -> bool:
        """Check if an email address is already registered."""
        return await self.get_by_email(email) is not None
"@
Set-Content -Path "D:\CLAUSEIQ\backend\app\repositories\user.py" -Value $repo_user

# repositories/document.py
$repo_doc = @"
"""
Document Repository

All database operations for the Document model.
No business logic. Only queries.
"""

import uuid
from typing import List

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.document import Document
from app.repositories.base import BaseRepository

class DocumentRepository(BaseRepository[Document]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(Document, session)

    async def get_by_owner(
        self, owner_id: uuid.UUID, limit: int = 20, offset: int = 0
    ) -> List[Document]:
        """Fetch all documents belonging to a specific user."""
        result = await self.session.execute(
            select(Document)
            .where(Document.owner_id == owner_id)
            .order_by(Document.created_at.desc())
            .limit(limit)
            .offset(offset)
        )
        return list(result.scalars().all())

    async def get_by_status(self, status: str) -> List[Document]:
        """Fetch all documents with a given processing status."""
        result = await self.session.execute(
            select(Document).where(Document.status == status)
        )
        return list(result.scalars().all())
"@
Set-Content -Path "D:\CLAUSEIQ\backend\app\repositories\document.py" -Value $repo_doc

# repositories/__init__.py
$repos_init = @"
"""Repositories package."""

from app.repositories.base import BaseRepository
from app.repositories.user import UserRepository
from app.repositories.document import DocumentRepository

__all__ = ["BaseRepository", "UserRepository", "DocumentRepository"]
"@
Set-Content -Path "D:\CLAUSEIQ\backend\app\repositories\__init__.py" -Value $repos_init

Write-Host "Repositories written."
Write-Host "All models, schemas and repositories complete."