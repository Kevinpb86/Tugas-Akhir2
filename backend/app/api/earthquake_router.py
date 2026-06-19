from fastapi import APIRouter, Depends, Query, HTTPException
from sqlalchemy.orm import Session

from app.config.database import get_db

from app.repositories.earthquake_repo import (
    EarthquakeRepository,
)

from app.api_schemas.earthquake_schema import (
    EarthquakeListResponse,
    EarthquakeDetailResponse,
)

router = APIRouter(
    prefix="/earthquakes",
    tags=["Earthquakes"],
)


@router.get(
    "",
    response_model=list[EarthquakeListResponse],
)
def get_earthquakes(
    limit: int = Query(20, le=100),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db),
):
    repo = EarthquakeRepository(db)

    rows = repo.get_all(
        limit=limit,
        offset=offset,
    )

    result = []

    for eq, prediction, probability in rows:

        result.append(
            EarthquakeListResponse(
                id=eq.id,
                event_time=eq.event_time,
                latitude=eq.latitude,
                longitude=eq.longitude,
                depth=eq.depth,
                magnitude=eq.magnitude,
                wilayah=eq.wilayah,
                prediction=prediction,
                probability=probability,
            )
        )

    return result


@router.get(
    "/{earthquake_id}",
    response_model=EarthquakeDetailResponse,
)
def get_earthquake_detail(
    earthquake_id: int,
    db: Session = Depends(get_db),
):
    repo = EarthquakeRepository(db)

    earthquake = repo.get_by_id(
        earthquake_id
    )

    if not earthquake:
        raise HTTPException(
            status_code=404,
            detail="Earthquake not found",
        )

    return earthquake