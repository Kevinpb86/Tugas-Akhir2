import os
import warnings
import joblib
import numpy as np
from sklearn.exceptions import InconsistentVersionWarning
import requests
from fastapi import HTTPException
from typing import Optional

# Resolve model path dynamically
MODEL_DIR = os.path.abspath(os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "model"))
MODEL_BMKG_PATH = os.path.join(MODEL_DIR, "bmkg_model.pkl")
SCALER_BMKG_PATH = os.path.join(MODEL_DIR, "scaler_bmkg.pkl")
MODEL_USGS_PATH = os.path.join(MODEL_DIR, "usgs_model.pkl")
SCALER_USGS_PATH = os.path.join(MODEL_DIR, "scaler_usgs.pkl")
MODEL_ANOMALI_PATH = os.path.join(MODEL_DIR, "model_anomali.pkl")
SCALER_ANOMALI_PATH = os.path.join(MODEL_DIR, "scaler_anomali.pkl")
REKOMENDASI_EDUKASI_PATH = os.path.join(MODEL_DIR, "rekomendasi_edukasi.pkl")

ml_models = {
    "bmkg": None,
    "usgs": None
}
ml_scalers = {
    "bmkg": None,
    "usgs": None
}
anomali_model = None
anomali_scaler = None
rekomendasi_edukasi_model = None

def load_ml_models():
    warnings.filterwarnings("ignore", category=InconsistentVersionWarning)
    global anomali_model, anomali_scaler, rekomendasi_edukasi_model
    try:
        if os.path.exists(MODEL_BMKG_PATH):
            ml_models["bmkg"] = joblib.load(MODEL_BMKG_PATH)
            print("Model BMKG berhasil diload!")
        else:
            print(f"Warning: Model BMKG tidak ditemukan di {MODEL_BMKG_PATH}")

        if os.path.exists(SCALER_BMKG_PATH):
            ml_scalers["bmkg"] = joblib.load(SCALER_BMKG_PATH)
            print("Scaler BMKG berhasil diload!")
        else:
            print(f"Warning: Scaler BMKG tidak ditemukan di {SCALER_BMKG_PATH}")
            
        if os.path.exists(MODEL_USGS_PATH):
            ml_models["usgs"] = joblib.load(MODEL_USGS_PATH)
            print("Model USGS berhasil diload!")
        else:
            print(f"Warning: Model USGS tidak ditemukan di {MODEL_USGS_PATH}")

        if os.path.exists(SCALER_USGS_PATH):
            ml_scalers["usgs"] = joblib.load(SCALER_USGS_PATH)
            print("Scaler USGS berhasil diload!")
        else:
            print(f"Warning: Scaler USGS tidak ditemukan di {SCALER_USGS_PATH}")

        if os.path.exists(MODEL_ANOMALI_PATH):
            anomali_model = joblib.load(MODEL_ANOMALI_PATH)
            print("Model Anomali berhasil diload!")
        else:
            print(f"Warning: Model Anomali tidak ditemukan di {MODEL_ANOMALI_PATH}")

        if os.path.exists(SCALER_ANOMALI_PATH):
            anomali_scaler = joblib.load(SCALER_ANOMALI_PATH)
            print("Scaler Anomali berhasil diload!")
        else:
            print(f"Warning: Scaler Anomali tidak ditemukan di {SCALER_ANOMALI_PATH}")

        if os.path.exists(REKOMENDASI_EDUKASI_PATH):
            rekomendasi_edukasi_model = joblib.load(REKOMENDASI_EDUKASI_PATH)
            print("Model Rekomendasi Edukasi berhasil diload!")
        else:
            print(f"Warning: Model Rekomendasi Edukasi tidak ditemukan di {REKOMENDASI_EDUKASI_PATH}")
    except Exception as e:
        print(f"Error loading models: {e}")

LOCAL_COORDINATES = {
    "lembang": (-6.82, 107.62),
    "bandung": (-6.9175, 107.6191),
    "cimahi": (-6.8722, 107.5414),
    "sumedang": (-6.8589, 107.9333),
    "subang": (-6.5715, 107.7587),
    "cianjur": (-6.8222, 107.1394),
    "purwakarta": (-6.5569, 107.4433),
    "garut": (-7.2278, 107.9086),
    "sukabumi": (-6.9278, 106.9300),
    "bogor": (-6.5971, 106.8060),
    "depok": (-6.4025, 106.7942),
    "bekasi": (-6.2383, 106.9756),
    "karawang": (-6.3039, 107.2981),
    "cirebon": (-6.7320, 108.5520),
    "indramayu": (-6.3264, 108.3200),
    "majalengka": (-6.8374, 108.2238),
    "kuningan": (-6.9764, 108.4842),
    "tasikmalaya": (-7.3274, 108.2207),
    "ciamis": (-7.3274, 108.3556),
    "banjar": (-7.3719, 108.5439),
    "pangandaran": (-7.6961, 108.4904)
}

LAT_MIN, LAT_MAX = -8.00, -5.50
LON_MIN, LON_MAX = 106.00, 109.00

def geocode_online(query: str) -> Optional[tuple[float, float]]:
    try:
        full_query = f"{query}, Jawa Barat, Indonesia"
        url = "https://nominatim.openstreetmap.org/search"
        headers = {
            "User-Agent": "AmaninApp/1.0 (contact: dava@amanin.com)"
        }
        params = {
            "q": full_query,
            "format": "json",
            "limit": 10
        }
        res = requests.get(url, headers=headers, params=params, timeout=5)
        if res.status_code == 200:
            data = res.json()
            if data:
                excluded = {'amenity', 'shop', 'office', 'highway', 'building', 'craft', 'leisure', 'tourism'}
                for item in data:
                    item_class = item.get("class", "")
                    if item_class in excluded:
                        continue
                    lat = float(item["lat"])
                    lon = float(item["lon"])
                    return lat, lon
    except Exception as e:
        print(f"Error geocoding online: {e}")
    return None

def resolve_coordinates(location_name: str) -> tuple[float, float]:
    clean_name = location_name.strip().lower()
    if clean_name in LOCAL_COORDINATES:
        return LOCAL_COORDINATES[clean_name]
    
    coords = geocode_online(location_name)
    if coords:
        return coords
        
    raise HTTPException(
        status_code=400, 
        detail=f"Lokasi '{location_name}' tidak dapat ditemukan atau tidak dikenali."
    )

def validate_study_area(lat: float, lon: float, location_name: str = None):
    if not (LAT_MIN <= lat <= LAT_MAX) or not (LON_MIN <= lon <= LON_MAX):
        loc_str = f" ({location_name})" if location_name else ""
        raise HTTPException(
            status_code=400,
            detail=f"Koordinat ({lat}, {lon}){loc_str} berada di luar wilayah studi Jawa Barat (Lintang: -8.00 s/d -5.50, Bujur: 106.00 s/d 109.00)."
        )
