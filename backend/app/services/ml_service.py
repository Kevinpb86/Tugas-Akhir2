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
MODEL_ANOMALI_PATH = os.path.join(MODEL_DIR, "isolation_forest_bmkg.pkl")
SCALER_ANOMALI_PATH = os.path.join(MODEL_DIR, "scaler_isolation_forest_bmkg.pkl")
SHAP_EXPLAINER_ANOMALI_PATH = os.path.join(MODEL_DIR, "IF_SHAP_explainer.pkl")
REKOMENDASI_EDUKASI_PATH = os.path.join(MODEL_DIR, "rekomendasi_edukasi.pkl")

ANOMALI_FEATURE_NAMES = ["mag", "depth", "latitude", "longitude"]

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
anomali_shap_explainer = None
rekomendasi_edukasi_model = None

def load_ml_models():
    warnings.filterwarnings("ignore", category=InconsistentVersionWarning)
    global anomali_model, anomali_scaler, anomali_shap_explainer, rekomendasi_edukasi_model
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

        if os.path.exists(SHAP_EXPLAINER_ANOMALI_PATH):
            anomali_shap_explainer = joblib.load(SHAP_EXPLAINER_ANOMALI_PATH)
            print("SHAP Explainer Anomali berhasil diload!")
        else:
            print(f"Warning: SHAP Explainer Anomali tidak ditemukan di {SHAP_EXPLAINER_ANOMALI_PATH}")

        if os.path.exists(REKOMENDASI_EDUKASI_PATH):
            rekomendasi_edukasi_model = joblib.load(REKOMENDASI_EDUKASI_PATH)
            print("Model Rekomendasi Edukasi berhasil diload!")
        else:
            print(f"Warning: Model Rekomendasi Edukasi tidak ditemukan di {REKOMENDASI_EDUKASI_PATH}")
    except Exception as e:
        print(f"Error loading models: {e}")


FEATURE_LABELS_ID = {
    "mag": "Magnitudo",
    "depth": "Kedalaman",
    "latitude": "Lintang",
    "longitude": "Bujur",
}

FEATURE_UNITS_ID = {
    "mag": "SR",
    "depth": "km",
    "latitude": "°",
    "longitude": "°",
}


def _deviation_label(n_std: float) -> str:
    """Terjemahkan seberapa jauh nilai fitur dari rata-rata historis (dalam satuan
    standar deviasi/z-score) menjadi label bahasa Indonesia yang mudah dipahami awam."""
    n = abs(n_std)
    if n < 0.5:
        return "sesuai kebiasaan historis"
    if n < 1.5:
        return "sedikit berbeda dari kebiasaan historis"
    if n < 3.0:
        return "cukup jauh berbeda dari kebiasaan historis"
    return "sangat jauh berbeda dari kebiasaan historis"


