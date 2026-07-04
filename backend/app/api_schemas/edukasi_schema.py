from pydantic import BaseModel
from typing import Optional

class EdukasiRequest(BaseModel):
    latitude: float
    longitude: float

class EdukasiResponse(BaseModel):
    status: str
    message: str
    data: Optional[dict] = None
