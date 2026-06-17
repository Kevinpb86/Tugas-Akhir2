from sqlalchemy.orm import Session
from sqlalchemy import func
from app.db_models.earthquake import Earthquake


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