from sqlalchemy.orm import Session
from sqlalchemy import func , and_
from app.db_models.earthquake import Earthquake

from sqlalchemy.orm import joinedload

from app.db_models.earthquake import Earthquake
from app.db_models.seismic_analysis import SeismicAnalysis
class EarthquakeRepository:

    def __init__(self, db: Session):
        self.db = db

    def bulk_insert(self, data: list[Earthquake]):
        self.db.add_all(data)
        self.db.commit()

    def exists(self, event_time, lat, lon):
        return (
            self.db.query(Earthquake)
            .filter(
                Earthquake.event_time == event_time,
                Earthquake.latitude == lat,
                Earthquake.longitude == lon
            )
            .first()
        )
    
    def count(self) -> int:
        return self.db.query(func.count(Earthquake.id)).scalar()
    
    def fingerprint_exists(self, fingerprint: str) -> bool:
        return self.db.query(Earthquake.id).filter(
            Earthquake.fingerprint == fingerprint
        ).first() is not None
    
    def get_event(self, time, latitude, longitude, magnitude):
        return (
            self.db.query(Earthquake).where(case(Earthquake.status == "Pending"))
        )
    
    def get_all(
        self,
        limit: int = 20,
        offset: int = 0,
    ):
        return (
            self.db.query(
                Earthquake,
                SeismicAnalysis.prediction,
                SeismicAnalysis.probability,
            )
            .outerjoin(
                SeismicAnalysis,
                SeismicAnalysis.earthquake_id == Earthquake.id,
            )
            .order_by(Earthquake.event_time.desc())
            .offset(offset)
            .limit(limit)
            .all()
        )


    def get_by_id(self, earthquake_id: int):
        return (
            self.db.query(Earthquake)
            .filter(Earthquake.id == earthquake_id)
            .first()
        )
    