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
