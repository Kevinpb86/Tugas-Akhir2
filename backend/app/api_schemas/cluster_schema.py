from pydantic import BaseModel


class ClusterChildResponse(BaseModel):
    earthquake_id: int
    prediction: str | None
    probability: float | None


class ClusterResponse(BaseModel):
    parent_id: int
    children: list[ClusterChildResponse]