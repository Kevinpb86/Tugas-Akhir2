from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr
import mysql.connector
from passlib.context import CryptContext
import os
import joblib
import numpy as np
import secrets
import requests
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
    "database": "db_amanin",
    "port": 3308
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

class AnomaliData(BaseModel):
    latitude: float
    longitude: float
    depth: float
    gap: float
    dmin: float
    nst: float
    bulan: int
    jam: int

# Load Machine Learning Model
MODEL_DIR = os.path.join(os.path.dirname(__file__), "model")
MODEL_BMKG_PATH = os.path.join(MODEL_DIR, "bmkg_model.pkl")
SCALER_BMKG_PATH = os.path.join(MODEL_DIR, "scaler_bmkg.pkl")
MODEL_USGS_PATH = os.path.join(MODEL_DIR, "usgs_model.pkl")
SCALER_USGS_PATH = os.path.join(MODEL_DIR, "scaler_usgs.pkl")
MODEL_ANOMALI_PATH = os.path.join(MODEL_DIR, "model_anomali.pkl")
SCALER_ANOMALI_PATH = os.path.join(MODEL_DIR, "scaler_anomali.pkl")

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
except Exception as e:
    print(f"Error loading models: {e}")
class GoogleAuthRequest(BaseModel):
    email: str
    full_name: str
    google_id: str

class FacebookAuthRequest(BaseModel):
    access_token: str

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
        "model_loaded": (ml_models["bmkg"] is not None) or (ml_models["usgs"] is not None),
        "bmkg_model_loaded": ml_models["bmkg"] is not None,
        "usgs_model_loaded": ml_models["usgs"] is not None,
        "bmkg_scaler_loaded": ml_scalers["bmkg"] is not None,
        "usgs_scaler_loaded": ml_scalers["usgs"] is not None
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
        features = np.array([[data.magnitude, data.depth, data.latitude, data.longitude]])
        
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
            "confidence": confidence_val
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Gagal melakukan prediksi: {str(e)}")

@app.post("/auth/google")
async def auth_google(req: GoogleAuthRequest):
    try:
        email = req.email
        full_name = req.full_name
        
        if not email:
            raise HTTPException(status_code=400, detail="Email tidak ditemukan")
            
        db = get_db()
        if not db:
            raise HTTPException(status_code=500, detail="Gagal koneksi ke database")
            
        cursor = db.cursor(dictionary=True)
        
        # Cek apakah user sudah terdaftar
        cursor.execute("SELECT * FROM users WHERE email = %s", (email,))
        db_user = cursor.fetchone()
        
        if db_user:
            # User sudah ada -> Login
            db.close()
            return {
                "message": "Login berhasil!",
                "user_id": db_user["id"],
                "full_name": db_user["full_name"],
                "email": db_user["email"]
            }
        else:
            # User belum ada -> Register Otomatis
            # Buatkan password acak karena login menggunakan Google
            random_password = secrets.token_urlsafe(16)
            hashed_password = pwd_context.hash(random_password)
            
            try:
                sql = "INSERT INTO users (full_name, email, password) VALUES (%s, %s, %s)"
                cursor.execute(sql, (full_name, email, hashed_password))
                db.commit()
                new_user_id = cursor.lastrowid
            except Exception as e:
                db.rollback()
                db.close()
                raise HTTPException(status_code=500, detail=str(e))
                
            db.close()
            return {
                "message": "Registrasi dan Login berhasil!",
                "user_id": new_user_id,
                "full_name": full_name,
                "email": email
            }
            
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")

