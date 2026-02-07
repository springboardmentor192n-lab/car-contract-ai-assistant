from datetime import datetime, timedelta, timezone
from typing import Optional, Annotated

from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from passlib.context import CryptContext
from sqlalchemy.ext.asyncio import AsyncSession

from backend.config import settings
from backend.database import get_db
from backend.models import schemas
from backend import crud

# --- Configuration ---

# Password Hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# JWT
ALGORITHM = "HS256"
# This defines the URL that clients will use to get a token.
# It points to the 'login_for_access_token' function in the user router.
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/users/token")


# --- Password Utilities ---

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verifies a plain password against a hashed one."""
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password: str) -> str:
    """Hashes a plain password."""
    return pwd_context.hash(password)


# --- JWT Token Utilities ---

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    """Creates a new JWT access token."""
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        # Use expiration from settings, with a fallback
        expire_minutes = getattr(settings, 'ACCESS_TOKEN_EXPIRE_MINUTES', 30)
        expire = datetime.now(timezone.utc) + timedelta(minutes=expire_minutes)
    
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt


# --- Core Authentication Dependency ---

async def get_current_user(
    token: Annotated[str, Depends(oauth2_scheme)], 
    db: Annotated[AsyncSession, Depends(get_db)]
) -> schemas.User:
    """
    Dependency to get the current user from a JWT token.

    - Decodes the token.
    - Validates the token data.
    - Fetches the user from the database.
    - Raises HTTPException for any errors.
    """
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[ALGORITHM])
        username: Optional[str] = payload.get("sub")
        if username is None:
            raise credentials_exception
        # We can add more token validation here (e.g., token type, scope)
        token_data = schemas.TokenData(username=username)
    except JWTError:
        raise credentials_exception
    
    user = await crud.get_user_by_username(db, username=token_data.username)
    if user is None:
        raise credentials_exception
        
    # FastAPI automatically handles the conversion from ORM model to Pydantic
    # model when a response_model is used. Here we return the full user object
    # from the database, and the route will return the Pydantic 'schemas.User'.
    return user
