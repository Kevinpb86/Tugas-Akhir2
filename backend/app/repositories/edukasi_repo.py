from sqlalchemy.orm import Session
from app.db_models.earthquake import Earthquake

class EdukasiRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_edukasi_data(self, limit: int = 1, offset: int = 0):
        """
        Mengambil data spesifik (latitude, longitude, magnitude, dan depth) 
        dari tabel earthquakes untuk keperluan edukasi.
        """
        return (
            self.db.query(
                Earthquake.latitude,
                Earthquake.longitude,
                Earthquake.magnitude,
                Earthquake.depth
            )
            .order_by(Earthquake.event_time.desc())
            .offset(offset)
            .limit(limit)
            .all()
        )
