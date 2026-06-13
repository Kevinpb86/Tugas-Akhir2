# DEVELOPMENT DOCUMENTATION — APLIKASI MITIGASI BENCANA AMANIN (TUGAS AKHIR)

## Konteks Proyek
Kalian membangun sistem **AMANIN** (Aplikasi Peringatan Dini dan Mitigasi Bencana Gempa Bumi & Cuaca) berbasis **Flutter (Frontend)** + **FastAPI (Backend)** + **MySQL (Database)**. 
Sistem ini menggunakan model Machine Learning untuk melakukan prediksi tingkat risiko gempa bumi (menggunakan SVM) dan mendeteksi anomali seismik.

**Fokus Utama:**
- Memindahkan proses data fetching dari API BMKG yang awalnya langsung dari Flutter (Client) agar dilewatkan melalui **Backend (Python FastAPI)**.
- Backend bertindak sebagai mediator: mengambil data BMKG, mengumpunkannya ke model ML (SVM & Anomali), dan mengembalikan hasil gabungan (data gempa + hasil prediksi) ke Flutter dalam satu format JSON yang bersih.
- Menjaga kebersihan repositori Git dengan melarang keras penempatan file `.ipynb` (Jupyter Notebook), file `.pkl`/`.keras` (Model ML), dan script utilitas di dalam folder Flutter client.

---

## Pembagian Modul

Semua anggota tim berkontribusi secara kolaboratif pada pengembangan frontend Flutter, riset machine learning, dan backend. Poin pembeda utama terletak pada proses deployment model ML ke dalam fitur aplikasi masing-masing sebagai berikut:

| Modul / Peran | Anggota Tim | Deskripsi & Scope Kerja |
| :--- | :--- | :--- |
| **Modul 1: Deploy SVM**<br>(Tingkat Risiko) | **Dava** | - Deploy model SVM (Support Vector Machine) ke backend.<br>- Mengklasifikasikan tingkat risiko gempa bumi (Rendah, Sedang, Tinggi) berdasarkan magnitudo, kedalaman, dan koordinat dari data BMKG & USGS. |
| **Modul 2: Deploy K-Means**<br>(Rekomendasi Edukasi) | **Kevin** | - Deploy model K-Means Clustering ke backend.<br>- Menganalisis aktivitas gempa bumi dan memetakan wilayah GPS kecamatan pengguna ke kluster risiko terdekat.<br>- Menyajikan rekomendasi artikel edukasi siaga bencana yang relevan. |
| **Modul 3: Deploy Isolation Forest**<br>& XGBoost (Anomali) | **Fuad** | - Deploy pipeline model Isolation Forest & XGBoost ke backend.<br>- Melakukan deteksi anomali seismisitas real-time berdasarkan parameter latitude, longitude, kedalaman, gap, dmin, nst, bulan, dan jam. |
| **Modul 4: Deploy Random Forest**<br>(Main/Aftershock) | **Gilang** | - Deploy model Random Forest berbasis Nearest-Neighbor ke backend.<br>- Mengklasifikasikan status kejadian gempa apakah merupakan gempa utama (Mainshock) atau gempa susulan (Aftershock) berdasarkan kemiripan spasial-temporal. |

*(Catatan: Model SVM untuk klasifikasi risiko BMKG/USGS dikembangkan secara bersama untuk kebutuhan backend umum).*

---

## Stack Teknis Standar (WAJIB SAMA)
*   **Mobile Client:** Flutter 3.x & Dart 3.x (State management bebas/sesuai kesepakatan, HTTP library: `http` package, Geolocation: `geolocator`)
*   **Backend Framework:** Python FastAPI (Uvicorn server, running on port `8000`)
*   **Database:** MySQL (port `3308`, nama database: `db_amanin`)
*   **Libraries ML (Backend):** `joblib`, `numpy`, `scikit-learn`
*   **Password Hashing:** `passlib` (Bcrypt)

---

## Struktur Folder Repositori (Clean Architecture)
```text
Tugas-Akhir2/
├── .gitignore                     # Menentukan file yang diabaikan Git di root
├── README.md                      # File pengenalan Project
├── DevDocs.md                     # File dokumentasi Development (Master Brief)
├── backend/                       # Direktori utama backend mobile app AMANIN
│   ├── app/
│   │   ├── api/                   # Route endpoint API (*.py)
│   │   ├── auth/                  # Logika verifikasi token JWT (*.py)
│   │   ├── services/              # Logika bisnis & preprocessing data (*.py)
│   │   ├── models/                # Skema database (*.py)
│   │   └── config/                # Env, config db, setup.sql
│   ├── ml_models/                 # Model ML hasil ekspor (.pkl)
│   ├── main.py                    # File entrypoint utama backend
│   └── requirements.txt           # Library dependensi python backend
└── amanin/                        # Direktori utama mobile app AMANIN
    ├── android/                   # Build & konfigurasi aplikasi Android (Gradle, manifest, dll)
    ├── assets/                    # Resource statis aplikasi
    │   └── images/                # Gambar (logo, ilustrasi, UI assets)
    ├── ios/                       # Build & konfigurasi aplikasi iOS (Xcode project)
    ├── lib/                       # Core source code Flutter
    │   ├── services/              # API request ke backend (*.dart)
    │   ├── utils/                 # Utility & helper function (*.dart)
    │   └── *.dart                 # Halaman UI (main, login, home)
    └── .gitignore                 # Mengabaikan build/ dan .dart_tool/
```

