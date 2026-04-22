from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr
import mysql.connector
from passlib.context import CryptContext

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

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
