from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.config.database import get_db

from app.repositories.seismic_analysis_repo import (
    SeismicAnalysisRepository,
)

from app.api_schemas.cluster_schema import (
    ClusterResponse,
    ClusterChildResponse,
)

router = APIRouter(
    prefix="/clusters",
    tags=["Clusters"],
)


@router.get(
    "/{parent_id}",
    response_model=ClusterResponse,
)
def get_cluster(
    parent_id: int,
    db: Session = Depends(get_db),
):
    repo = SeismicAnalysisRepository(db)

    children = repo.get_children(parent_id)

    return ClusterResponse(
        parent_id=parent_id,
        children=[
            ClusterChildResponse(
                earthquake_id=item.earthquake_id,
                prediction=item.prediction,
                probability=item.probability,
            )
            for item in children
        ],
    )