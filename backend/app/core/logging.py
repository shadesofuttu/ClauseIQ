"""
Logging Configuration

Structured JSON logging via structlog.
In development: human-readable colored output.
In production: machine-readable JSON for log aggregators (Datadog, CloudWatch, etc).
"""

import logging
import sys

import structlog

from app.core.config import settings

def configure_logging() -> None:
    """
    Configure structured logging for the application.
    Called once at application startup in main.py lifespan.
    """
    shared_processors = [
        structlog.contextvars.merge_contextvars,
        structlog.stdlib.add_logger_name,
        structlog.stdlib.add_log_level,
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.StackInfoRenderer(),
    ]

    if settings.LOG_FORMAT == "json":
        processors = shared_processors + [
            structlog.processors.dict_tracebacks,
            structlog.processors.JSONRenderer(),
        ]
    else:
        processors = shared_processors + [
            structlog.dev.ConsoleRenderer(colors=True),
        ]

    structlog.configure(
        processors=processors,
        wrapper_class=structlog.make_filtering_bound_logger(
            logging.getLevelName(settings.LOG_LEVEL)
        ),
        context_class=dict,
        logger_factory=structlog.PrintLoggerFactory(sys.stdout),
        cache_logger_on_first_use=True,
    )

    # Suppress noisy third-party loggers in production
    if settings.ENVIRONMENT == "production":
        logging.getLogger("uvicorn.access").setLevel(logging.WARNING)

def get_logger(name: str = __name__) -> structlog.BoundLogger:
    """Return a bound logger for use in any module."""
    return structlog.get_logger(name)
