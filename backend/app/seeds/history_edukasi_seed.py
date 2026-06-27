import pandas as pd
from app.config.database import SessionLocal
from app.db_models.edukasi import ZonaGPS

# Sesuaikan lokasi file CSV jika berbeda
CSV_PATH = "data/Database_Zona_GPS_.csv"

def run_seed():
    db = SessionLocal()

    try:
        # Cek apakah data sudah pernah di-seed agar tidak duplikat
        if db.query(ZonaGPS).count() > 0:
            print("Seed already executed. Skipping...")
            return
        
        print(f"Membaca data dari {CSV_PATH}...")
        df = pd.read_csv(CSV_PATH)
        
        processed = 0

        # Iterasi setiap baris di data CSV
        for _, row in df.iterrows():
            
            # Memasukkan data dari CSV ke objek model ZonaGPS
            zona = ZonaGPS(
                lat_grid=float(row["Lat_Grid"]),
                lon_grid=float(row["Lon_Grid"]),
                kode_klaster=str(row["Kode_Klaster"]),
            )
            
            db.add(zona)
            processed += 1
            
            # Log progress untuk memberi tahu user proses sedang berjalan
            if processed % 1000 == 0:
                print(f"Processed {processed}/{len(df)}")
                
        # Commit perubahan ke database setelah loop selesai (bulk insert manual)
        db.commit()
        
        print(f"Seed success: {processed} records dimasukkan ke database.")

    except Exception as e:
        # Jika terjadi error (misalnya tipe data salah, kolom tidak ditemukan), batalkan (rollback)
        db.rollback()
        print(f"Seed failed: {e}")

    finally:
        # Tutup koneksi agar tidak memory leak
        db.close()


if __name__ == "__main__":
    run_seed()
