from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.config.database import get_db

from app.repositories.seismic_analysis_repo import (
    SeismicAnalysisRepository,
)

from app.api_schemas.analysis_schema import (
    AnalysisResponse,
)

router = APIRouter(
    prefix="/earthquakes",
    tags=["Analysis"],
)


@router.get(
    "/{earthquake_id}/analysis",
    response_model=AnalysisResponse,
)
def get_analysis(
    earthquake_id: int,
    db: Session = Depends(get_db),
):
    repo = SeismicAnalysisRepository(db)

    analysis = repo.get_by_earthquake_id(
        earthquake_id
    )

    if not analysis:
        raise HTTPException(
            status_code=404,
            detail="Analysis not found",
        )

    return analysis