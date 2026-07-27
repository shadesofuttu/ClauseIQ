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
