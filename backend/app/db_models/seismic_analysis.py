from sqlalchemy import (
    Column,
    Integer,
    Float,
    String,
    ForeignKey,
    DateTime,
)
from datetime import datetime

from app.config.database import Base


class SeismicAnalysis(Base):
    __tablename__ = "seismic_analysis"

    id = Column(Integer, primary_key=True, index=True)

    earthquake_id = Column(
        Integer,
        ForeignKey("earthquakes.id"),
        nullable=False,
    )

    # NND RESULT
    parent_earthquake_id = Column(
        Integer,
        ForeignKey("earthquakes.id"),
        nullable=True,
    )

    n_value = Column(Float)

    log_n = Column(Float)
    log_t = Column(Float)
    log_r = Column(Float)

    dm = Column(Float)

    # ML RESULT
    prediction = Column(String(20))
    probability = Column(Float)

    created_at = Column(
        DateTime,
        default=datetime.utcnow,
    )