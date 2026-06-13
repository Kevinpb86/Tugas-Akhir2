import numpy as np
from fastapi import APIRouter, HTTPException
from app.models.schemas import EarthquakeData, AnomaliData
from app.services.ml_service import ml_models, ml_scalers, anomali_model, anomali_scaler, resolve_coordinates, validate_study_area

router = APIRouter()

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
        
    validate_study_area(lat, lon, data.location_name)
    
    try:
        features = np.array([[data.magnitude, data.depth, lat, lon]])
        
        # Gunakan scaler yang diload jika tersedia
        selected_scaler = ml_scalers.get(source)
        if selected_scaler is not None:
            features_scaled = selected_scaler.transform(features)
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
    if anomali_model is None or anomali_scaler is None:
        raise HTTPException(status_code=503, detail="Model atau scaler anomali belum tersedia.")

    try:
        features = np.array([[
            data.latitude,
            data.longitude,
            data.depth,
            data.gap,
            data.dmin,
            data.nst,
            data.bulan,
            data.jam
        ]])

        features_scaled = anomali_scaler.transform(features)
        prediction = anomali_model.predict(features_scaled)
        pred_value = int(prediction[0])

        is_anomali = pred_value == 1
        label = "Anomali" if is_anomali else "Normal"

        try:
            prob = anomali_model.predict_proba(features_scaled)[0]
            confidence_val = round(float(prob[pred_value]), 4)
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
