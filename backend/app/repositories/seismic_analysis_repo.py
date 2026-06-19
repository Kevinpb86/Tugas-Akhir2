from app.db_models.seismic_analysis import SeismicAnalysis


class SeismicAnalysisRepository:

    def __init__(self, db):
        self.db = db

    def get_by_earthquake_id(
        self,
        earthquake_id: int,
    ):
        return (
            self.db.query(SeismicAnalysis)
            .filter(
                SeismicAnalysis.earthquake_id == earthquake_id
            )
            .first()
        )

    def get_children(
        self,
        parent_id: int,
    ):
        return (
            self.db.query(SeismicAnalysis)
            .filter(
                SeismicAnalysis.parent_earthquake_id == parent_id
            )
            .all()
        )