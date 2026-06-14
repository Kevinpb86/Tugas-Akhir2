from sqlalchemy import Column, Integer, Float, String, ForeignKey, DateTime
from datetime import datetime
from app.config.database import Base

## Create tabel for earthquake data from API BMKG
class Earthquake(Base):
    __tablename__ = "earthquakes"

    id = Column(Integer, primary_key=True, index=True)

    event_time = Column(DateTime, nullable=False)

    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)

    depth = Column(Float, nullable=False)
    magnitude = Column(Float, nullable=False)

    source = Column(String(20), default="BMKG")

    status = Column(String(20), default="pending")  
    # pending → processed (setelah NND + RF)

    created_at = Column(DateTime, default=datetime.utcnow)