from sqlalchemy.orm import Session
from datetime import datetime, timedelta

from app.db_models.earthquake import Earthquake
from app.db_models.seismic_analysis import SeismicAnalysis


class SeismicAnalysisRepository:

    def __init__(self, db: Session):
        self.db = db

    def get_network(self, days: int):

        start_time = datetime.utcnow() - timedelta(days=days)

        rows = (
            self.db.query(Earthquake, SeismicAnalysis)
            .join(
                SeismicAnalysis,
                SeismicAnalysis.earthquake_id == Earthquake.id,
                isouter=True
            )
            .filter(Earthquake.event_time >= start_time)
            .all()
        )

        return rows