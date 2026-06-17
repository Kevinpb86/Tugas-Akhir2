import smtplib
import secrets
import requests
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session

from app.config.database import get_db
from app.auth.security import pwd_context
from app.api_schemas.auth import UserRegister, UserLogin, GoogleAuthRequest, FacebookAuthRequest, ForgotPasswordRequest
from app.config.config import SENDER_EMAIL, APP_PASSWORD
from app.db_models.user import User

router = APIRouter()

@router.post("/register")
async def register(user: UserRegister, db: Session = Depends(get_db)):
    # Cek apakah email sudah terdaftar
    try:
        db_user = db.query(User).filter(User.email == user.email).first()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Gagal koneksi database: {str(e)}")
        
    if db_user:
        raise HTTPException(status_code=400, detail="Email sudah terdaftar!")
    
    hashed_password = pwd_context.hash(user.password)
    try:
        new_user = User(
            full_name=user.full_name,
            email=user.email,
            password=hashed_password
        )
        db.add(new_user)
        db.commit()
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    
    return {"message": "Registrasi berhasil!", "user": user.email}

@router.post("/login")
async def login(user: UserLogin, db: Session = Depends(get_db)):
    # Cari user berdasarkan email
    try:
        db_user = db.query(User).filter(User.email == user.email).first()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Gagal koneksi database: {str(e)}")
        
    if not db_user:
        raise HTTPException(status_code=401, detail="Email atau password salah!")
    
    if not pwd_context.verify(user.password, db_user.password):
        raise HTTPException(status_code=401, detail="Email atau password salah!")
    
    return {
        "message": "Login berhasil!",
        "user_id": db_user.id,
        "full_name": db_user.full_name,
        "email": db_user.email
    }

@router.post("/auth/google")
async def auth_google(req: GoogleAuthRequest, db: Session = Depends(get_db)):
    try:
        email = req.email
        full_name = req.full_name
        
        if not email:
            raise HTTPException(status_code=400, detail="Email tidak ditemukan")
            
        # Cek apakah user sudah terdaftar
        db_user = db.query(User).filter(User.email == email).first()
        
        if db_user:
            return {
                "message": "Login berhasil!",
                "user_id": db_user.id,
                "full_name": db_user.full_name,
                "email": db_user.email
            }
        else:
            random_password = secrets.token_urlsafe(16)
            hashed_password = pwd_context.hash(random_password)
            
            try:
                new_user = User(
                    full_name=full_name,
                    email=email,
                    password=hashed_password
                )
                db.add(new_user)
                db.commit()
                db.refresh(new_user)
                new_user_id = new_user.id
            except Exception as e:
                db.rollback()
                raise HTTPException(status_code=500, detail=str(e))
                
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
async def auth_facebook(req: FacebookAuthRequest, db: Session = Depends(get_db)):
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
            
        # Cek apakah user sudah terdaftar
        db_user = db.query(User).filter(User.email == email).first()
        
        if db_user:
            return {
                "message": "Login berhasil!",
                "user_id": db_user.id,
                "full_name": db_user.full_name,
                "email": db_user.email,
                "facebook_picture": picture
            }
        else:
            random_password = secrets.token_urlsafe(16)
            hashed_password = pwd_context.hash(random_password)
            
            try:
                new_user = User(
                    full_name=name,
                    email=email,
                    password=hashed_password
                )
                db.add(new_user)
                db.commit()
                db.refresh(new_user)
                new_user_id = new_user.id
            except Exception as e:
                db.rollback()
                raise HTTPException(status_code=500, detail=str(e))
                
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
def forgot_password(req: ForgotPasswordRequest, db: Session = Depends(get_db)):
    email = req.email
    
    try:
        user = db.query(User).filter(User.email == email).first()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
        
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
