from apscheduler.schedulers.blocking import BlockingScheduler
from apscheduler.triggers.interval import IntervalTrigger

from app.services.cron_job_bmkg import run_job
from app.config.logging import logger

JOB_ID = "bmkg_ingestion"


def start_scheduler():
    scheduler = BlockingScheduler(timezone="UTC")

    scheduler.add_job(
        func=run_job,
        trigger=IntervalTrigger(minutes=1),
        id=JOB_ID,
        replace_existing=True,
        max_instances=1,
        coalesce=True,
    )

    logger.info("BMKG worker started")

    try:
        scheduler.start()

    except (KeyboardInterrupt, SystemExit):
        logger.info("BMKG worker stopped")


if __name__ == "__main__":
    start_scheduler()