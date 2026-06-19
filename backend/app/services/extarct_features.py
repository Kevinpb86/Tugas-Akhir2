import numpy as np

from app.db_models.earthquake import Earthquake


class NNDService:
    def __init__(
        self,
        db,
        fractal_dimension: float = 1.6,
        w: float = 1.03,
    ):
        self.db = db
        self.fractal_dimension = fractal_dimension
        self.w = w

    def compute(self, earthquake: Earthquake):
        """
        Identify nearest neighbor of a given event.

        Parameters
        ----------
        earthquake : Earthquake
            Event to analyze.

        Returns
        -------
        dict | None
            {
                "parent_earthquake_id": int,
                "N+": float,
                "T+": float,
                "R+": float,
                "dm+": float,
                "log_N+": float,
                "log_T+": float,
                "log_R+": float,
            }
        """

        neighbors = (
            self.db.query(Earthquake)
            .filter(
                Earthquake.event_time < earthquake.event_time
            )
            .order_by(Earthquake.event_time.asc())
            .all()
        )

        # N-1 events will have a neighbor
        if not neighbors:
            return None

        best_parent = None
        best_n = np.inf
        best_t = None
        best_r = None
        best_dm = None

        for parent in neighbors:

            # -- rescaled time
            t_plus = (
                earthquake.event_time - parent.event_time
            ).total_seconds() / 86400.0

            t_plus = t_plus * np.power(
                10,
                -0.5 * self.w * parent.magnitude
            )

            # -- rescaled distance (epicentral!)
            epicentral_distance = np.sqrt(
                np.power(
                    earthquake.latitude - parent.latitude,
                    2,
                )
                + np.power(
                    earthquake.longitude - parent.longitude,
                    2,
                )
            )

            r_plus = np.power(
                epicentral_distance,
                self.fractal_dimension,
            ) * np.power(
                10,
                -0.5 * self.w * parent.magnitude
            )

            # -- magnitude difference
            dm_plus = parent.magnitude - earthquake.magnitude

            # -- nearest-neighbor distance
            n_plus = t_plus * r_plus

            # -- find the nearest neighbor which minimize eta
            if n_plus < best_n:
                best_parent = parent
                best_n = n_plus
                best_t = t_plus
                best_r = r_plus
                best_dm = dm_plus

            if best_r == 0:
                print(
                    f"Zero distance detected: "
                    f"child={earthquake.id}, "
                    f"parent={best_parent.id}"
                )

        EPS = 1e-12

        log_n = np.log10(max(best_n, EPS))
        log_t = np.log10(max(best_t, EPS))
        log_r = np.log10(max(best_r, EPS))

        return {
            "parent_earthquake_id": best_parent.id,
            "N+": float(best_n),
            "T+": float(best_t),
            "R+": float(best_r),
            "dm+": float(best_dm),
            "log_N+": float(log_n),
            "log_T+": float(log_t),
            "log_R+": float(log_r),
        }