import sys

def add_forgot_password_endpoint():
    with open('backend/main.py', 'r', encoding='utf-8') as f:
        content = f.read()

    new_endpoint = '''
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
    try:
        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True)
        cursor.execute("SELECT * FROM users WHERE email = %s", (email,))
        user = cursor.fetchone()
        if not user:
            raise HTTPException(status_code=404, detail="Email tidak terdaftar!")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if connection.is_connected():
            cursor.close()
            connection.close()
            
    # 2. Setup SMTP credentials (USER NEEDS TO FILL THESE IN)
    SENDER_EMAIL = "email.anda@gmail.com" # GANTI DENGAN EMAIL GMAIL ANDA
    APP_PASSWORD = "password_aplikasi_anda" # GANTI DENGAN APP PASSWORD GMAIL ANDA
    
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
'''
    
    if '/forgot-password' not in content:
        with open('backend/main.py', 'a', encoding='utf-8') as f:
            f.write(new_endpoint)
        print('Added /forgot-password endpoint successfully.')
    else:
        print('Endpoint already exists.')

add_forgot_password_endpoint()
