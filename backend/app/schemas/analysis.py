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
