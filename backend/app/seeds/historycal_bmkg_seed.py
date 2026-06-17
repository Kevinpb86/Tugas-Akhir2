import pandas as pd

from app.config.database import SessionLocal
from app.db_models.earthquake import Earthquake
from app.repositories.earthquake_repo import EarthquakeRepository
from app.auth.security import generate_fingerprint


CSV_PATH = "data/df_combined_catalog_for_mysql.csv"


def run_seed():
    db = SessionLocal()
    repo = EarthquakeRepository(db)

    try:
        if repo.count() > 0:
            print("Seed already executed. Skipping...")
            return

        df = pd.read_csv(CSV_PATH)
        df["datetime"] = (pd.to_datetime(df["datetime"], utc=True).dt.tz_localize(None))

        data = []

        for _, row in df.iterrows():

            fingerprint = generate_fingerprint(
                event_time=row["datetime"],
                latitude=float(row["latitude"]),
                longitude=float(row["longitude"]),
                magnitude=float(row["magnitude"]),
                depth=float(row["depth"]),
            )

            data.append(
                Earthquake(
                    event_time=row["datetime"],
                    latitude=row["latitude"],
                    longitude=row["longitude"],
                    depth=row["depth"],
                    magnitude=row["magnitude"],
                    wilayah=row["wilayah"],
                    dirasakan=(
                        row["dirasakan"]
                        if pd.notna(row["dirasakan"])
                        else None
                    ),
                    source=row["source"],
                    status="processed",
                    fingerprint=fingerprint,
                )
            )

        repo.bulk_insert(data)

        print(f"Seed success: {len(data)} records")

    except Exception as e:
        db.rollback()
        print(f"Seed failed: {e}")

    finally:
        db.close()


if __name__ == "__main__":
    run_seed()