from pydantic import BaseModel, EmailStr

class UserRegister(BaseModel):
    full_name: str
    email: EmailStr
    password: str

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class GoogleAuthRequest(BaseModel):
    email: str
    full_name: str
    google_id: str

class FacebookAuthRequest(BaseModel):
    access_token: str

class ForgotPasswordRequest(BaseModel):
    email: EmailStr