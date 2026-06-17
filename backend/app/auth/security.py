from passlib.context import CryptContext
import hashlib

# hashing password security for user
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

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