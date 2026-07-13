from datetime import datetime, timedelta

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.config.database import get_db

from app.db_models.earthquake import Earthquake
from app.db_models.seismic_analysis import SeismicAnalysis
from app.db_models.influence_zones import InfluenceZone

from app.api_schemas.analysis_schema import (
    MapResponse,
    EarthquakeMapNode,
    InfluenceZoneNode,
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
        datetime.utcnow() -
        timedelta(days=days)
    )

    # ==================================================
    # EARTHQUAKE MARKERS
    # ==================================================

    rows = (
        db.query(
            Earthquake,
            SeismicAnalysis
        )
        .outerjoin(
            SeismicAnalysis,
            SeismicAnalysis.earthquake_id ==
            Earthquake.id
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

    # ==================================================
    # ACTIVE INFLUENCE ZONES
    # ==================================================

    zone_rows = (
        db.query(
            InfluenceZone,
            Earthquake
        )
        .join(
            Earthquake,
            InfluenceZone.earthquake_id ==
            Earthquake.id
        )
        .filter(
            InfluenceZone.end_time >=
            datetime.utcnow()
        )
        .all()
    )

    influence_zones = []

    for zone, eq in zone_rows:

        influence_zones.append(
            InfluenceZoneNode(
                earthquake_id=eq.id,

                latitude=eq.latitude,
                longitude=eq.longitude,
                magnitude=eq.magnitude,

                radius_km=zone.radius_km,
                window_days=zone.window_days,

                start_time=zone.start_time,
                end_time=zone.end_time,
            )
        )

    return MapResponse(
        earthquakes=earthquakes,
        influence_zones=influence_zones,
    )