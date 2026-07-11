import sys
sys.path.append("c:/Semester 8/Tugas-Akhir2/backend")
from app.config.database import SessionLocal
from app.db_models.edukasi import RiskSource

def run_seed():
    db = SessionLocal()
    
    # 25+ major active faults and historic earthquakes in Indonesia
    sources = [
        # Jawa Barat
        {"name": "Cianjur", "description": "gempa merusak Cianjur M5.6", "latitude": -6.82, "longitude": 107.14},
        {"name": "Cikarang", "description": "gempa sesar Cipamingkis Cikarang", "latitude": -6.36, "longitude": 107.17},
        {"name": "Lembang", "description": "rambatan gempa Cianjur M5.6, Sumedang M4.8 & Sukabumi M5.8", "latitude": -6.82, "longitude": 107.62},
        {"name": "Garut", "description": "gempa sesar Garsela Garut", "latitude": -7.31, "longitude": 107.75},
        
        # Jawa Tengah & Yogyakarta
        {"name": "Yogyakarta", "description": "gempa merusak Yogyakarta M5.9 (Sesar Opak)", "latitude": -7.9, "longitude": 110.45},
        {"name": "Pekalongan", "description": "aktivitas sesar aktif Pekalongan", "latitude": -6.9, "longitude": 109.67},
        {"name": "Semarang", "description": "aktivitas sesar aktif Semarang/Kendeng", "latitude": -7.0, "longitude": 110.4},
        
        # Jawa Timur
        {"name": "Malang", "description": "gempa selatan Jawa Timur M6.1", "latitude": -8.4, "longitude": 112.5},
        {"name": "Surabaya", "description": "aktivitas zona sesar aktif Kendeng", "latitude": -7.3, "longitude": 112.7},
        
        # Bali, NTB, NTT
        {"name": "Lombok", "description": "gempa merusak Lombok M7.0", "latitude": -8.3, "longitude": 116.2},
        {"name": "Kupang", "description": "aktivitas sesar aktif Kupang", "latitude": -10.17, "longitude": 123.6},
        
        # Sumatera
        {"name": "Banda Aceh", "description": "gempa megathrust & tsunami Aceh M9.1", "latitude": 5.5, "longitude": 95.3},
        {"name": "Nias", "description": "gempa merusak Nias-Simeulue M8.6", "latitude": 1.3, "longitude": 97.6},
        {"name": "Padang", "description": "gempa merusak Padang M7.6", "latitude": -0.95, "longitude": 100.35},
        {"name": "Mentawai", "description": "aktivitas zona subduksi Megathrust Mentawai", "latitude": -2.0, "longitude": 99.0},
        {"name": "Bengkulu", "description": "gempa besar Bengkulu M8.4", "latitude": -3.8, "longitude": 102.26},
        {"name": "Liwa", "description": "aktivitas sesar Semangko di Liwa", "latitude": -5.0, "longitude": 104.0},
        
        # Sulawesi
        {"name": "Palu", "description": "gempa & tsunami Palu-Donggala M7.4 (Sesar Palu-Koro)", "latitude": -0.9, "longitude": 119.8},
        {"name": "Majene", "description": "gempa merusak Majene M6.2", "latitude": -3.0, "longitude": 118.9},
        {"name": "Soroako", "description": "aktivitas sesar aktif Matano Soroako", "latitude": -2.5, "longitude": 121.3},
        {"name": "Manado", "description": "gempa subduksi Laut Maluku", "latitude": 1.48, "longitude": 124.8},
        
        # Kalimantan
        {"name": "Tarakan", "description": "gempa merusak Tarakan M6.1 (Sesar Tarakan)", "latitude": 3.3, "longitude": 117.6},
        {"name": "Meratus", "description": "aktivitas sesar aktif Meratus", "latitude": -3.0, "longitude": 115.5},
        
        # Maluku & Papua
        {"name": "Ambon", "description": "gempa merusak Ambon M6.5", "latitude": -3.7, "longitude": 128.18},
        {"name": "Banda", "description": "gempa megathrust Laut Banda M8.0", "latitude": -4.5, "longitude": 129.9},
        {"name": "Sorong", "description": "aktivitas sesar aktif Sorong", "latitude": -0.8, "longitude": 131.25},
        {"name": "Biak", "description": "gempa bumi & tsunami Biak M8.2", "latitude": -1.0, "longitude": 136.0},
        {"name": "Jayapura", "description": "gempa merusak Jayapura M5.4", "latitude": -2.5, "longitude": 140.7}
    ]
    
    try:
        # Clear old records
        db.query(RiskSource).delete()
        db.commit()
        
        print("Clearing old risk sources...")
        
        for item in sources:
            src = RiskSource(
                name=item["name"],
                description=item["description"],
                latitude=item["latitude"],
                longitude=item["longitude"]
            )
            db.add(src)
            
        db.commit()
        print(f"Success seeded {len(sources)} risk sources into table risk_sources.")
        
    except Exception as e:
        db.rollback()
        print(f"Seed failed: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    run_seed()
