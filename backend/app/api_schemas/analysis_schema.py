from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel


class NetworkNode(BaseModel):
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


class NetworkEdge(BaseModel):
    source: int
    target: int


class NetworkResponse(BaseModel):
    nodes: List[NetworkNode]
    edges: List[NetworkEdge]