def explain_anomali(features_for_model: np.ndarray, features_raw: Optional[np.ndarray] = None) -> Optional[dict]:
    """Hitung kontribusi tiap fitur terhadap skor anomali memakai SHAP TreeExplainer
    yang sudah dilatih (IF_SHAP_explainer.pkl), lalu susun penjelasan lengkap
    (angka SHAP asli + narasi awam + perbandingan ke rata-rata historis) dalam bahasa Indonesia.

    `features_raw` (opsional): nilai fitur asli sebelum di-scaling, dipakai untuk
    menampilkan angka yang dikenali user (mis. "22 km") alih-alih nilai ter-scaling.
    """
    if anomali_shap_explainer is None:
        return None

    shap_values = anomali_shap_explainer.shap_values(features_for_model)[0]
    total_abs = float(np.abs(shap_values).sum()) or 1.0

    # Rata-rata & simpangan baku historis dari scaler (traceable ke data training),
    # dipakai untuk membandingkan nilai gempa ini terhadap kebiasaan historis.
    means = getattr(anomali_scaler, "mean_", None)
    stds = getattr(anomali_scaler, "scale_", None)

    raw_row = features_raw[0] if features_raw is not None else None

    contributions = []
    for i, name in enumerate(ANOMALI_FEATURE_NAMES):
        value = float(shap_values[i])
        persen_kontribusi = round(abs(value) / total_abs * 100, 1)
        arah = "anomali" if value < 0 else "normal"

        entry = {
            "feature": name,
            "label": FEATURE_LABELS_ID.get(name, name),
            "unit": FEATURE_UNITS_ID.get(name, ""),
            "shap_value": round(value, 4),
            "kontribusi_persen": persen_kontribusi,
            "arah": arah,
        }

        if raw_row is not None:
            entry["nilai_aktual"] = round(float(raw_row[i]), 2)

        if means is not None and stds is not None and raw_row is not None:
            rata_rata_historis = float(means[i])
            n_std = (float(raw_row[i]) - rata_rata_historis) / float(stds[i])
            entry["rata_rata_historis"] = round(rata_rata_historis, 2)
            entry["deviasi_std"] = round(n_std, 2)
            entry["keterangan"] = _deviation_label(n_std)

        contributions.append(entry)

    # Urutkan dari kontribusi paling besar (paling mendorong ke arah anomali/normal)
    contributions.sort(key=lambda c: abs(c["shap_value"]), reverse=True)

    dominant = contributions[0]
    arah_teks = "mendorong ke arah anomali" if dominant["shap_value"] < 0 else "mendorong ke arah normal"

    if "nilai_aktual" in dominant and "rata_rata_historis" in dominant:
        narasi = (
            f"Faktor paling berpengaruh adalah {dominant['label']} "
            f"({dominant['nilai_aktual']} {dominant['unit']}, {dominant['keterangan']} "
            f"yang rata-ratanya {dominant['rata_rata_historis']} {dominant['unit']}), "
            f"berkontribusi {dominant['kontribusi_persen']}% dan {arah_teks}."
        )
    else:
        narasi = (
            f"Faktor paling berpengaruh adalah {dominant['label']} "
            f"(kontribusi {dominant['kontribusi_persen']}%), yang {arah_teks}."
        )

    return {
        "base_value": round(float(anomali_shap_explainer.expected_value[0]), 4),
        "contributions": contributions,
        "summary": narasi,
    }


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

def extract_city_from_description(name: str) -> str:
    name_lower = name.lower()
    if "gempa" in name_lower or "km" in name_lower:
        directions = ["barat daya", "barat laut", "timur laut", "tenggara", "selatan", "utara", "timur", "barat", "laut"]
        for d in directions:
            if d in name_lower:
                parts = name_lower.split(d)
                if len(parts) > 1:
                    candidate = parts[-1].strip()
                    for prefix in ["kab.", "kabupaten", "kota", "kecamatan", "desa"]:
                        if candidate.startswith(prefix):
                            candidate = candidate[len(prefix):].strip()
                    if candidate:
                        # Clean any non-alphanumeric chars at the end
                        candidate = ''.join(c for c in candidate if c.isalnum() or c.isspace()).strip()
                        return candidate
    return name

def resolve_coordinates(location_name: str) -> tuple[float, float]:
    clean_name = location_name.strip().lower()
    if clean_name in LOCAL_COORDINATES:
        return LOCAL_COORDINATES[clean_name]
    
    coords = geocode_online(location_name)
    if coords:
        return coords

    # Jika gagal, coba ekstrak nama wilayah/kota utama dari kalimat deskripsi BMKG
    extracted_name = extract_city_from_description(location_name)
    if extracted_name != location_name:
        print(f"Extracted city name for geocoding: '{extracted_name}' from '{location_name}'")
        extracted_clean = extracted_name.lower()
        if extracted_clean in LOCAL_COORDINATES:
            return LOCAL_COORDINATES[extracted_clean]
        coords = geocode_online(extracted_name)
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
