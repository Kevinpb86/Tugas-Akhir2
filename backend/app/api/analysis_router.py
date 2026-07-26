from datetime import datetime, timedelta

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.config.database import get_db

from app.db_models.earthquake import Earthquake
from app.db_models.seismic_analysis import SeismicAnalysis

from app.api_schemas.analysis_schema import (
    MapResponse,
    EarthquakeMapNode,
)


router = APIRouter(
    prefix="/earthquakes",
    tags=["Analysis"],
)


@router.get(
    "/map",
    response_model=MapResponse,
)
def get_map(
    days: int = 30,
    db: Session = Depends(get_db),
):

    cutoff = (
        datetime.utcnow()
        - timedelta(days=days)
    )


    rows = (
        db.query(
            Earthquake,
            SeismicAnalysis
        )
        .outerjoin(
            SeismicAnalysis,
            SeismicAnalysis.earthquake_id
            == Earthquake.id
        )
        .filter(
            Earthquake.event_time >= cutoff
        )
        .order_by(
            Earthquake.event_time.asc()
        )
        .all()
    )


    earthquakes = []

    for eq, analysis in rows:

        earthquakes.append(
            EarthquakeMapNode(
                id=eq.id,
                event_time=eq.event_time,

                latitude=eq.latitude,
                longitude=eq.longitude,

                depth=eq.depth,
                magnitude=eq.magnitude,

                wilayah=eq.wilayah,
                dirasakan=eq.dirasakan,

                prediction=(
                    analysis.prediction
                    if analysis
                    else None
                ),

                probability=(
                    analysis.probability
                    if analysis
                    else None
                ),
            )
        )


    return MapResponse(
        earthquakes=earthquakes,
    )