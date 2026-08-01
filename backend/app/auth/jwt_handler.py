from datetime import datetime, timedelta
from jose import JWTError, jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

from app.config.config import JWT_SECRET_KEY, JWT_EXPIRY_MINUTES

ALGORITHM = "HS256"

# Skema Bearer token untuk Swagger UI dan dependency injection
bearer_scheme = HTTPBearer()


def create_access_token(data: dict) -> str:
    """
    Membuat JWT access token.
    
    Parameter data berisi payload seperti:
    {"user_id": 1, "email": "user@mail.com", "full_name": "User"}
    """
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=JWT_EXPIRY_MINUTES)
    to_encode.update({"exp": expire})
    
    encoded_jwt = jwt.encode(to_encode, JWT_SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt


def decode_access_token(token: str) -> dict:
    """
    Mendecode dan memvalidasi JWT token.
    Mengembalikan payload jika valid, raise HTTPException jika tidak.
    """
    try:
        payload = jwt.decode(token, JWT_SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token tidak valid atau sudah kedaluwarsa",
            headers={"WWW-Authenticate": "Bearer"},
        )


def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(bearer_scheme),
) -> dict:
    """
    FastAPI dependency untuk mengekstrak user dari JWT token.
    
    Cara pakai di endpoint:
        @router.get("/protected")
        def protected_route(current_user: dict = Depends(get_current_user)):
            return {"user": current_user}
    """
    token = credentials.credentials
    return decode_access_token(token)
