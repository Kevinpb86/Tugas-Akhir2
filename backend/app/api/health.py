from fastapi import APIRouter
from app.services.ml_service import ml_models, ml_scalers

router = APIRouter()

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
