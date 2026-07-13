import pandas as pd

from app.auth.security import generate_fingerprint
from app.config.database import SessionLocal

from app.db_models.earthquake import Earthquake
from app.db_models.seismic_analysis import SeismicAnalysis

from app.services.extarct_features import NNDService
from app.services.rf_service import MLService
from app.services.influence_zones_service import (
    InfluenceZoneService
)

from app.utils.time_utils import (
    datetime_to_datenum
)

CSV_PATH = "data/prediction_data_bmkg.csv"

MC = 4.7


def run_prediction_seed():

    db = SessionLocal()

    nnd_service = NNDService(db)
    ml_service = MLService()
    influence_service = InfluenceZoneService(db)

    try:

        # ==========================================
        # LOAD DATA
        # ==========================================

        df = pd.read_csv(CSV_PATH)

        df["datetime"] = (
            pd.to_datetime(
                df["datetime"],
                utc=True
            )
            .dt.tz_localize(None)
        )

        df = (
            df.sort_values("datetime")
            .reset_index(drop=True)
        )

        processed = 0

        # ==========================================
        # PROCESS EACH EVENT
        # ==========================================

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
                time=datetime_to_datenum(
                    row["datetime"]
                ),
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

            # supaya event sekarang bisa
            # dipakai sebagai parent event
            db.flush()

            nnd_result = None

            # ======================================
            # NND FEATURE EXTRACTION
            # ======================================

            if earthquake.magnitude >= MC:

                nnd_result = nnd_service.compute(
                    earthquake,
                    mc=MC
                )

            # ======================================
            # RF PREDICTION
            # ======================================

            if nnd_result:

                prediction_result = (
                    ml_service.predict(
                        log_n=nnd_result["log_N+"],
                        log_t=nnd_result["log_T+"],
                        log_r=nnd_result["log_R+"],
                        dm=nnd_result["dm+"],
                    )
                )

                analysis = SeismicAnalysis(
                    earthquake_id=earthquake.id,

                    parent_earthquake_id=
                    nnd_result[
                        "parent_earthquake_id"
                    ],

                    n_value=nnd_result["N+"],

                    log_n=nnd_result["log_N+"],
                    log_t=nnd_result["log_T+"],
                    log_r=nnd_result["log_R+"],

                    dm=nnd_result["dm+"],

                    prediction=
                    prediction_result[
                        "prediction"
                    ],

                    probability=
                    prediction_result[
                        "probability"
                    ],
                )

                db.add(analysis)

                # analysis.id tersedia
                db.flush()

                # ==========================
                # CREATE INFLUENCE ZONE
                # ==========================

                influence_service.create_if_background(
                    earthquake=earthquake,
                    analysis=analysis,
                )

                earthquake.status = "processed"

            else:

                earthquake.status = "below_mc"

            processed += 1

            if processed % 100 == 0:
                print(
                    f"Processed "
                    f"{processed}/{len(df)}"
                )

        # ==========================================
        # COMMIT ALL
        # ==========================================

        db.commit()

        print(
            f"\nPrediction seed success:"
            f" {processed} records"
        )

    except Exception as e:

        db.rollback()

        print(
            f"\nPrediction failed:"
            f" {e}"
        )

        raise e

    finally:
        db.close()


if __name__ == "__main__":
    run_prediction_seed()