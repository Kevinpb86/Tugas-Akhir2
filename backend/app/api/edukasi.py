import os
import requests
from datetime import datetime
from fastapi import APIRouter, HTTPException, Query, Depends
from sqlalchemy.orm import Session
from app.config.database import get_db
from app.api_schemas.edukasi_schema import EdukasiRequest, EdukasiResponse
from app.services.edukasi_service import EdukasiService

router = APIRouter()

YOUTUBE_API_KEY = os.getenv("YOUTUBE_API_KEY")

@router.get("/videos")
def get_edukasi_videos(page_token: str = Query(None, alias="pageToken")):
    if not YOUTUBE_API_KEY:
        raise HTTPException(status_code=500, detail="YOUTUBE_API_KEY is not configured.")

    # Search for mitigation videos on youtube
    url = "https://www.googleapis.com/youtube/v3/search"
    params = {
        "part": "snippet",
        "q": "mitigasi bencana gempa bumi bmkg",
        "type": "video",
        "key": YOUTUBE_API_KEY,
        "maxResults": 10
    }
    
    if page_token:
        params["pageToken"] = page_token

    try:
        response = requests.get(url, params=params)
        response.raise_for_status()
        data = response.json()

        videos = []
        for item in data.get("items", []):
            snippet = item.get("snippet", {})
            videos.append({
                "id": item.get("id", {}).get("videoId"),
                "title": snippet.get("title"),
                "description": snippet.get("description"),
                "channel": snippet.get("channelTitle"),
                "thumbnail": snippet.get("thumbnails", {}).get("high", {}).get("url") or snippet.get("thumbnails", {}).get("medium", {}).get("url")
            })

        result = {
            "status": "success",
            "data": videos,
            "nextPageToken": data.get("nextPageToken")
        }

        # Jika ini adalah permintaan halaman pertama (tidak ada page_token)
        # Hitung 'Video of the Day' menggunakan rumus modulus hari
        if not page_token and len(videos) > 0:
            day_index = datetime.now().toordinal()
            featured_index = day_index % len(videos)
            result["featuredVideo"] = videos[featured_index]
            
            # Hapus featured video dari list agar tidak muncul ganda
            # Namun kita ambil copy agar index tidak kacau
            filtered_videos = []
            for i, v in enumerate(videos):
                if i != featured_index:
                    filtered_videos.append(v)
            result["data"] = filtered_videos

        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/waspada", response_model=EdukasiResponse)
def check_waspada(req: EdukasiRequest, db: Session = Depends(get_db)):
    try:
        service = EdukasiService(db)
        result = service.get_edukasi_status(req.latitude, req.longitude)
        
        return EdukasiResponse(
            status=result["status"],
            message=result["message"],
            data=result["data"]
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Terjadi kesalahan saat memproses data: {str(e)}")
