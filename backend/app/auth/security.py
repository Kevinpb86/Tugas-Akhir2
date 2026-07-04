from passlib.context import CryptContext
import hashlib

# hashing password security for user
pwd_context = CryptContext(schemes=["pbkdf2_sha256", "bcrypt"], deprecated="auto")
fallback_context = CryptContext(schemes=["pbkdf2_sha256"], deprecated="auto")


def validate_password(password: str) -> None:
    if not isinstance(password, str):
        raise ValueError("Password harus berupa teks")

    if not password:
        raise ValueError("Password tidak boleh kosong")

    if len(password.encode("utf-8")) > 72:
        raise ValueError("Password maksimal 72 karakter")


def hash_password(password: str) -> str:
    validate_password(password)
    try:
        return pwd_context.hash(password)
    except Exception:
        return fallback_context.hash(password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    validate_password(plain_password)
    try:
        return pwd_context.verify(plain_password, hashed_password)
    except Exception:
        return fallback_context.verify(plain_password, hashed_password)


# fingerprint for unique index earthquake data 
def generate_fingerprint(
    event_time,
    latitude: float,
    longitude: float,
    magnitude: float,
    depth: float,
) -> str:
    payload = (
        f"{event_time.isoformat()}|"
        f"{latitude:.3f}|"
        f"{longitude:.3f}|"
        f"{magnitude:.1f}|"
        f"{depth:.1f}"
    )

    return hashlib.sha1(payload.encode("utf-8")).hexdigest()

