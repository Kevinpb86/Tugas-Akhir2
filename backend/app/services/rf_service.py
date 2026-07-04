import joblib
import pandas as pd
from app.config.logging import logger
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parents[2]
MODEL_PATH = BASE_DIR / "model" / "random_forest_model.pkl"

class MLService:

    def __init__(self):
        if not MODEL_PATH.exists():
            raise FileNotFoundError(
                f"Model tidak ditemukan: {MODEL_PATH}"
            )

        self.model = joblib.load(MODEL_PATH)

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