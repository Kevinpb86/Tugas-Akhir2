from datetime import datetime

from pydantic import BaseModel


class AnalysisResponse(BaseModel):
    earthquake_id: int

    parent_earthquake_id: int | None

    n_value: float | None

    log_n: float | None
    log_t: float | None
    log_r: float | None

    dm: float | None

    prediction: str | None
    probability: float | None

    created_at: datetime

    class Config:
        from_attributes = True