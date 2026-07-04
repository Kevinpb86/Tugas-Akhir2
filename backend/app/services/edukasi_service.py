from datetime import datetime
import numpy as np
from sqlalchemy.orm import Session

from app.db_models.earthquake import Earthquake
from app.repositories.edukasi_repo import EdukasiRepository
from app.services.ml_service import rekomendasi_edukasi_model

class EdukasiService:
    def __init__(self, db: Session):
        self.db = db
        self.repo = EdukasiRepository(db)

    def get_edukasi_status(self, lat: float, lon: float):
        # 1. Check if there's an earthquake today near the location (approx 1 degree = ~111km)
        today_start = datetime.utcnow().replace(hour=0, minute=0, second=0, microsecond=0)
        
        lat_min, lat_max = lat - 1.0, lat + 1.0
        lon_min, lon_max = lon - 1.0, lon + 1.0
        
        recent_quake = self.db.query(
            Earthquake.id, 
            Earthquake.magnitude, 
            Earthquake.depth
        ).filter(
            Earthquake.event_time >= today_start,
            Earthquake.latitude >= lat_min,
            Earthquake.latitude <= lat_max,
            Earthquake.longitude >= lon_min,
            Earthquake.longitude <= lon_max
        ).order_by(Earthquake.event_time.desc()).first()
        
        if recent_quake and rekomendasi_edukasi_model:
            # Menggunakan Model ML (rekomendasi_edukasi.pkl)
            try:
                model = rekomendasi_edukasi_model['model']
                scaler = rekomendasi_edukasi_model['scaler']
                mapping = rekomendasi_edukasi_model['mapping']
                
                mag = recent_quake.magnitude
                depth = recent_quake.depth
                
                # Transform the depth log
                depth_log = np.log1p(depth)
                depth_scaled = scaler.transform([[depth_log]])[0][0]
                
                # Model predicts based on mag and depth_scaled
                features = [[mag, depth_scaled]]
                cluster = model.predict(features)[0]
                
                mapped_cluster = mapping.get(cluster, cluster)
                
                if mapped_cluster == 2:
                    status = "Bahaya (Merah)"
                elif mapped_cluster == 1:
                    status = "WASPADA (Kuning)"
                else:
                    status = "AMAN (Hijau)"
                    
                return {
                    "status": status,
                    "message": f"Peringatan: Ditemukan gempa {mag} SR hari ini di sekitar Anda.",
                    "data": {
                        "source": "BMKG Real-time",
                        "earthquake_id": recent_quake.id,
                        "magnitude": mag,
                        "depth": depth
                    }
                }
            except Exception as e:
                print(f"Error during ML prediction: {e}")
                # Fallback to CSV below if ML fails
                pass
                
        # 2. Fallback to CSV Database (ZonaGPS)
        nearest = self.repo.get_nearest_zona_gps(lat, lon)
        if nearest:
            try:
                # Karena database ZonaGPS akan disimpan secara logis: 0 = Aman, 1 = Waspada, 2 = Bahaya
                mapped_kode = int(nearest.kode_klaster)
            except Exception:
                mapped_kode = 0
                
            if mapped_kode == 2:
                status = "Bahaya (Merah)"
            elif mapped_kode == 1:
                status = "WASPADA (Kuning)"
            else:
                status = "AMAN (Hijau)"
                
            return {
                "status": status,
                "message": "Kondisi saat ini aman (tidak ada gempa real-time hari ini). Status area didasarkan pada data historis.",
                "data": {
                    "source": "Database CSV (ZonaGPS)",
                    "lat_grid": nearest.lat_grid,
                    "lon_grid": nearest.lon_grid
                }
            }
            
        return {
            "status": "Unknown",
            "message": "Lokasi tidak ditemukan di database zona.",
            "data": None
        }
