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

## ✨ Fitur-Fitur Utama (Core Features)

🚨 **1. Peringatan & Informasi Gempa Real-Time**
- Pantau data gempabumi yang baru saja terjadi berdasarkan filter cerdas (Terkini, Mangitudo ≥ 5.0, Dirasakan, Real-Time).
- Tampilan detail berupa **Peta Guncangan** (interaktif), titik koordinat (Lintang/Bujur), magnitudo, dan kedalaman gempa.
- Opsi pelaporan instan dengan tombol cepat *"Saya juga merasakannya"*.
- Dilengkapi dengan daftar riwayat gempa yang rapi dan detail historis.

🌤️ **2. Pemantauan Cuaca Berbasis Titik Lokasi**
- Integrasi cerdas untuk memantau prakiraan "Cuaca Mingguan" secara presisi berdasarkan posisi pengguna (Misal: Jakarta Pusat).
- Laporan suhu harian (Celcius) lengkap dengan indeks kelembaban, tekanan udara, kecepatan angin, hingga jarak pandang.
- Rekomendasi aktivitas harian berdasar pergerakan matahari.

📚 **3. Pusat Edukasi Mitigasi Bencana**
- Modul "Mitigasi Gempa Bumi" komprehensif (Pra-bencana, saat bencana, pasca-bencana).
- Tampilan grid responsif untuk langkah keselamatan di berbagai tempat: Di dalam rumah, di luar ruangan, di dalam mobil, dan di gedung tinggi.
- Integrasi **Video Edukasi** (misal: Simulasi evakuasi mandiri) agar masyarakat mudah memahaminya lewat simulasi visual.
- Fasilitas panduan merakit komponen krusial **Tas Siaga Bencana (TSB)** berwujud _checklist_ (dokumen, p3k, senter, dsb).
- Standar operasional keselamatan multi-bencana lainnya (Tsunami, Longsor, Banjir, Gunung Api).

📞 **4. Akses Cepat Bantuan Darurat (Emergency Call)**
- Nomor telepon vital terpusat (Ambulans/Medis: 118, Pemadam Kebakaran: 113, Polisi: 110, dan SAR/Basarnas: 115) dapat dihubungi langsung dalam *1-tap call*.

🛡️ **5. Edukasi Perlindungan Aset & Keluarga**
- Banner terintegrasi program "Asuransi Pro-Siaga" untuk memberi pengarahan proteksi finansial dari dampak bencana.

---

## 🛠️ Teknologi yang Digunakan
Proyek ini dibangun menggunakan arsitektur modern untuk *mobile application* *cross-platform* (bisa jalan di Android maupun iOS dalam satu *codebase*!):

- **Framework:** [Flutter](https://flutter.dev/) (UI Toolkit by Google)
- **Bahasa Pemrograman:** [Dart](https://dart.dev/)
- **UI/UX:** *Material Design & Custom Styling* (Micro-interactions, Navigation Bar Melayang, Gradient & Shadow UI, dsb)
- **Komponen Spesifik:**
  - `webview_flutter`: Render fungsionalitas peta (Map) dan penampil peringatan dini cuaca guncangan.
  - Implementasi *Font* Khusus (Custom Typography) untuk menciptakan nuansa yang elegan dan mudah terbaca.
- **Workflow & Version Control:** Git, Visual Studio Code / Android Studio, dan GitHub repositori.

---

## 🚀 Cara Menjalankan Proyek Secara Lokal

Ingin mencoba meng-compile antarmuka *Amanin* cantik ini langsung ke HP / Emulator-mu? Ikuti panduan singkat berikut:

1. **Clone repositori ini:**
   Buka terminal/Command Prompt dan jalankan:
   ```bash
   git clone https://github.com/Kevinpb86/Tugas-Akhir2.git
   ```

2. **Masuk ke direktori utama aplikasi:**
   ```bash
   cd Tugas-Akhir2/amanin
   ```

3. **Install seluruh dependensi *package*:**
   ```bash
   flutter pub get
   ```

4. **Jalankan Aplikasi:**
   Koneksikan *device* atau emulator Anda, lalu lakukan eksekusi:
   ```bash
   flutter run
   ```

> **Catatan Penting:** Repositori komitmen (branch: `Dava-Ihza`) ini dimanfaatkan khusus sebagai sub-wadah pengembangan (Development Sandbox) **purwarupa purwa (UI/UX prototype)** aplikasi Tugas Akhir akademik. Jika terdapat *dummy text* / placeholder pada simulasi API, maka itu ditujukan untuk keperluan presentasi desain di masa pembangunan aplikasi ini.