*(Catatan: Folder `machine_learning/` berisi riset & training notebook ditempatkan di luar repositori Git atau di-ignore agar tidak mengotori repositori produksi).*

---

## Skema Database Global (`db_amanin`)

### Tabel `users`
```sql
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## Logic Penting & Endpoint Backend ML (Wajib Ada)

### 6.1. Aliran Data Gempa Terpusat (Mediator)
Aplikasi Flutter melakukan request ke backend FastAPI. Backend menembak API BMKG, mengambil respon JSON eksternal, melakukan preprocessing, memanggil model ML masing-masing fitur, lalu mengembalikan satu respon gabungan yang bersih ke Flutter.

### 6.2. Fitur 1 (Dava) - Klasifikasi Tingkat Risiko (SVM)
Mengklasifikasikan risiko gempa bumi (Rendah, Sedang, Tinggi) berdasarkan magnitudo, kedalaman, dan koordinat.
*   **Endpoint:** `POST /predict`
*   **Preprocessing:** Manual Min-Max Scaling berdasarkan batas dataset training:
    - BMKG Min `[1.0, 1.0, -7.998, 106.0]`, Max `[7.191, 649.067, -5.501, 108.998]`

### 6.3. Fitur 2 (Kevin) - Rekomendasi Edukasi (K-Means)
Mengelompokkan daerah bencana gempa bumi berdasarkan magnitude, kedalaman, dan koordinat.
*   **Endpoint:** `POST /predict-edukasi`
*   **Logic:** Backend mencocokkan koordinat GPS kecamatan pengguna ke cluster risiko terdekat untuk menampilkan artikel edukasi mitigasi bencana yang relevan.

### 6.4. Fitur 3 (Fuad) - Deteksi Anomali Seismisitas (Isolation Forest & XGBoost)
Mendeteksi anomali seismisitas berdasarkan parameter spasial dan temporal (gap, dmin, nst, kedalaman, bulan, jam).
*   **Endpoint:** `POST /predict-anomali`
*   **Logic:** Respon mengembalikan status `is_anomali` (True/False) dan confidence score.

### 6.5. Fitur 4 (Gilang) - Klasifikasi Main/Aftershock (Random Forest)
Mengklasifikasikan status gempa apakah merupakan gempa utama (Mainshock) atau gempa susulan (Aftershock) berdasarkan kesamaan spasial-temporal dengan gempa besar sebelumnya menggunakan Random Forest.
*   **Endpoint:** `POST /predict-shock`

---

## Standar Response API

### 1. Register / Login (`POST /register` & `POST /login`)
*   **Success Response:**
    ```json
    {
      "message": "Login berhasil!",
      "user_id": 1,
      "full_name": "Dava Ihza",
      "email": "dava@mail.com"
    }
    ```
*   **Error Response (401 / 400):**
    ```json
    {
      "detail": "Email atau password salah!"
    }
    ```

### 2. Prediksi Risiko Gempa (`POST /predict`)
*   **Request Body:**
    *   *Catatan*: Koordinat `latitude` dan `longitude` bersifat opsional jika `location_name` disertakan.
    ```json
    {
      "magnitude": 5.2,
      "depth": 10.0,
      "latitude": -6.9,           // Opsional jika ada location_name
      "longitude": 107.6,         // Opsional jika ada location_name
      "location_name": "Lembang", // Opsional (pencarian lokasi ramah pengguna)
      "source": "bmkg"
    }
    ```
*   **Success Response:**
    ```json
    {
      "risk_level": "Sedang",
      "prediction_code": 1,
      "confidence": 0.8421,
      "latitude": -6.82,          // Koordinat terdeteksi (geocoded)
      "longitude": 107.62         // Koordinat terdeteksi (geocoded)
    }
    ```

---

## Template Prompt AI (WAJIB DIPAKAI UNTUK CODING)

Saat menggunakan AI Agent (seperti Antigravity, Claude, atau ChatGPT), salin template instruksi berikut di awal sesi percakapan agar AI paham batas arsitektur kita:

```text
Halo! Saya sedang mengembangkan proyek Tugas Akhir bernama AMANIN
menggunakan Flutter (Client) + FastAPI (Backend Python) + MySQL.

Patuhi aturan arsitektur berikut secara ketat:
1. Stack Teknis: Flutter 3.x (Dart), FastAPI (Python 3.10), MySQL (Port 3308).
2. Clean Workspace: Jangan pernah membuat berkas Jupyter Notebook (.ipynb),
   berkas model (.pkl/.keras), atau script Python pembantu di dalam
   folder frontend 'amanin/'.
3. Data Flow: Semua data gempa bumi eksternal harus dilewatkan melalui
   Backend FastAPI sebagai mediator, bukan langsung ditembak dari Flutter
   ke BMKG. Backend akan memproses data BMKG + melakukan prediksi
   model ML sebelum mengirimkannya ke Flutter.
4. Struktur Folder Project:
   - Frontend berada di: /amanin
   - Backend berada di: /backend
   - Riset ML/Notebook berada di: /machine_learning

Sekarang, saya sedang mengerjakan:
[TULIS MODUL YANG INGIN DIKERJAKAN, MISAL: "Refaktor endpoint gempa di backend
dan di Flutter"]

Tolong bantu saya untuk membuat:
[TULIS PERMINTAAN SPESIFIK KAMU DI SINI]
```
