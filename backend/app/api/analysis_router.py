from datetime import datetime, timedelta
import requests

from fastapi import APIRouter, Depends
from fastapi.responses import Response
from sqlalchemy.orm import Session

from app.config.database import get_db

from app.db_models.earthquake import Earthquake
from app.db_models.seismic_analysis import SeismicAnalysis

from app.api_schemas.analysis_schema import (
    MapResponse,
    EarthquakeMapNode,
)


router = APIRouter(
    prefix="/earthquakes",
    tags=["Analysis"],
)


BULAN_ID = ["Jan", "Feb", "Mar", "Apr", "Mei", "Jun",
            "Jul", "Agu", "Sep", "Okt", "Nov", "Des"]


def _format_eq_bmkg(eq: Earthquake) -> dict:
    event_time = eq.event_time
    wib = event_time + timedelta(hours=7)
    lat = eq.latitude
    lon = eq.longitude
    return {
        "Tanggal": f"{wib.day:02d} {BULAN_ID[wib.month - 1]} {wib.year}",
        "Jam": wib.strftime("%H:%M:%S WIB"),
        "DateTime": event_time.isoformat() + "+00:00",
        "Coordinates": f"{lat},{lon}",
        "Lintang": f"{abs(lat):.2f} {'LS' if lat < 0 else 'LU'}",
        "Bujur": f"{abs(lon):.2f} {'BT' if lon >= 0 else 'BB'}",
        "Magnitude": str(eq.magnitude),
        "Kedalaman": f"{eq.depth:g} km",
        "Wilayah": eq.wilayah or "",
        "Potensi": "",
        "Dirasakan": eq.dirasakan or "",
        "Shakemap": "",
    }


@router.get("/bmkg")
def get_bmkg_earthquakes(
    limit: int = 50,
    db: Session = Depends(get_db),
):
    """
    Mengambil data gempa dari database backend. Fallback ke API BMKG jika DB kosong.
    """
    try:
        rows = (
            db.query(Earthquake)
            .order_by(Earthquake.event_time.desc())
            .limit(limit)
            .all()
        )
        if rows:
            gempa_list = [_format_eq_bmkg(eq) for eq in rows]
            return {"Infogempa": {"gempa": gempa_list}}
    except Exception as e:
        print(f"Error querying earthquake DB: {e}")

    try:
        res = requests.get("https://data.bmkg.go.id/DataMKG/TEWS/gempaterkini.json", timeout=10)
        if res.status_code == 200:
            return res.json()
    except Exception as e:
        print(f"Fallback to BMKG external API failed: {e}")

    return {"Infogempa": {"gempa": []}}


@router.get("/latest")
def get_latest_earthquake(
    db: Session = Depends(get_db),
):
    """
    Mengambil 1 data gempa terbaru dari database backend.
    """
    try:
        eq = (
            db.query(Earthquake)
            .order_by(Earthquake.event_time.desc())
            .first()
        )
        if eq:
            return {"Infogempa": {"gempa": _format_eq_bmkg(eq)}}
    except Exception as e:
        print(f"Error querying latest earthquake DB: {e}")

    try:
        res = requests.get("https://data.bmkg.go.id/DataMKG/TEWS/autogempa.json", timeout=10)
        if res.status_code == 200:
            return res.json()
    except Exception as e:
        print(f"Fallback to autogempa failed: {e}")

    return {"Infogempa": {"gempa": {}}}


@router.get("/felt")
def get_felt_earthquakes(
    limit: int = 15,
    db: Session = Depends(get_db),
):
    """
    Mengambil data gempa dirasakan dari database backend.
    """
    try:
        rows = (
            db.query(Earthquake)
            .filter(Earthquake.dirasakan.isnot(None), Earthquake.dirasakan != "")
            .order_by(Earthquake.event_time.desc())
            .limit(limit)
            .all()
        )
        if not rows:
            rows = (
                db.query(Earthquake)
                .order_by(Earthquake.event_time.desc())
                .limit(limit)
                .all()
            )
        if rows:
            gempa_list = [_format_eq_bmkg(eq) for eq in rows]
            return {"Infogempa": {"gempa": gempa_list}}
    except Exception as e:
        print(f"Error querying felt earthquake DB: {e}")

    try:
        res = requests.get("https://data.bmkg.go.id/DataMKG/TEWS/gempadirasakan.json", timeout=10)
        if res.status_code == 200:
            return res.json()
    except Exception as e:
        print(f"Fallback to gempadirasakan failed: {e}")

    return {"Infogempa": {"gempa": []}}


@router.get("/download-history")
def download_history_csv(
    filter_type: int = 0,
    db: Session = Depends(get_db),
):
    """
    Mengunduh dataset riwayat gempa langsung sebagai file CSV ke perangkat pengguna.
    """
    query = db.query(Earthquake).order_by(Earthquake.event_time.desc())
    if filter_type == 1:
        query = query.filter(Earthquake.magnitude >= 5.0)

    rows = query.limit(500).all()

    output = ["Tanggal,Jam,Lintang,Bujur,Magnitude,Kedalaman,Wilayah,Potensi,Dirasakan,Anomali"]
    for eq in rows:
        formatted = _format_eq_bmkg(eq)
        fields = [
            formatted["Tanggal"],
            formatted["Jam"],
            formatted["Lintang"],
            formatted["Bujur"],
            formatted["Magnitude"],
            formatted["Kedalaman"],
            formatted["Wilayah"],
            formatted["Potensi"],
            formatted["Dirasakan"],
            "Tidak",
        ]
        escaped_fields = [f'"{str(field).replace(chr(34), chr(34)+chr(34))}"' for field in fields]
        output.append(",".join(escaped_fields))

    csv_content = "\n".join(output)
    filename = f"riwayat_gempa_{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}.csv"

    return Response(
        content=csv_content,
        media_type="text/csv",
        headers={
            "Content-Disposition": f"attachment; filename={filename}"
        },
    )


@router.get(
    "/map",
    response_model=MapResponse,
)
def get_map(
    days: int = 30,
    db: Session = Depends(get_db),
):

    cutoff = (
        datetime.utcnow()
        - timedelta(days=days)
    )


    rows = (
        db.query(
            Earthquake,
            SeismicAnalysis
        )
        .outerjoin(
            SeismicAnalysis,
            SeismicAnalysis.earthquake_id
            == Earthquake.id
        )
        .filter(
            Earthquake.event_time >= cutoff
        )
        .order_by(
            Earthquake.event_time.asc()
        )
        .all()
    )


    earthquakes = []

    for eq, analysis in rows:

        earthquakes.append(
            EarthquakeMapNode(
                id=eq.id,
                event_time=eq.event_time,

                latitude=eq.latitude,
                longitude=eq.longitude,

                depth=eq.depth,
                magnitude=eq.magnitude,

                wilayah=eq.wilayah,
                dirasakan=eq.dirasakan,

                prediction=(
                    analysis.prediction
                    if analysis
                    else None
                ),

                probability=(
                    analysis.probability
                    if analysis
                    else None
                ),
            )
        )


    return MapResponse(
        earthquakes=earthquakes,
    )