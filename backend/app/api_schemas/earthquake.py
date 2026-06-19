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
    magnitude: float
    depth: float
    latitude: float
    longitude: float

