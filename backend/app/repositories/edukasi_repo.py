from sqlalchemy.orm import Session
from sqlalchemy import func
from app.db_models.earthquake import Earthquake
from app.db_models.edukasi import ZonaGPS

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

    def get_nearest_zona_gps(self, lat: float, lon: float):
        # Calculate Euclidean distance squared
        distance_expr = func.power(ZonaGPS.lat_grid - lat, 2) + func.power(ZonaGPS.lon_grid - lon, 2)
        nearest = self.db.query(ZonaGPS).order_by(distance_expr.asc()).first()
        return nearest
