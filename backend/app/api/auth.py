import smtplib
import secrets
import requests
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from fastapi import APIRouter, HTTPException

from app.config.database import get_db
from app.auth.security import pwd_context
from app.models.schemas import UserRegister, UserLogin, GoogleAuthRequest, FacebookAuthRequest, ForgotPasswordRequest
from app.config.db import SENDER_EMAIL, APP_PASSWORD

router = APIRouter()

@router.post("/register")
async def register(user: UserRegister):
    db = get_db()
    if not db:
        raise HTTPException(status_code=500, detail="Gagal koneksi ke database")
    
    cursor = db.cursor()
    cursor.execute("SELECT id FROM users WHERE email = %s", (user.email,))
    if cursor.fetchone():
        db.close()
        raise HTTPException(status_code=400, detail="Email sudah terdaftar!")
    
    hashed_password = pwd_context.hash(user.password)
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

@router.post("/login")
async def login(user: UserLogin):
    db = get_db()
    if not db:
        raise HTTPException(status_code=500, detail="Gagal koneksi ke database")
    
    cursor = db.cursor(dictionary=True)
    cursor.execute("SELECT * FROM users WHERE email = %s", (user.email,))
    db_user = cursor.fetchone()
    db.close()
    
    if not db_user:
        raise HTTPException(status_code=401, detail="Email atau password salah!")
    
    if not pwd_context.verify(user.password, db_user["password"]):
        raise HTTPException(status_code=401, detail="Email atau password salah!")
    
    return {
        "message": "Login berhasil!",
        "user_id": db_user["id"],
        "full_name": db_user["full_name"],
        "email": db_user["email"]
    }

@router.post("/auth/google")
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
        cursor.execute("SELECT * FROM users WHERE email = %s", (email,))
        db_user = cursor.fetchone()
        
        if db_user:
            db.close()
            return {
                "message": "Login berhasil!",
                "user_id": db_user["id"],
                "full_name": db_user["full_name"],
                "email": db_user["email"]
            }
        else:
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

@router.post("/auth/facebook")
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
        cursor.execute("SELECT * FROM users WHERE email = %s", (email,))
        db_user = cursor.fetchone()
        
        if db_user:
            db.close()
            return {
                "message": "Login berhasil!",
                "user_id": db_user["id"],
                "full_name": db_user["full_name"],
                "email": db_user["email"],
                "facebook_picture": picture
            }
        else:
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

@router.post("/forgot-password")
def forgot_password(req: ForgotPasswordRequest):
    email = req.email
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
            
    reset_link = f"http://localhost:8000/reset-password?email={email}&token=dummy_token_123"
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
    
    try:
        if SENDER_EMAIL == "email.anda@gmail.com":
             return {"message": "PENGEMBANG: Silakan ganti SENDER_EMAIL dan APP_PASSWORD di file .env terlebih dahulu."}
             
        server = smtplib.SMTP('smtp.gmail.com', 587)
        server.starttls()
        server.login(SENDER_EMAIL, APP_PASSWORD)
        text = msg.as_string()
        server.sendmail(SENDER_EMAIL, email, text)
        server.quit()
        return {"message": "Tautan reset kata sandi telah dikirim ke email Anda."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Gagal mengirim email: {str(e)}")
