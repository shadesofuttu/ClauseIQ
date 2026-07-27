"""
ClauseIQ - FastAPI Application Entry Point

This module is the composition root of the application.
It is responsible for:
- Creating the FastAPI application instance
- Registering routers
- Registering middleware
- Registering exception handlers
- Managing application lifespan (startup/shutdown)

Nothing else belongs here.
"""

from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.core.logging import configure_logging
from app.core.exceptions import register_exception_handlers

@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Application lifespan manager.
    Handles startup and shutdown events.
    """
    # Startup
    configure_logging()
    # Future: initialise DB connection pool, load plugin registry, warm caches
    yield
    # Shutdown
    # Future: close DB connections, flush queues

def create_application() -> FastAPI:
    """
    Application factory.
    Returns a fully configured FastAPI instance.
    """
    application = FastAPI(
        title=settings.PROJECT_NAME,
        description=settings.PROJECT_DESCRIPTION,
        version=settings.VERSION,
        docs_url="/api/docs" if settings.ENVIRONMENT != "production" else None,
        redoc_url="/api/redoc" if settings.ENVIRONMENT != "production" else None,
        openapi_url="/api/openapi.json" if settings.ENVIRONMENT != "production" else None,
        lifespan=lifespan,
    )

    # --- Middleware ---
    application.add_middleware(
        CORSMiddleware,
        allow_origins=settings.ALLOWED_ORIGINS,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # --- Exception Handlers ---
    register_exception_handlers(application)

    # --- Routers ---
    # from app.api.v1.routes import router as api_v1_router
    # application.include_router(api_v1_router, prefix="/api/v1")

    return application

app = create_application()

