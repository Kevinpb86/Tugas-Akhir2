from sqlalchemy import Column, Integer, Float, String, ForeignKey, DateTime
from datetime import datetime
from app.config.database import Base

## Create tabel for Random Forest ML result
class SeismicAnalysis(Base):
    __tablename__ = "seismic_analysis"

    id = Column(Integer, primary_key=True, index=True)

    earthquake_id = Column(Integer, ForeignKey("earthquakes.id"))

    # NND FEATURES
    log_n = Column(Float)
    log_t = Column(Float)
    log_r = Column(Float)
    dm = Column(Float)

    # ML RESULT
    prediction = Column(String(20))   # mainshock / aftershock
    probability = Column(Float)

    created_at = Column(DateTime, default=datetime.utcnow)

## Create tabel for earthquake cluster based RF ML result
class SeismicCluster(Base):
    __tablename__ = "seismic_cluster"

    id = Column(Integer, primary_key=True, index=True)

    child_id = Column(Integer, ForeignKey("earthquakes.id"))
    parent_id = Column(Integer, ForeignKey("earthquakes.id"))

    distance = Column(Float)  # NND value

    created_at = Column(DateTime, default=datetime.utcnow)