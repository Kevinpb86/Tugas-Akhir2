from sqlalchemy.exc import SQLAlchemyError

from app.config.database import SessionLocal
from app.config.logging import logger

from app.db_models.seismic_analysis import SeismicAnalysis

from app.repositories.earthquake_repo import (
    EarthquakeRepository
)

from app.services.fetch_bmkg_service import BMKGService
from app.services.extarct_features import NNDService
from app.services.rf_service import MLService
from app.services.influence_zones_service import (
    InfluenceZoneService
)

MC = 4.7


def run_job():

    db = SessionLocal()

    repo = EarthquakeRepository(db)

    bmkg_service = BMKGService()
    nnd_service = NNDService(db)
    ml_service = MLService()
    influence_service = InfluenceZoneService(db)

    try:
        logger.info("Fetching BMKG data...")

        raw = bmkg_service.fetch_latest()

        quakes = bmkg_service.transform(raw)

        if not quakes:
            logger.warning(
                "No earthquake data found"
            )
            return

        inserted = 0
        skipped = 0

        for quake in quakes:

            exists = repo.fingerprint_exists(
                quake.fingerprint
            )

            if exists:
                skipped += 1
                continue

            # ==========================================
            # INSERT EARTHQUAKE
            # ==========================================

            db.add(quake)

            # generate earthquake.id
            db.flush()

            logger.info(
                f"Processing earthquake_id="
                f"{quake.id}"
            )

            # ==========================================
            # DEFAULT STATUS
            # ==========================================

            quake.status = "below_mc"

            # ==========================================
            # NND + RF
            # ==========================================

            if quake.magnitude >= MC:

                nnd_result = nnd_service.compute(
                    quake,
                    mc=MC
                )

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
                        earthquake_id=quake.id,

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

                    # supaya analysis bisa dipakai
                    db.flush()

                    # ==================================
                    # CREATE INFLUENCE ZONE
                    # ==================================

                    influence_service.create_if_background(
                        earthquake=quake,
                        analysis=analysis,
                    )

                    quake.status = "processed"

            inserted += 1

        db.commit()

        if inserted:

            logger.info(
                f"Ingestion success → "
                f"inserted={inserted} "
                f"skipped={skipped}"
            )

        else:

            logger.info(
                f"No new data → "
                f"skipped={skipped}"
            )

    except SQLAlchemyError as exc:

        db.rollback()

        logger.exception(
            f"Database error: {exc}"
        )

    except Exception as exc:

        db.rollback()

        logger.exception(
            f"Job failed: {exc}"
        )

    finally:

        db.close()

        logger.info(
            "DB connection closed"
        )