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
