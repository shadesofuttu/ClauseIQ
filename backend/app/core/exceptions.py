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
