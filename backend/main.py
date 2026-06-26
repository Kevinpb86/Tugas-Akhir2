from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.services.ml_service import load_ml_models

from app.api.auth import router as auth_router
from app.api.predict import router as predict_router
from app.api.health import router as health_router
from app.api.edukasi import router as edukasi_router
from app.api.analysis_router import router as analysis_router


app = FastAPI()


# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Startup event (load ML model)
@app.on_event("startup")
def startup_event():
    load_ml_models()


# Routers
app.include_router(auth_router)
app.include_router(predict_router)
app.include_router(health_router)
app.include_router(edukasi_router, prefix="/api/edukasi", tags=["Edukasi"])

app.include_router(analysis_router)
@app.get("/")
def root():
    return {"message": "AMANIN Backend Running"}