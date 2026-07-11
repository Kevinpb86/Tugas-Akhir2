from sqlalchemy import Column, Integer, Float, String
from app.config.database import Base

class ZonaGPS(Base):
    __tablename__ = "zona_gps"

    id = Column(Integer, primary_key=True, index=True)
    
    # Koordinat grid berdasarkan data CSV
    lat_grid = Column(Float, nullable=False)
    lon_grid = Column(Float, nullable=False)
    
    # Kode klaster (Menggunakan String untuk mengantisipasi format campuran huruf/angka)
    kode_klaster = Column(String(50), nullable=False)


class RiskSource(Base):
    __tablename__ = "risk_sources"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    description = Column(String(200), nullable=False)
    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)
