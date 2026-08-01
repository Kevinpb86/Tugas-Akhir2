import os
from dotenv import load_dotenv

load_dotenv()

class Settings:
    DB_HOST = os.getenv("DB_HOST")
    DB_PORT = os.getenv("DB_PORT")
    DB_USER = os.getenv("DB_USER")
    DB_PASSWORD = os.getenv("DB_PASSWORD")
    DB_NAME = os.getenv("DB_NAME")

settings = Settings()

SENDER_EMAIL = os.getenv("SENDER_EMAIL", "email.anda@gmail.com")
APP_PASSWORD = os.getenv("APP_PASSWORD", "")

JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY", "fallback_secret_key_change_me")
JWT_EXPIRY_MINUTES = int(os.getenv("JWT_EXPIRY_MINUTES", "1440"))
