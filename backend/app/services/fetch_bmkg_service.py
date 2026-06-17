import hashlib
import requests

from datetime import datetime, timezone
from dateutil import parser

from app.db_models.earthquake import Earthquake
from app.auth.security import generate_fingerprint


class BMKGService:

    URL = "https://data.bmkg.go.id/DataMKG/TEWS/gempadirasakan.json"

    def fetch_latest(self):
        response = requests.get(self.URL, timeout=10)
        response.raise_for_status()

        return response.json()

    def transform(self, raw: dict):

        earthquakes = raw["Infogempa"]["gempa"]

        results = []

        now = datetime.now(timezone.utc).replace(tzinfo=None)

        for data in earthquakes:

            event_time = (parser.isoparse(data["DateTime"]).astimezone(timezone.utc).replace(tzinfo=None))

            # filter future earthquake
            if event_time > now:
                continue

            lat, lon = map(
                float,
                data["Coordinates"].split(",")
            )

            magnitude = round(
                float(data["Magnitude"]),
                1
            )

            depth = round(
                float(
                    data["Kedalaman"].replace(" km", "")
                ),
                1
            )

            lat = round(lat, 3)
            lon = round(lon, 3)

            fingerprint = generate_fingerprint(
                event_time=event_time,
                latitude=lat,
                longitude=lon,
                magnitude=magnitude,
                depth=depth
            )

            eq = Earthquake(
                event_time=event_time,
                latitude=lat,
                longitude=lon,
                depth=depth,
                magnitude=magnitude,
                wilayah=data.get("Wilayah"),
                dirasakan=data.get("Dirasakan"),
                source="BMKG",
                status="pending",
                fingerprint=fingerprint
            )

            results.append(eq)

        return results