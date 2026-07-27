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
