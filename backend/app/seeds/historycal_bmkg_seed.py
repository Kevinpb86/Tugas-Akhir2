import pandas as pd

from app.auth.security import generate_fingerprint
from app.config.database import SessionLocal
from app.db_models.earthquake import Earthquake
from app.db_models.seismic_analysis import SeismicAnalysis
from app.repositories.earthquake_repo import EarthquakeRepository
from app.services.extarct_features import NNDService
from app.utils.time_utils import datetime_to_datenum


CSV_PATH = "data/historical_data_bmkg_2021-2026.csv"
MC = 4.7


def run_seed():
    db = SessionLocal()
    repo = EarthquakeRepository(db)
    nnd_service = NNDService(db)

    try:
        if repo.count() > 0:
            print("Seed already executed. Skipping...")
            return

        df = pd.read_csv(CSV_PATH)

        df["datetime"] = (
            pd.to_datetime(df["datetime"], utc=True)
            .dt.tz_localize(None)
        )

        df = df.sort_values("datetime").reset_index(drop=True)

        processed = 0

        for _, row in df.iterrows():

            fingerprint = generate_fingerprint(
                event_time=row["datetime"],
                latitude=float(row["latitude"]),
                longitude=float(row["longitude"]),
                magnitude=float(row["magnitude"]),
                depth=float(row["depth"]),
            )

            earthquake = Earthquake(
                event_time=row["datetime"],
                time=datetime_to_datenum(row["datetime"]),
                latitude=float(row["latitude"]),
                longitude=float(row["longitude"]),
                depth=float(row["depth"]),
                magnitude=float(row["magnitude"]),
                wilayah=row["wilayah"],
                dirasakan=(
                    row["dirasakan"]
                    if pd.notna(row["dirasakan"])
                    else None
                ),
                source=row["source"],
                status="pending",
                fingerprint=fingerprint,
            )

            db.add(earthquake)

            # supaya earthquake.id tersedia
            db.flush()

            # hitung NND terhadap event historis sebelumnya
            nnd_result = None

            if earthquake.magnitude >= MC:
                nnd_result = nnd_service.compute(earthquake, mc=MC)

            if nnd_result is not None:

                analysis = SeismicAnalysis(
                    earthquake_id=earthquake.id,
                    parent_earthquake_id=nnd_result["parent_earthquake_id"],
                    n_value=nnd_result["N+"],
                    log_n=nnd_result["log_N+"],
                    log_t=nnd_result["log_T+"],
                    log_r=nnd_result["log_R+"],
                    dm=nnd_result["dm+"],
                )

                db.add(analysis)

                if earthquake.magnitude < MC:
                    earthquake.status = "below_mc"

                elif nnd_result is not None:
                    earthquake.status = "processed"

                else:
                    earthquake.status = "processed"

            processed += 1

            if processed % 100 == 0:
                print(f"Processed {processed}/{len(df)}")

        db.commit()

        print(f"Seed success: {processed} records")

    except Exception as e:
        db.rollback()
        print(f"Seed failed: {e}")

    finally:
        db.close()


if __name__ == "__main__":
    run_seed()