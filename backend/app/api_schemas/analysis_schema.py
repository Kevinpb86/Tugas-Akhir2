from datetime import datetime
from typing import List, Optional

from pydantic import BaseModel


class EarthquakeMapNode(BaseModel):
    id: int
    event_time: datetime

    latitude: float
    longitude: float
    depth: float
    magnitude: float

    wilayah: Optional[str]
    dirasakan: Optional[str]

    prediction: Optional[str]
    probability: Optional[float]


class InfluenceZoneNode(BaseModel):
    earthquake_id: int

    latitude: float
    longitude: float
    magnitude: float

    radius_km: float
    window_days: int

    start_time: datetime
    end_time: datetime


class MapResponse(BaseModel):
    earthquakes: List[EarthquakeMapNode]
    influence_zones: List[InfluenceZoneNode]