@app.post("/auth/facebook")
async def auth_facebook(req: FacebookAuthRequest):
    try:
        url = f"https://graph.facebook.com/me?fields=id,name,email,picture&access_token={req.access_token}"
        response = requests.get(url)
        
        if response.status_code != 200:
            raise HTTPException(status_code=401, detail="Token Facebook tidak valid")
            
        fb_user_info = response.json()
        
        email = fb_user_info.get('email')
        name = fb_user_info.get('name')
        picture = fb_user_info.get('picture', {}).get('data', {}).get('url', '')
        
        if not email:
            raise HTTPException(status_code=400, detail="Akun Facebook tidak memiliki email yang bisa diakses")
            
        db = get_db()
        if not db:
            raise HTTPException(status_code=500, detail="Gagal koneksi ke database")
            
        cursor = db.cursor(dictionary=True)
        
        # Cek apakah user sudah terdaftar
        cursor.execute("SELECT * FROM users WHERE email = %s", (email,))
        db_user = cursor.fetchone()
        
        if db_user:
            # User sudah ada -> Login
            db.close()
            return {
                "message": "Login berhasil!",
                "user_id": db_user["id"],
                "full_name": db_user["full_name"],
                "email": db_user["email"],
                "facebook_picture": picture
            }
        else:
            # User belum ada -> Register Otomatis
            random_password = secrets.token_urlsafe(16)
            hashed_password = pwd_context.hash(random_password)
            
            try:
                sql = "INSERT INTO users (full_name, email, password) VALUES (%s, %s, %s)"
                cursor.execute(sql, (name, email, hashed_password))
                db.commit()
                new_user_id = cursor.lastrowid
            except Exception as e:
                db.rollback()
                db.close()
                raise HTTPException(status_code=500, detail=str(e))
                
            db.close()
            return {
                "message": "Registrasi dan Login berhasil!",
                "user_id": new_user_id,
                "full_name": name,
                "email": email,
                "facebook_picture": picture
            }
            
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")


import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from pydantic import BaseModel, EmailStr

class ForgotPasswordRequest(BaseModel):
    email: EmailStr

@app.post("/forgot-password")
def forgot_password(req: ForgotPasswordRequest):
    email = req.email
    
    # 1. Check if email exists in DB
    db = get_db()
    if not db:
        raise HTTPException(status_code=500, detail="Gagal koneksi ke database")
        
    try:
        cursor = db.cursor(dictionary=True)
        cursor.execute("SELECT * FROM users WHERE email = %s", (email,))
        user = cursor.fetchone()
    except Exception as e:
        db.close()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if 'cursor' in locals():
            cursor.close()
        db.close()
        
    if not user:
        raise HTTPException(status_code=404, detail="Email tidak terdaftar!")
            
    # 2. Setup SMTP credentials (USER NEEDS TO FILL THESE IN)
    SENDER_EMAIL = "kevinpratama86pb@gmail.com"
    APP_PASSWORD = "putzdnahxilprhaj"
    
    # URL for resetting password (Can be a deep link to the app or a web page)
    # For now, we simulate a simple URL containing a dummy token
    reset_link = f"http://localhost:8000/reset-password?email={email}&token=dummy_token_123"
    
    # 3. Create the email content
    msg = MIMEMultipart()
    msg['From'] = SENDER_EMAIL
    msg['To'] = email
    msg['Subject'] = "Reset Kata Sandi - Aplikasi Amanin"
    
    body = f"""
    <html>
      <body>
        <h2 style="color: #092C4C;">Reset Kata Sandi Amanin</h2>
        <p>Halo,</p>
        <p>Kami menerima permintaan untuk mereset kata sandi Anda. Silakan klik tautan di bawah ini untuk mereset kata sandi Anda:</p>
        <a href="{reset_link}" style="display: inline-block; padding: 10px 20px; color: white; background-color: #00BCD4; text-decoration: none; border-radius: 8px;">Reset Kata Sandi</a>
        <p>Jika Anda tidak merasa meminta reset kata sandi, abaikan email ini.</p>
        <br>
        <p>Terima kasih,<br>Tim Amanin</p>
      </body>
    </html>
    """
    msg.attach(MIMEText(body, 'html'))
    
    # 4. Send the email
    try:
        # Note: If credentials are not filled, this will fail gracefully and return a message
        if SENDER_EMAIL == "email.anda@gmail.com":
             return {"message": "PENGEMBANG: Silakan ganti SENDER_EMAIL dan APP_PASSWORD di backend/main.py terlebih dahulu."}
             
        server = smtplib.SMTP('smtp.gmail.com', 587)
        server.starttls()
        server.login(SENDER_EMAIL, APP_PASSWORD)
        text = msg.as_string()
        server.sendmail(SENDER_EMAIL, email, text)
        server.quit()
        return {"message": "Tautan reset kata sandi telah dikirim ke email Anda."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Gagal mengirim email: {str(e)}")

@app.post("/predict-anomali")
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


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
