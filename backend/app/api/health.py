from fastapi import APIRouter
from app.services.ml_service import ml_models, ml_scalers
from app.services.fetch_bmkg_service import BMKGService
from app.services.cron_job_bmkg import run_job
from app.config.logging import logger

router = APIRouter()
service_bmkg = BMKGService()

@router.get("/health")
async def health_check():
    return {
        "status": "ok", 
        "model_loaded": (ml_models["bmkg"] is not None) or (ml_models["usgs"] is not None),
        "bmkg_model_loaded": ml_models["bmkg"] is not None,
        "usgs_model_loaded": ml_models["usgs"] is not None,
        "bmkg_scaler_loaded": ml_scalers["bmkg"] is not None,
        "usgs_scaler_loaded": ml_scalers["usgs"] is not None
    }

@router.get("/health/data-bmkg")
async def bmkg_check():
    data = service_bmkg.fetch_latest()
    logger.info("TEST LOG API")
    return {
        "status": "Success",
        "total_data": len(data['Infogempa']['gempa'])
    }

@router.get("/test-cron")
def test_cron():
    logger.info("Manual cron trigger")
    run_job()
    return {"status": "cron executed"}
