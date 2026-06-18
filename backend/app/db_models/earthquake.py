from sqlalchemy import Column, Integer, Float, String, DateTime, Text
from datetime import datetime

from app.config.database import Base


class Earthquake(Base):
    __tablename__ = "earthquakes"

    id = Column(Integer, primary_key=True, index=True)

    # waktu gempa
    event_time = Column(DateTime, nullable=False, index=True)

    # koordinat
    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)

    # parameter fisik gempa
    depth = Column(Float, nullable=False)
    magnitude = Column(Float, nullable=False)

    # info BMKG (free text → pakai TEXT)
    dirasakan = Column(Text, nullable=True)
    wilayah = Column(Text, nullable=True)

    # kolom untuk pencegah duplikasi data 
    fingerprint = Column(
        String(40),
        unique=True,
        nullable=False,
        index=True
    )
    # metadata
    source = Column(String(50), default="BMKG")
    status = Column(String(20), default="pending")

    created_at = Column(DateTime, default=datetime.utcnow)