from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr
import mysql.connector
from passlib.context import CryptContext
import os
import joblib
import numpy as np
app = FastAPI()

# Pengaturan CORS agar Flutter bisa memanggil API ini
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Konfigurasi Database (Ganti sesuai setting XAMPP kamu jika berbeda)
db_config = {
    "host": "localhost",
    "user": "root",
    "password": "", # Default XAMPP kosong
    "database": "db_amanin"
}

# Setup Password Hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Model Data untuk Request
class UserRegister(BaseModel):
    full_name: str
    email: EmailStr
    password: str

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class EarthquakeData(BaseModel):
    magnitude: float
    depth: float
    latitude: float
    longitude: float
    source: str = "bmkg" # Bisa 'bmkg' atau 'usgs'

# Load Machine Learning Model
MODEL_DIR = os.path.join(os.path.dirname(__file__), "model")
MODEL_BMKG_PATH = os.path.join(MODEL_DIR, "bmkg_model.pkl")
MODEL_USGS_PATH = os.path.join(MODEL_DIR, "usgs_model.pkl")

ml_models = {
    "bmkg": None,
    "usgs": None
}

try:
    if os.path.exists(MODEL_BMKG_PATH):
        ml_models["bmkg"] = joblib.load(MODEL_BMKG_PATH)
        print("Model BMKG berhasil diload!")
    else:
        print(f"Warning: Model BMKG tidak ditemukan di {MODEL_BMKG_PATH}")
        
    if os.path.exists(MODEL_USGS_PATH):
        ml_models["usgs"] = joblib.load(MODEL_USGS_PATH)
        print("Model USGS berhasil diload!")
    else:
        print(f"Warning: Model USGS tidak ditemukan di {MODEL_USGS_PATH}")
except Exception as e:
    print(f"Error loading models: {e}")

# Fungsi untuk koneksi DB
def get_db():
    try:
        conn = mysql.connector.connect(**db_config)
        return conn
    except mysql.connector.Error as err:
        print(f"Error: {err}")
        return None

@app.post("/register")
async def register(user: UserRegister):
    db = get_db()
    if not db:
        raise HTTPException(status_code=500, detail="Gagal koneksi ke database")
    
    cursor = db.cursor()
    
    # Cek apakah email sudah terdaftar
    cursor.execute("SELECT id FROM users WHERE email = %s", (user.email,))
    if cursor.fetchone():
        db.close()
        raise HTTPException(status_code=400, detail="Email sudah terdaftar!")
    
    # Hash password
    hashed_password = pwd_context.hash(user.password)
    
    # Simpan ke DB
    try:
        sql = "INSERT INTO users (full_name, email, password) VALUES (%s, %s, %s)"
        cursor.execute(sql, (user.full_name, user.email, hashed_password))
        db.commit()
    except Exception as e:
        db.rollback()
        db.close()
        raise HTTPException(status_code=500, detail=str(e))
    
    db.close()
    return {"message": "Registrasi berhasil!", "user": user.email}

@app.post("/login")
async def login(user: UserLogin):
    db = get_db()
    if not db:
        raise HTTPException(status_code=500, detail="Gagal koneksi ke database")
    
    cursor = db.cursor(dictionary=True)
    
    # Cari user berdasarkan email
    cursor.execute("SELECT * FROM users WHERE email = %s", (user.email,))
    db_user = cursor.fetchone()
    
    db.close()
    
    if not db_user:
        raise HTTPException(status_code=401, detail="Email atau password salah!")
    
    # Verifikasi password
    if not pwd_context.verify(user.password, db_user["password"]):
        raise HTTPException(status_code=401, detail="Email atau password salah!")
    
    return {
        "message": "Login berhasil!",
        "user_id": db_user["id"],
        "full_name": db_user["full_name"],
        "email": db_user["email"]
    }

@app.get("/health")
async def health_check():
    return {
        "status": "ok", 
        "bmkg_model_loaded": ml_models["bmkg"] is not None,
        "usgs_model_loaded": ml_models["usgs"] is not None
    }

@app.post("/predict")
async def predict_risk(data: EarthquakeData):
    source = data.source.lower()
    if source not in ["bmkg", "usgs"]:
        raise HTTPException(status_code=400, detail="Source harus 'bmkg' atau 'usgs'")
        
    selected_model = ml_models[source]
    
    if selected_model is None:
        raise HTTPException(status_code=503, detail=f"Model ML {source.upper()} belum diload/tidak tersedia.")
    
    try:
        # Mapping batas minimum dan maksimum dataset saat training untuk MinMaxScaler
        # Urutan fitur: [magnitude, depth, latitude, longitude]
        
        if source == "usgs":
            # Data batas dari dataset USGS
            x_min = np.array([3.400, 1.410, -7.999, 106.001])
            x_max = np.array([7.500, 407.300, -5.561, 109.000])
        else:
            # Data batas dari dataset BMKG
            x_min = np.array([1.000, 1.000, -7.998, 106.000])
            x_max = np.array([7.191, 649.067, -5.501, 108.998])
            
        features = np.array([[data.magnitude, data.depth, data.latitude, data.longitude]])
        
        # Lakukan Normalisasi Min-Max secara manual
        # Rumus: (X - X_min) / (X_max - X_min)
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
            
        return {
            "risk_level": risk_label,
            "prediction_code": pred_value,
            "confidence": 1.0 # SVM standard di scikit-learn biasanya butuh probability=True untuk confidence
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Gagal melakukan prediksi: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
