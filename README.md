# 🌍 Amanin - Aplikasi Cerdas Tanggap Bencana & Gempa Bumi

<div align="center">
  <h3>🎉 Selamat Datang di "Amanin" (Proyek Tugas Akhir)</h3>
  <br>
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
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
- **Berita Kebencanaan & Section Survival:** Pusat berita terbaru serta pengingat mengenai *Survival Kit* (Tas Siaga Bencana).

🚨 **2. Peringatan & Informasi Gempa Real-Time**
Pusat kontrol pemantauan data gempabumi untuk meningkatkan respon siaga pengguna:
- Peta *interaktif* Guncangan.
- Filter cerdas (Gempa Terkini, Mangitudo ≥ 5.0, Gempa Dirasakan).
- Tampilan riwayat riil dan detail seperti koordinat lokasi, kedalaman episenter, dan intensitas skala *MMI*.
- *Call to Action* instan ("Saya juga merasakannya").

🌤️ **3. Pemantauan Cuaca Berbasis Geofisika**
Layanan cuaca dinamis yang menyesuaikan dengan geolokasi yang dihidupkan:
- Prakiraan *"Cuaca Mingguan"* secara presisi per hari/jam.
- Status iklim komplit mulai dari suhu Celsius, Kelembaban relatif udara, Tekanan udara per hPa, jarak pandang, hingga kecepataan angin dalam km/jam.

📚 **4. Pusat Edukasi Bencana Edukatif & Multimedia**
Lebih tanggap dan siap untuk menyelamatkan diri, fasilitas penunjang edukasi merangkap:
- **Video Edukasi Interaktif**: Pemutaran video penanggulangan prabencana, saat bencana darurat, hingga pascabencana langsung dalam *interface* aplikasi.
- **Filter Chip Cerdas**: Materi bacaan komprehensif terkait gempa, tsunami, kebakaran, tanah longsor, yang dihias dengan UI *Glassmorphism*.
- **Panduan Standar Keselamatan Ruang**: Tips mitigasi khusus (di luar atau dalam rumah, di gedung, atau berkendara).

🧠 **5. Klasifikasi Tingkat Kerentanan Seismik (Model Machine Learning)**
Fitur *eksklusif* pengembangan Tugas Akhir:
- **Integrasi Penuh Machine Learning**: Fitur klasifikasi berbasis **Support Vector Machine (SVM)** yang *real-time* terhubung ke backend Python untuk memetakan zonasi risiko gempa secara otomatis.
- **Dual Model Inference**: Pengguna dapat memilih sumber data prediksi dari model yang dilatih menggunakan dataset **BMKG (Lokal)** atau **USGS (Global)**.
- Sistem memprediksi skor risiko dengan tingkatan: **Rendah**, **Sedang**, dan **Tinggi** dengan pra-pemrosesan Normalisasi Min-Max.
- Pengolahan berbasis *input parameter gempa kunci* (Magnitudo, Kedalaman, Lintang, Bujur Episenter).
- Turut serta dibekali utilitas **Hitung Dampak Guncangan Gempa** berbekal algoritma parameter pendukung *rule-based*.

🛡️ **6. Edukasi Perlindungan Aset & Peralatan Survival Kritis**
- **Asuransi "Pro-Siaga":** Integrasi panel proteksi finansial agar kerugian asuransial pascabencana dapat ditanggulangi sedini mungkin.
- **Toko Mitigasi (*Toko Shop*)**: Menjual beragam produk krusial untuk bencana seperti P3K Darurat, Helm SNI Kevlar, Peluit Survival, Jaket Anti Dingin, sampai Filter Air yang menunjang penyiapan *Tas Siaga*.

---

## 🛠️ Arsitektur & Teknologi

Proyek ini dibangun menggunakan landasan modern pada pengembangan *mobile cross-platform* :

- **Frontend Framework:** [Flutter](https://flutter.dev/) (Dart)
- **Backend API & ML Engine:** [FastAPI](https://fastapi.tiangolo.com/) (Python) dengan Scikit-Learn (Support Vector Machine) dan Joblib.
- **Paradigma Antarmuka UI/UX:** *Material Design & Custom Styling* bertemakan minimalis-futuristik. Dilengkapi bayangan (*Drop & Inner Shadows*), mikro-interaksi responsif, dan efek grafikal bergradien yang elok.
- **Dependencies Kunci:** Pemanggilan Webview & Modul rendering Peta / API.
- **Sistem *Development & Version Control*:** Lingkungan terkendali penuh dengan *Git* dan pelacakan dari *GitHub*.

---

## 🚀 Eksekusi dan Penjalanan Simulasi Lokal

Ingin mencoba meng-compile dan meng-run antarmuka *Amanin* memukau ini di emulator secara independen? 

1. **Clone Repositori:**
   ```bash
   git clone https://github.com/Kevinpb86/Tugas-Akhir2.git
   ```

2. **Masuk ke Direktori Kerja Utama:**
   ```bash
   cd Tugas-Akhir2/amanin
   ```

3. **Sinkronisasi Dependensi (Packages):**
   ```bash
   flutter pub get
   ```

4. **Menjalankan Backend Machine Learning (Wajib untuk fitur Klasifikasi):**
   Buka terminal baru, masuk ke folder backend dan jalankan server FastAPI:
   ```bash
   cd Tugas-Akhir2/amanin/backend
   pip install -r requirements.txt
   python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
   ```

5. **Kompilasi dan Pengoperasian Aplikasi Flutter:**
   Pastikan emulator atau perangkat USB Mode *Debugging* Anda sudah tercantol sukses.
   ```bash
   flutter run
   ```

---

## 📈 Pembaruan Terkini (*Changelog*)

Berikut adalah jejak historis pemutakhiran layanan dan perbaikan (*bug fixes*) terpenting yang sukses tereksekusi di lintasan rilis *branch* ini:

*   **Integrasi Model Machine Learning Klasifikasi SVM:** Penerapan layar simulasi inovatif yang membaca kondisi magnitudo dan kedalaman dengan kaidah SVM guna menentukan risiko Rendah, Sedang, hingga Tinggi.
*   **Pemutakhiran Infrastruktur Edukasi:** Merombak besar-besaran tata letak halaman **Edukasi** dengan penyisipan tombol akses media *(Video Edukasi)*, *filter chips* responsif, serta *card* materi.
*   **Optimalisasi Toko & Perdagangan Bencana:** Penyertaan navigasi khusus untuk mengakses kelengkapan keselamatan P3K di *widget* produk.
*   **Resinchronisasi Tombol Asuransi:** Memperbaiki sistem laluan URL/Iklan Asuransi "Pro-Siaga" yang tadinya rawan rusak, dan sekarang beroperasi mulus pada Cuaca, Beranda, serta Gempa.
*   **Tuning Sensibilitas Navigasi:** Perbaikan *margin*, *text bounds layout*, juga peningkatan estetika agar konsistensi ruang putih (*whitespace*) terjaga.

---

> **⚠️ Catatan Ekstra (Academic Context):** Repositori pada komitmen (`branch: Dava-Ihza`) ini dimanfaatkan sebagai sub-wadah *Development Sandbox* / **Prototipe Purwarupa UI/UX** dari penelitian dan perancangan Akademik Tugas Akhir. Jika Anda mendapati penempatan statis (*dummy text*) ataupun integrasi API bersimulasi, hal tersebut bertujuan mengimplementasikan kaidah visualnya terlebih dahulu sesuai dengan gagasan metodologi penelitian.
