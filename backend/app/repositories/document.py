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
