import pandas as pd
from app.config.database import SessionLocal
from app.db_models.earthquake import Earthquake
from app.utils.time_utils import datetime_to_datenum


def load_data_from_db():
    db = SessionLocal()

    try:
        rows = db.query(Earthquake).all()

        data = [
            {
                "id": r.id,
                "event_time": r.event_time,
                "time": r.time,
                "latitude": r.latitude,
                "longitude": r.longitude,
                "magnitude": r.magnitude,
                "depth": r.depth,
                "fingerprint": r.fingerprint,
            }
            for r in rows
        ]

        return pd.DataFrame(data)

    finally:
        db.close()


def validate_nnd_from_db():
    df = load_data_from_db()

    print("\n==============================")
    print("   NND DB VALIDATION REPORT")
    print("==============================\n")
    print(df["event_time"])
    # -----------------------------
    # 1. DUPLICATE CHECK
    # -----------------------------
    dup_event = df.duplicated(
        subset=["event_time", "latitude", "longitude", "magnitude", "depth"],
        keep=False
    ).sum()

    print(f"[1] Duplicate events: {dup_event}")

    # -----------------------------
    # 2. FINGERPRINT DUPLICATE
    # -----------------------------
    dup_fp = df["fingerprint"].duplicated().sum()
    print(f"[2] Duplicate fingerprint: {dup_fp}")

    # -----------------------------
    # 3. TIME SORT CHECK
    # -----------------------------
    sorted_check = df["event_time"].is_monotonic_increasing
    print(f"[3] Event time sorted: {sorted_check}")

    # -----------------------------
    # 4. ZERO DISTANCE CHECK (SELF LINK)
    # -----------------------------
    zero_self = 0  # DB version tidak punya i+, jadi hanya indikasi

    print(f"[4] Self-parent (cannot detect exactly in DB view): {zero_self}")

    # -----------------------------
    # 5. TIME PRECISION CHECK
    # -----------------------------
    frac_std = (df["time"] % 1).std()
    print(f"[5] Time fractional std: {frac_std:.8f}")

    print("\n==============================")
    print("        END REPORT")
    print("==============================\n")


if __name__ == "__main__":
    validate_nnd_from_db()