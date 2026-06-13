from pydantic import BaseModel, EmailStr
from typing import Optional

class UserRegister(BaseModel):
    full_name: str
    email: EmailStr
    password: str

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class EarthquakeData(BaseModel):
    magnitude: float
    depth: float
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    location_name: Optional[str] = None
    source: str = "bmkg" # Bisa 'bmkg' atau 'usgs'

class AnomaliData(BaseModel):
    latitude: float
    longitude: float
    depth: float
    gap: float
    dmin: float
    nst: float
    bulan: int
    jam: int

class GoogleAuthRequest(BaseModel):
    email: str
    full_name: str
    google_id: str

class FacebookAuthRequest(BaseModel):
    access_token: str

class ForgotPasswordRequest(BaseModel):
    email: EmailStr
