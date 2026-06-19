import joblib
import pandas as pd
from app.config.logging import logger


class MLService:

    def __init__(
        self,
        model_path: str = "model/random_forest_model.pkl",
    ):
        self.model = joblib.load(model_path)

    def predict(
        self,
        log_n: float,
        log_t: float,
        log_r: float,
        dm: float,
    ):

        features = pd.DataFrame(
            [{
                "log_N+": log_n,
                "log_T+": log_t,
                "log_R+": log_r,
                "dm+": dm,
            }]
        )

        prediction = self.model.predict(features)[0]

        probability = self.model.predict_proba(
            features
        )[0][prediction]

        label_map = {
            0: "Mainshock",
            1: "Aftershock",
        }

        logger.info(
            "Prediction result: prediction=%s probability=%.4f",
            prediction,
            probability
        )
        return {
            "prediction": label_map[prediction],
            "probability": float(probability),
        }