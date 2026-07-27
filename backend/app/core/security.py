"""
Security Utilities

Handles:
- Password hashing and verification
- JWT token creation and decoding

This module is a utility layer only.
It does not handle HTTP requests or FastAPI dependencies.
Those belong in api/v1/dependencies/.
"""

from datetime import datetime, timedelta, timezone

from jose import JWTError, jwt
from passlib.context import CryptContext

from app.core.config import settings
from app.core.exceptions import AuthenticationError, TokenExpiredError

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    """Hash a plain-text password."""
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify a plain-text password against a hashed password."""
    return pwd_context.verify(plain_password, hashed_password)

def create_access_token(subject: str) -> str:
    """
    Create a signed JWT access token.

    Args:
        subject: The user identifier (typically user ID as string).

    Returns:
        A signed JWT string.
    """
    expire = datetime.now(timezone.utc) + timedelta(
        minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES
    )
    payload = {"sub": subject, "exp": expire}
    return jwt.encode(payload, settings.SECRET_KEY, algorithm=settings.ALGORITHM)

def decode_access_token(token: str) -> str:
    """
    Decode and validate a JWT access token.

    Args:
        token: The JWT string to decode.

    Returns:
        The subject (user ID) from the token.

    Raises:
        TokenExpiredError: If the token has expired.
        AuthenticationError: If the token is invalid.
    """
    try:
        payload = jwt.decode(
            token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM]
        )
        subject: str | None = payload.get("sub")
        if subject is None:
            raise AuthenticationError("Token missing subject.")
        return subject
    except JWTError as e:
        if "expired" in str(e).lower():
            raise TokenExpiredError()
        raise AuthenticationError("Invalid token.")
