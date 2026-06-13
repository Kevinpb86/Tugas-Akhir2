import os
from dotenv import load_dotenv

# Load environment variables from .env in backend directory
dotenv_path = os.path.abspath(os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), '.env'))
load_dotenv(dotenv_path)

DB_CONFIG = {
    "host": os.getenv("DB_HOST", "localhost"),
    "user": os.getenv("DB_USER", "root"),
    "password": os.getenv("DB_PASSWORD", ""),
    "database": os.getenv("DB_DATABASE", "db_amanin"),
    "port": int(os.getenv("DB_PORT", 3308))
}

SENDER_EMAIL = os.getenv("SENDER_EMAIL", "email.anda@gmail.com")
APP_PASSWORD = os.getenv("APP_PASSWORD", "")
