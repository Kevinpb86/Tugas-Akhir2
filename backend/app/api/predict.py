import os
import numpy as np
import pandas as pd
import requests
from datetime import timedelta
from fastapi import APIRouter, HTTPException
from app.api_schemas.earthquake import EarthquakeData, AnomaliData
from app.config.database import SessionLocal
from app.db_models.earthquake import Earthquake
from app.services import ml_service
from app.services.ml_service import ml_models, ml_scalers, resolve_coordinates, validate_study_area

router = APIRouter()

HISTORY_CSV_PATH = os.path.abspath(os.path.join(
    os.path.dirname(os.path.dirname(os.path.dirname(__file__))),
    "data", "historical_data_bmkg_2021-2026.csv"
))

BULAN_ID = ["Jan", "Feb", "Mar", "Apr", "Mei", "Jun",
            "Jul", "Agu", "Sep", "Okt", "Nov", "Des"]


def _format_gempa_bmkg(event_time, lat, lon, depth, mag, wilayah, dirasakan):
    # event_time tersimpan dalam UTC, tampilkan sebagai WIB (UTC+7) seperti format BMKG
    wib = event_time + timedelta(hours=7)
    return {
        "Tanggal": f"{wib.day:02d} {BULAN_ID[wib.month - 1]} {wib.year}",
        "Jam": wib.strftime("%H:%M:%S WIB"),
        "DateTime": event_time.isoformat() + "+00:00",
        "Coordinates": f"{lat},{lon}",
        "Lintang": f"{abs(lat):.2f} {'LS' if lat < 0 else 'LU'}",
        "Bujur": f"{abs(lon):.2f} {'BT' if lon >= 0 else 'BB'}",
        "Magnitude": str(mag),
        "Kedalaman": f"{depth:g} km",
        "Wilayah": wilayah or "",
        "Dirasakan": dirasakan or "",
    }


@router.get("/anomali-history")
async def get_anomali_history(limit: int = 5):
    """Scan riwayat gempa (tabel earthquakes di DB, fallback ke CSV historis
    jika DB tidak tersedia/kosong), jalankan Isolation Forest, dan kembalikan
    gempa asli yang terdeteksi anomali (maksimal `limit`)."""
    if ml_service.anomali_model is None:
        raise HTTPException(status_code=503, detail="Model anomali belum tersedia.")

    rows = []
    data_source = None

    # 1) Coba dari database
    try:
        db = SessionLocal()
        try:
            db_rows = (
                db.query(Earthquake)
                .order_by(Earthquake.event_time.desc())
                .all()
            )
            if db_rows:
                rows = [
                    (r.event_time, r.latitude, r.longitude, r.depth,
                     r.magnitude, r.wilayah, r.dirasakan)
                    for r in db_rows
                ]
                data_source = "database"
        finally:
            db.close()
    except Exception as e:
        print(f"DB tidak tersedia, fallback ke CSV historis: {e}")

    # 2) Fallback ke CSV historis
    if not rows:
        if not os.path.exists(HISTORY_CSV_PATH):
            raise HTTPException(
                status_code=503,
                detail="Riwayat gempa tidak tersedia (database mati dan CSV historis tidak ditemukan)."
            )
        df = pd.read_csv(HISTORY_CSV_PATH)
        df["datetime"] = pd.to_datetime(df["datetime"], utc=True).dt.tz_localize(None)
        rows = [
            (row["datetime"].to_pydatetime(), float(row["latitude"]), float(row["longitude"]),
             float(row["depth"]), float(row["magnitude"]),
             row["wilayah"] if pd.notna(row["wilayah"]) else "",
             row["dirasakan"] if pd.notna(row["dirasakan"]) else "")
            for _, row in df.iterrows()
        ]
        data_source = "csv_historis"

    # Prediksi anomali seluruh riwayat sekaligus (batch)
    features = np.array([[mag, depth, lat, lon]
                         for (_, lat, lon, depth, mag, _, _) in rows])
    if ml_service.anomali_scaler is not None:
        features_for_model = ml_service.anomali_scaler.transform(features)
    else:
        features_for_model = features

    predictions = ml_service.anomali_model.predict(features_for_model)
    scores = ml_service.anomali_model.decision_function(features_for_model)

    # Ambil hanya yang anomali (-1), urutkan dari yang paling anomali (skor terendah)
    anomali_rows = [
        (rows[i], float(scores[i]))
        for i in range(len(rows))
        if int(predictions[i]) == -1
    ]
    anomali_rows.sort(key=lambda x: x[1])
    anomali_rows = anomali_rows[:limit]

    hasil_list = []
    for row, score in anomali_rows:
        g = _format_gempa_bmkg(*row)
        g["is_anomali"] = True
        g["status_anomali"] = "Anomali Terdeteksi"
        g["anomaly_score"] = round(abs(score), 4)
        hasil_list.append(g)

    return {
        "source": data_source,
        "total_diperiksa": len(rows),
        "total_anomali": int((predictions == -1).sum()),
        "data": hasil_list
    }

