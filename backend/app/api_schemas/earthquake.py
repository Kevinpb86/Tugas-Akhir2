from pydantic import BaseModel, EmailStr
from typing import Optional

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

