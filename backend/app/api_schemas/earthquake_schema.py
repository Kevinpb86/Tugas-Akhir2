from datetime import datetime

from pydantic import BaseModel


class EarthquakeListResponse(BaseModel):
    id: int
    event_time: datetime
    latitude: float
    longitude: float
    depth: float
    magnitude: float
    wilayah: str | None

    prediction: str | None
    probability: float | None

    class Config:
        from_attributes = True


class EarthquakeDetailResponse(BaseModel):
    id: int
    event_time: datetime
    latitude: float
    longitude: float
    depth: float
    magnitude: float

    wilayah: str | None
    dirasakan: str | None
    source: str
    status: str

    class Config:
        from_attributes = True