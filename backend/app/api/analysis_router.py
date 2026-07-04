from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.config.database import get_db
from app.repositories.seismic_analysis_repo import SeismicAnalysisRepository
from app.db_models.earthquake import Earthquake
from app.api_schemas.analysis_schema import (
    NetworkResponse,
    NetworkNode,
    NetworkEdge
)

router = APIRouter(
    prefix="/earthquakes",
    tags=["Analysis"],
)


@router.get("/network", response_model=NetworkResponse)
def get_network(
    days: int = 30,
    db: Session = Depends(get_db),
):

    repo = SeismicAnalysisRepository(db)

    # ==================================================
    # 1. MAIN QUERY (Earthquake + Analysis)
    # ==================================================
    rows = repo.get_network(days)
    # rows = [(Earthquake, SeismicAnalysis)]

    nodes_map = {}
    parent_ids = set()
    edges = []

    # ==================================================
    # 2. BUILD CHILD NODES + COLLECT PARENTS + EDGES
    # ==================================================
    for eq, analysis in rows:

        # -------------------------
        # NODE (child event)
        # -------------------------
        nodes_map[eq.id] = {
            "id": eq.id,
            "event_time": eq.event_time,
            "latitude": eq.latitude,
            "longitude": eq.longitude,
            "depth": eq.depth,
            "magnitude": eq.magnitude,
            "wilayah": eq.wilayah,
            "dirasakan": eq.dirasakan,
            "prediction": analysis.prediction if analysis else None,
            "probability": analysis.probability if analysis else None,
        }

        # -------------------------
        # EDGE + collect parent ids
        # -------------------------
        if analysis and analysis.parent_earthquake_id:

            parent_ids.add(analysis.parent_earthquake_id)

            edges.append({
                "source": analysis.parent_earthquake_id,
                "target": eq.id
            })

    # ==================================================
    # 3. BULK FETCH PARENTS (NO N+1)
    # ==================================================
    if parent_ids:

        parent_rows = (
            db.query(Earthquake)
            .filter(Earthquake.id.in_(parent_ids))
            .all()
        )

        for p in parent_rows:

            # inject parent node only if missing
            if p.id not in nodes_map:
                nodes_map[p.id] = {
                    "id": p.id,
                    "event_time": p.event_time,
                    "latitude": p.latitude,
                    "longitude": p.longitude,
                    "depth": p.depth,
                    "magnitude": p.magnitude,
                    "wilayah": p.wilayah,
                    "dirasakan": p.dirasakan,
                    "prediction": None,
                    "probability": None,
                }

    # ==================================================
    # 4. SORT NODES (biar stable di frontend)
    # ==================================================
    nodes = sorted(
        nodes_map.values(),
        key=lambda x: x["event_time"]
    )

    # ==================================================
    # 5. RESPONSE
    # ==================================================
    return NetworkResponse(
        nodes=nodes,
        edges=edges
    )