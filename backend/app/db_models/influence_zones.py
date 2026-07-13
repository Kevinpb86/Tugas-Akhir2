from sqlalchemy import (
    Column,
    Integer,
    Float,
    ForeignKey,
    DateTime,
)
from datetime import datetime

from app.config.database import Base


class InfluenceZone(Base):
    __tablename__ = "influence_zones"

    id = Column(
        Integer,
        primary_key=True,
        index=True
    )

    # mainshock yang membentuk zona pengaruh
    earthquake_id = Column(
        Integer,
        ForeignKey("earthquakes.id"),
        nullable=False,
        unique=True,
    )

    # Gardner-Knopoff window
    radius_km = Column(
        Float,
        nullable=False,
    )

    window_days = Column(
        Integer,
        nullable=False,
    )

    # validity period
    start_time = Column(
        DateTime,
        nullable=False,
    )

    end_time = Column(
        DateTime,
        nullable=False,
    )

    created_at = Column(
        DateTime,
        default=datetime.utcnow,
    )