@router.post("/predict")
async def predict_risk(data: EarthquakeData):
    source = data.source.lower()
    if source not in ["bmkg", "usgs"]:
        raise HTTPException(status_code=400, detail="Source harus 'bmkg' atau 'usgs'")
        
    selected_model = ml_models[source]
    
    if selected_model is None:
        raise HTTPException(status_code=503, detail=f"Model ML {source.upper()} belum diload/tidak tersedia.")
    
    lat = data.latitude
    lon = data.longitude
    
    if data.location_name:
        lat, lon = resolve_coordinates(data.location_name)
        
    if lat is None or lon is None:
        raise HTTPException(
            status_code=400,
            detail="Harus menyertakan koordinat (latitude & longitude) atau nama daerah (location_name)."
        )
        
    # Bypassed so we can test real-time BMKG data anywhere:
    # validate_study_area(lat, lon, data.location_name)
    
    try:
        features = np.array([[data.magnitude, data.depth, lat, lon]])
        
        # Gunakan scaler yang diload jika tersedia
        selected_scaler = ml_scalers.get(source)
        if selected_scaler is not None:
            features_scaled = selected_scaler.transform(features)
            # Clip data agar nilainya tidak keluar dari range [0, 1] jika ada input ekstrem
            features_scaled = np.clip(features_scaled, 0, 1)
        else:
            # Fallback ke normalisasi manual jika file scaler tidak tersedia
            if source == "usgs":
                # Data batas dari dataset USGS
                x_min = np.array([3.400, 1.410, -7.999, 106.001])
                x_max = np.array([7.500, 407.300, -5.561, 109.000])
            else:
                # Data batas dari dataset BMKG
                x_min = np.array([1.000, 1.000, -7.998, 106.000])
                x_max = np.array([7.191, 649.067, -5.501, 108.998])
            features_scaled = (features - x_min) / (x_max - x_min)
            # Clip data agar nilainya tidak keluar dari range [0, 1] jika ada input ekstrem
            features_scaled = np.clip(features_scaled, 0, 1)
        
        # Model SVM melakukan prediksi
        prediction = selected_model.predict(features_scaled)
        
        # Mapping hasil prediksi numerik (asumsi 0: Rendah, 1: Sedang, 2: Tinggi) 
        # Sesuaikan dengan label aktual model saat training!
        pred_value = int(prediction[0])
        
        if pred_value == 2:
            risk_label = "Tinggi"
        elif pred_value == 1:
            risk_label = "Sedang"
        else:
            risk_label = "Rendah"
            
        # Hitung decision function dan softmax untuk confidence score dinamis
        try:
            decision_scores = selected_model.decision_function(features_scaled)[0]
            exp_scores = np.exp(decision_scores)
            probabilities = exp_scores / np.sum(exp_scores)
            class_idx = np.where(selected_model.classes_ == pred_value)[0][0]
            confidence_val = round(float(probabilities[class_idx]), 4)
        except Exception as e:
            print(f"Error calculating confidence score: {e}")
            confidence_val = 1.0
            
        return {
            "risk_level": risk_label,
            "prediction_code": pred_value,
            "confidence": confidence_val,
            "latitude": lat,
            "longitude": lon
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Gagal melakukan prediksi: {str(e)}")

@router.post("/predict-anomali")
async def predict_anomali(data: AnomaliData):
    if ml_service.anomali_model is None:
        raise HTTPException(status_code=503, detail="Model anomali belum tersedia.")

    try:
        features = np.array([[
            data.magnitude,
            data.depth,
            data.latitude,
            data.longitude
        ]])

        if ml_service.anomali_scaler is not None:
            features_for_model = ml_service.anomali_scaler.transform(features)
        else:
            features_for_model = features
            
        prediction = ml_service.anomali_model.predict(features_for_model)
        pred_value = int(prediction[0])

        # Isolation Forest dari scikit-learn mengembalikan -1 untuk anomali, 1 untuk normal
        is_anomali = (pred_value == -1)
        label = "Anomali Terdeteksi" if is_anomali else "Normal"

        try:
            score = ml_service.anomali_model.decision_function(features_for_model)[0]
            confidence_val = round(float(abs(score)), 4)
        except Exception:
            confidence_val = 1.0

        return {
            "is_anomali": is_anomali,
            "label": label,
            "prediction_code": pred_value,
            "confidence": confidence_val
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Gagal melakukan prediksi anomali: {str(e)}")

@router.get("/anomali-terkini")
async def get_anomali_terkini():
    if ml_service.anomali_model is None:
        raise HTTPException(status_code=503, detail="Model anomali belum tersedia.")

    url = "https://data.bmkg.go.id/DataMKG/TEWS/gempadirasakan.json"
    try:
        res = requests.get(url, timeout=10)
        res.raise_for_status()
        data_bmkg = res.json()
        gempa_list = data_bmkg.get("Infogempa", {}).get("gempa", [])
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"Gagal mengambil data dari BMKG: {str(e)}")

    hasil_list = []
    for g in gempa_list:
        try:
            mag = float(g.get("Magnitude", "0"))
            
            # Kedalaman biasanya "10 km", ambil angkanya saja
            depth_str = g.get("Kedalaman", "0").replace(" km", "")
            depth = float(depth_str)
            
            # Coordinates biasanya "-6.12,106.82"
            coords_str = g.get("Coordinates", "0,0").split(",")
            lat = float(coords_str[0])
            lon = float(coords_str[1])
            
            # Lakukan prediksi Anomali
            features = np.array([[mag, depth, lat, lon]])
            if ml_service.anomali_scaler is not None:
                features_for_model = ml_service.anomali_scaler.transform(features)
            else:
                features_for_model = features
                
            prediction = ml_service.anomali_model.predict(features_for_model)
            pred_value = int(prediction[0])
            
            # -1 = anomali, 1 = normal di scikit-learn IsolationForest
            is_anomali = (pred_value == -1)
            label = "Anomali Terdeteksi" if is_anomali else "Normal"
            
            try:
                score = ml_service.anomali_model.decision_function(features_for_model)[0]
                confidence_val = round(float(abs(score)), 4)
            except Exception:
                confidence_val = 1.0

            # Menggabungkan data asli BMKG dengan hasil prediksi
            g_copy = dict(g)
            g_copy["is_anomali"] = is_anomali
            g_copy["status_anomali"] = label
            g_copy["anomaly_score"] = confidence_val
            
            hasil_list.append(g_copy)
        except Exception as parse_error:
            # Skip jika ada gempa yang gagal diparse
            print(f"Error parsing earthquake: {parse_error}")
            hasil_list.append(g)

    return {"data": hasil_list}


@router.get("/reverse-geocode")
async def reverse_geocode(lat: float, lon: float):
    url = f"https://nominatim.openstreetmap.org/reverse?format=json&lat={lat}&lon={lon}&zoom=16&addressdetails=1"
    headers = {"User-Agent": "AmaninApp/1.0"}
    try:
        res = requests.get(url, headers=headers, timeout=5)
        if res.status_code == 200:
            return res.json()
        else:
            raise HTTPException(status_code=res.status_code, detail="Gagal menghubungi server geocoding")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

