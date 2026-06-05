# 🌍 Amanin - Aplikasi Cerdas Tanggap Bencana & Gempa Bumi

<div align="center">
  <h3>🎉 Selamat Datang di "Amanin" (Proyek Tugas Akhir)</h3>
  <p><i>Solusi Cerdas, Cepat, dan Tepat untuk Mitigasi Bencana di Genggaman Anda.</i></p>
  <br>
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white" alt="Python" />
  <img src="https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white" alt="FastAPI" />
  <img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android" />
  <img src="https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white" alt="iOS" />
</div>

<br>

**Amanin** *(nama sementara)* adalah sebuah aplikasi inovatif berbasis _mobile_ yang berfokus pada mitigasi bencana, pemantauan status gempabumi secara *real-time*, prakiraan cuaca lokal, serta pusat edukasi keselamatan terpadu untuk masyarakat Indonesia. 

Aplikasi ini dirancang khusus dengan antarmuka (UI/UX) yang sangat modern, bersih, intuitif, dan *user-friendly*, sehingga dapat memastikan setiap penggunanya selangkah lebih tanggap dan siap saat menghadapi keadaan darurat alam.

---

## ✨ Ikhtisar Halaman & Fitur Aplikasi Utama (Core Features)

Aplikasi *Amanin* memuat berbagai *screen* utama yang menyediakan integrasi layanan komplit, mencakup:

🏠 **1. Beranda Terpadu & Interaktif (Dashboard/Home)**
Halaman utama (*Beranda*) menghadirkan segala informasi vital secara *at-a-glance* (sekilas) kepada pengguna:
- **Peringatan Dini (Early Warning):** Notifikasi guncangan darurat beserta status aman pada zona pengguna.
- **Card Gempa Terkini:** Ringkasan peristiwa gempa sonder *detail* dengan ikon peringatan darurat.
- **Ringkasan Cuaca Lokal:** Terdapat indikator visibilitas, cuaca harian, dan rekomendasi aktivitas cerdas dalam format UI modern.
- **Berita Kebencanaan & Section Survival:** Pusat berita terbaru (API Live News Terintegrasi) serta pengingat mengenai *Survival Kit*.

🚨 **2. Peringatan & Informasi Gempa Real-Time**
Pusat kontrol pemantauan data gempabumi untuk meningkatkan respon siaga pengguna:
- Peta *interaktif* Guncangan.
- Filter cerdas (Gempa Terkini, Mangitudo ≥ 5.0, Gempa Dirasakan).
- Tampilan riwayat riil dan detail seperti koordinat lokasi, kedalaman episenter, dan intensitas skala *MMI*.
- *Call to Action* instan ("Saya juga merasakannya").

🌤️ **3. Pemantauan Cuaca Berbasis Geofisika**
Layanan cuaca dinamis yang menyesuaikan dengan geolokasi yang dihidupkan:
- Prakiraan *"Cuaca Mingguan"* secara presisi per hari/jam.
- Status iklim komplit (Suhu, Kelembaban, Tekanan Udara, Jarak Pandang, Kecepatan Angin).

📚 **4. Pusat Edukasi Bencana Edukatif & Multimedia**
- **Video Edukasi Interaktif**: Pemutaran video penanggulangan prabencana langsung dalam *interface* aplikasi.
- **Filter Chip Cerdas**: Materi bacaan komprehensif berhias UI *Glassmorphism*.
- **Panduan Standar Keselamatan Ruang**: Tips mitigasi khusus lingkungan sekitar.

🧠 **5. Klasifikasi Tingkat Kerentanan Seismik (Model Machine Learning)**
Fitur *eksklusif* pengembangan Tugas Akhir (Terbaru!):
- **Integrasi Penuh Machine Learning**: Klasifikasi berbasis **Support Vector Machine (SVM)** yang *real-time* terhubung ke backend Python FastAPI.
- **Dual Model Inference**: Memilih sumber data prediksi dari model dataset **BMKG (Lokal)** atau **USGS (Global)**.
- **Sistem Prediksi Skor Risiko**: Tingkatan **Rendah**, **Sedang**, dan **Tinggi** dengan pra-pemrosesan Normalisasi Min-Max.

🛡️ **6. Edukasi Perlindungan Aset & Peralatan Survival Kritis**
- **Asuransi "Pro-Siaga":** Integrasi panel proteksi finansial.
- **Toko Mitigasi (*Toko Shop*)**: Menjual beragam produk krusial untuk bencana.

---

## 👨‍💻 Tim Pengembang & Riwayat Kolaborasi (Team & Branches)

