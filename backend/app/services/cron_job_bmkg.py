from sqlalchemy.exc import SQLAlchemyError

from app.config.database import SessionLocal
from app.config.logging import logger

from app.repositories.earthquake_repo import (
    EarthquakeRepository
)

from app.services.fetch_bmkg_service import BMKGService


def run_job():

    db = SessionLocal()

    repo = EarthquakeRepository(db)
    service = BMKGService()

    try:
        logger.info("Fetching BMKG data...")

        raw = service.fetch_latest()

        quakes = service.transform(raw)

        if not quakes:
            logger.warning("No earthquake data found")
            return

        inserted = []
        skipped = 0

        for quake in quakes:

            exists = repo.fingerprint_exists(
                quake.fingerprint
            )

            if exists:
                skipped += 1
                continue

            inserted.append(quake)

        if inserted:

            repo.bulk_insert(inserted)

            logger.info(
                f"Ingestion success → "
                f"inserted={len(inserted)} "
                f"skipped={skipped}"
            )

        else:
            logger.info(
                f"No new data → skipped={skipped}"
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