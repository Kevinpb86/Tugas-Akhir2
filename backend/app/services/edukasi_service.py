from datetime import datetime
import numpy as np
import requests
from sqlalchemy.orm import Session

from app.db_models.earthquake import Earthquake
from app.db_models.edukasi import RiskSource
from app.repositories.edukasi_repo import EdukasiRepository
from app.services import ml_service

BMKG_API_URL = "https://data.bmkg.go.id/DataMKG/TEWS/gempadirasakan.json"

class EdukasiService:
    def __init__(self, db: Session):
        self.db = db
        self.repo = EdukasiRepository(db)

    def _get_nearest_risk_source_desc(self, lat: float, lon: float) -> str:
        try:
            sources = self.db.query(RiskSource).all()
            if not sources:
                return "gempa merusak Cianjur M5.6"
                
            nearest_desc = "gempa merusak Cianjur M5.6"
            min_dist = float('inf')
            
            for s in sources:
                dist = ((lat - s.latitude) ** 2 + (lon - s.longitude) ** 2) ** 0.5
                if dist < min_dist:
                    min_dist = dist
                    nearest_desc = s.description
                    
            return nearest_desc
        except Exception as e:
            print(f"Error querying RiskSource: {e}")
            return "gempa merusak Cianjur M5.6"

    def _extract_city_name(self, wilayah: str) -> str:
        """Ekstrak nama kota/wilayah bersih dari deskripsi BMKG."""
        import re
        if not wilayah:
            return "Ciwidey"
        # Hapus awalan seperti "Pusat gempa berada di darat 4 km utara Tanggamus" -> "Tanggamus"
        cleaned = re.sub(r"^.*?\d+\s*km\s*(utara|selatan|barat|timur|tenggara|barat daya|barat laut|timur laut)?\s*", "", wilayah, flags=re.IGNORECASE)
        cleaned = re.sub(r"^(Kabupaten|Kota|Kab\.|Kecamatan|Desa|Kelurahan)\s+", "", cleaned, flags=re.IGNORECASE)
        return cleaned.strip() or wilayah

    def _fetch_latest_bmkg_earthquake(self):
        """Ambil gempa terbaru langsung dari API BMKG (real-time)."""
        try:
            response = requests.get(BMKG_API_URL, timeout=10)
            response.raise_for_status()
            data = response.json()
            
            gempa_list = data.get("Infogempa", {}).get("gempa", [])
            if not gempa_list:
                return None
            
            # Ambil gempa pertama (terbaru)
            latest = gempa_list[0]
            magnitude = round(float(latest.get("Magnitude", 0)), 1)
            depth = round(float(latest.get("Kedalaman", "0 km").replace(" km", "")), 1)
            wilayah = latest.get("Wilayah", "Tidak diketahui")
            tanggal = latest.get("Tanggal", "")
            jam = latest.get("Jam", "")
            city_name = self._extract_city_name(wilayah)
            
            return {
                "magnitude": magnitude,
                "depth": depth,
                "wilayah": wilayah,
                "city_name": city_name,
                "tanggal": tanggal,
                "jam": jam
            }
        except Exception as e:
            print(f"Error fetching from BMKG API: {e}")
            return None

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
        
        if recent_quake and ml_service.rekomendasi_edukasi_model:
            # Menggunakan Model ML (rekomendasi_edukasi.pkl)
            try:
                model = ml_service.rekomendasi_edukasi_model['model']
                scaler = ml_service.rekomendasi_edukasi_model['scaler']
                mapping = ml_service.rekomendasi_edukasi_model['mapping']
                
                mag = recent_quake.magnitude
                depth = recent_quake.depth
                
                # Transform the magnitude: log(1 + mag) * 10.0
                mag_log_berbobot = np.log1p(mag) * 10.0
                
                # Transform the depth log
                depth_log = np.log1p(depth)
                depth_scaled = scaler.transform([[depth_log]])[0][0]
                
                # Model predicts based on mag_log_berbobot and depth_scaled
                features = [[mag_log_berbobot, depth_scaled]]
                cluster = model.predict(features)[0]
                
                mapped_cluster = mapping.get(cluster, cluster)
                
                if mapped_cluster == 2:
                    status = "Bahaya (Merah)"
                    message = f"Terdeteksi gempa aktif {mag} SR (Kedalaman {depth} km) di sekitar Anda yang berpotensi menimbulkan kerusakan langsung."
                elif mapped_cluster == 1:
                    status = "WASPADA (Kuning)"
                    message = f"Terdeteksi gempa aktif {mag} SR (Kedalaman {depth} km) di sekitar Anda. Guncangan berisiko merambat dan memengaruhi kestabilan bangunan."
                else:
                    status = "AMAN (Hijau)"
                    message = f"Terdeteksi gempa aktif {mag} SR (Kedalaman {depth} km) di sekitar Anda dengan potensi dampak guncangan yang sangat lemah."
                    
                return {
                    "status": status,
                    "message": message,
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
                
            ref_desc = self._get_nearest_risk_source_desc(lat, lon)
            
            if mapped_kode == 2:
                status = "Bahaya (Merah)"
                message = f"Pernah terjadi gempa merusak setempat atau berada langsung di jalur sesar aktif utama (seperti {ref_desc})."
            elif mapped_kode == 1:
                status = "WASPADA (Kuning)"
                message = f"Pernah terdampak rambatan guncangan gempa dari daerah sekitar (seperti {ref_desc}) meskipun bukan pusat episentrum."
            else:
                # === ZONA AMAN: Fetch gempa real-time dari API BMKG langsung ===
                # Lalu jalankan melalui model K-Means (rekomendasi_edukasi.pkl)
                if ml_service.rekomendasi_edukasi_model:
                    try:
                        bmkg_data = self._fetch_latest_bmkg_earthquake()
                        
                        if bmkg_data:
                            model = ml_service.rekomendasi_edukasi_model['model']
                            scaler = ml_service.rekomendasi_edukasi_model['scaler']
                            mapping = ml_service.rekomendasi_edukasi_model['mapping']
                            
                            mag = bmkg_data['magnitude']
                            depth = bmkg_data['depth']
                            wilayah = bmkg_data['wilayah']
                            tanggal = bmkg_data['tanggal']
                            jam = bmkg_data['jam']
                            
                            # Transform: log(1 + mag) * 10.0
                            mag_log_berbobot = np.log1p(mag) * 10.0
                            
                            # Transform: log(1 + depth) lalu scale
                            depth_log = np.log1p(depth)
                            depth_scaled = scaler.transform([[depth_log]])[0][0]
                            
                            # Prediksi cluster
                            features = [[mag_log_berbobot, depth_scaled]]
                            cluster = model.predict(features)[0]
                            mapped_cluster = mapping.get(cluster, cluster)
                            
                            if mapped_cluster == 2:
                                status = "Bahaya (Merah)"
                                message = f"Gempa terbaru BMKG: M{mag} SR, Kedalaman {depth} km ({wilayah}, {tanggal} {jam}). Model K-Means memprediksi potensi kerusakan tinggi."
                            elif mapped_cluster == 1:
                                status = "WASPADA (Kuning)"
                                message = f"Gempa terbaru BMKG: M{mag} SR, Kedalaman {depth} km ({wilayah}, {tanggal} {jam}). Model K-Means memprediksi potensi guncangan menengah."
                            else:
                                status = "AMAN (Hijau)"
                                message = f"Gempa terbaru BMKG: M{mag} SR, Kedalaman {depth} km ({wilayah}, {tanggal} {jam}). Model K-Means memprediksi potensi dampak rendah."
                            
                            return {
                                "status": status,
                                "message": message,
                                "data": {
                                    "source": "API BMKG Real-time + Model K-Means (rekomendasi_edukasi.pkl)",
                                    "magnitude": mag,
                                    "depth": depth,
                                    "wilayah": wilayah,
                                    "city_name": bmkg_data.get("city_name", "Tanggamus"),
                                    "tanggal": tanggal,
                                    "jam": jam,
                                    "cluster": int(cluster),
                                    "mapped_cluster": int(mapped_cluster)
                                }
                            }
                    except Exception as e:
                        print(f"Error during BMKG API + K-Means prediction: {e}")
                
                # Fallback jika model tidak tersedia atau gagal
                status = "AMAN (Hijau)"
                message = "Tidak memiliki riwayat kerusakan seismik lokal dan aman dari dampak rambatan guncangan gempa besar di sekitarnya."
                
            return {
                "status": status,
                "message": message,
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