Proyek ini merupakan hasil dedikasi kerja sama tim yang luar biasa. Berikut adalah struktur kolaborasi dan pembagian *branch* kami di GitHub:

| Kontributor | Peran / Fokus | Branch Aktif |
| :--- | :--- | :--- |
| **Dava Ihza Bagus S** (`Davaihza`) | **Lead UI/UX Designer (Figma), Keseluruhan Frontend**, ML Integration, API Development, & Bug Fixes | `Dava-Ihza`, `main` |
| **Kevin** (`Kevinpb86`) | Version Control Management & Supporting Tasks | `kevin_branch`, `main` |
| **Fuad Nugraha** (`FuadNugraha25`) | Supporting Feature Implementation | `Fuad_branch` |

### 🚀 Hasil Push & Pencapaian Terkini (Changelog & History)
Kami aktif memelihara *"History"* kolaborasi. Beberapa pembaruan keren yang baru saja berhasil di-*push* dan di-*merge* ke dalam *repository* meliputi:

*   🎉 **[Davaihza] Integrasi Machine Learning SVM (BMKG & USGS) ke Backend FastAPI & Flutter:** Membangun *endpoint* Python untuk menerima *request* magnitudo dan kedalaman dari Flutter, mengembalikannya sebagai tingkat risiko Rendah/Sedang/Tinggi melalui `uvicorn` (Diselesaikan melalui sinkronisasi AI Pair Programming yang epik!).
*   🔧 **[Davaihza] Bug Fix & Refactoring UI Dart Analyzer:** Menghilangkan peringatan (*warnings*) dari Dart Analyzer, contohnya mengganti `withOpacity` menjadi `withAlpha` agar kode berjalan modern, bersih, dan optimal.
*   📰 **[Davaihza] Update Tampilan Berita & API News Data:** Memperbarui antarmuka berita statis menjadi dinamis *(Real-time via RapidAPI)*, dilengkapi integrasi ke halaman Detail Berita yang *fresh*.
*   🤝 **[Kevinpb86] Push & Sinkronisasi Branch Utama:** Memastikan struktur file dasar stabil sebelum *merging* *pull requests* antar *branch*.
*   ✨ **[Davaihza] Optimalisasi Estetika Aplikasi Keseluruhan:** Mendesain mandiri dari awal di Figma, menerjemahkannya ke Flutter, menambahkan ruang putih (*whitespace*) elegan, memperbaiki *margin*, dan menyeimbangkan *text bounds* untuk menciptakan desain *Glassmorphism* yang memukau.

---

## 🛠️ Arsitektur & Teknologi

Proyek ini dibangun menggunakan landasan modern pada pengembangan *mobile cross-platform*:

- **Frontend Framework:** [Flutter](https://flutter.dev/) (Dart)
- **Backend API & ML Engine:** [FastAPI](https://fastapi.tiangolo.com/) (Python) dengan Scikit-Learn (SVM) dan Joblib.
- **Paradigma Antarmuka UI/UX:** *Material Design & Custom Styling* bertemakan minimalis-futuristik. Dilengkapi *Drop & Inner Shadows*, mikro-interaksi responsif, dan *glassmorphism*.
- **Sistem Version Control:** *Git* & *GitHub*.

---

## ⚙️ Eksekusi dan Penjalanan Simulasi Lokal

Ingin mencoba meng-compile antarmuka *Amanin* memukau ini di emulator?

1. **Clone Repositori:**
   ```bash
   git clone https://github.com/Kevinpb86/Tugas-Akhir2.git
   ```

2. **Masuk ke Direktori & Install Dependensi Flutter:**
   ```bash
   cd Tugas-Akhir2/amanin
   flutter pub get
   ```

3. **Menjalankan Backend ML FastAPI (Wajib untuk Klasifikasi Seismik):**
   ```bash
   cd Tugas-Akhir2/amanin/backend
   pip install -r requirements.txt
   python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
   ```

4. **Kompilasi Aplikasi Flutter:**
   Pastikan emulator atau perangkat sudah terkoneksi dengan baik.
   ```bash
   flutter run
   ```

---

> **⚠️ Catatan Ekstra (Academic Context):** Repositori pada komitmen (`branch: Dava-Ihza`) ini dimanfaatkan sebagai sub-wadah *Development Sandbox* / **Prototipe Purwarupa UI/UX** dari penelitian dan perancangan Akademik Tugas Akhir. Jika Anda mendapati penempatan statis, hal tersebut bertujuan mengimplementasikan kaidah visualnya terlebih dahulu sesuai dengan gagasan metodologi penelitian.
