from datetime import timedelta

from sqlalchemy.orm import Session

from app.db_models.influence_zones import InfluenceZone
from app.db_models.earthquake import Earthquake
from app.db_models.seismic_analysis import SeismicAnalysis


class InfluenceZoneService:

    GK_WINDOWS = [
        (8.0, 94, 985),
        (7.0, 81, 960),
        (6.5, 61, 790),
        (6.0, 54, 510),
        (5.5, 47, 290),
        (5.0, 40, 155),
        (4.0, 30, 42),
        (3.5, 26, 22),
        (3.0, 22.5, 11.5),
        (2.5, 19.5, 6),
    ]

    def __init__(self, db: Session):
        self.db = db

    # ==================================================
    # GK WINDOW LOOKUP
    # ==================================================

    def get_gk_window(
        self,
        magnitude: float
    ) -> tuple[float, int]:

        for min_mag, radius, days in self.GK_WINDOWS:
            if magnitude >= min_mag:
                return radius, days

        return 19.5, 6

    # ==================================================
    # CREATE INFLUENCE ZONE
    # ==================================================

    def create_if_background(
        self,
        earthquake: Earthquake,
        analysis: SeismicAnalysis,
    ) -> InfluenceZone | None:

        if analysis.prediction != "Background Event":
            return None

        radius_km, window_days = self.get_gk_window(
            earthquake.magnitude
        )

        existing = (
            self.db.query(InfluenceZone)
            .filter(
                InfluenceZone.earthquake_id == earthquake.id
            )
            .first()
        )

        if existing:
            return existing

        zone = InfluenceZone(
            earthquake_id=earthquake.id,
            radius_km=radius_km,
            window_days=window_days,
            start_time=earthquake.event_time,
            end_time=(
                earthquake.event_time +
                timedelta(days=window_days)
            )
        )

        self.db.add(zone)
        self.db.commit()
        self.db.refresh(zone)

        return zone