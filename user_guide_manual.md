# 📖 Panduan Penggunaan Aplikasi AMANIN

Selamat datang di **AMANIN**, aplikasi asisten siaga bencana gempa bumi pintar yang dirancang untuk membantu Anda memantau, mendeteksi risiko, mempelajari langkah-langkah mitigasi, serta bersiap menghadapi potensi ancaman gempa bumi menggunakan teknologi Kecerdasan Buatan (Machine Learning).

Berikut adalah panduan lengkap cara menggunakan berbagai fitur unggulan di aplikasi AMANIN.

---

## 📌 Daftar Isi
1. [Deteksi Lingkungan Dinamis (Indoor/Outdoor & Geografis)](#1-deteksi-lingkungan-dinamis)
2. [Informasi Gempa & Prediksi Tingkat Risiko (SVM)](#2-informasi-gempa--prediksi-tingkat-risiko)
3. [Deteksi Anomali Seismik (Isolation Forest)](#3-deteksi-anomali-seismik)
4. [Kalkulator Dampak Gempa Bumi](#4-kalkulator-dampak-gempa-bumi)
5. [Edukasi Mitigasi & Media Pembelajaran](#5-edukasi-mitigasi--media-pembelajaran)
6. [Toko Siaga Bencana & Layanan Asuransi](#6-toko-siaga-bencana--layanan-asuransi)
7. [Tips Siaga Darurat Gempa Bumi](#7-tips-siaga-darurat-gempa-bumi)

---

## 1. Deteksi Lingkungan Dinamis
Fitur ini otomatis mendeteksi status lokasi fisik dan tipe geografis lingkungan sekitar Anda secara real-time saat aplikasi dibuka.

* **Status Ruangan (Indoor/Outdoor):**
  * **Deteksi Otomatis:** Sistem mendeteksi akurasi GPS Anda. Jika akurasi buruk ($> 25\text{ meter}$) karena terhalang dinding/atap, sistem otomatis memunculkan status **Dalam Ruangan**. Jika akurasi sangat baik, sistem memunculkan status **Luar Ruangan**.
  * **Ubah Manual (Interactive Toggle):** Anda dapat menekan/mengetuk tombol status ini di bagian header Beranda untuk mengubahnya secara manual kapan saja.
* **Status Wilayah Geografis:**
  * **Wilayah Darat:** Pengguna berada di dataran/darat yang aman dari ancaman pantai/gunung langsung.
  * **Dekat Pantai:** Terdeteksi jika alamat geocoding pengguna berada di area pesisir (jarak dekat dengan pantai/laut). Berguna sebagai alarm kewaspadaan tsunami jika terjadi gempa besar.
  * **Dekat [Nama Gunung]:** Otomatis mendeteksi jika koordinat GPS pengguna berada dalam radius $< 10\text{ km}$ dari salah satu gunung api aktif utama di Indonesia (misal: Gunung Merapi, Gede, Ceremai, Rinjani, dll.).

---

## 2. Informasi Gempa & Prediksi Tingkat Risiko
Fitur ini memadukan data real-time BMKG / USGS dengan kecerdasan buatan (*Support Vector Machine* - SVM) untuk memprediksi tingkat bahaya gempa di koordinat gempa.

* **Cara Mengakses:** Ketuk menu **Peta/Gempa** di aplikasi.
* **Peta Interaktif:** Menampilkan lokasi episentrum gempa terkini dengan pin merah menyala.
* **Prediksi Risiko SVM:** Di dalam detail gempa, kecerdasan buatan akan memproses parameter magnitudo, kedalaman, dan koordinat untuk menghasilkan prediksi tingkat risiko:
  * 🔴 **Tinggi:** Berpotensi merusak bangunan secara masif dan memerlukan evakuasi darurat segera.
  * 🟡 **Sedang:** Berpotensi menimbulkan kerusakan ringan pada konstruksi lemah dan getaran terasa kuat.
  * 🟢 **Rendah:** Aman, getaran cenderung lemah dan tidak merusak.
* **Tingkat Akurasi (Confidence Score):** Menampilkan persentase kepercayaan model AI terhadap hasil prediksi tersebut.

---

## 3. Deteksi Anomali Seismik
Menggunakan algoritma *Isolation Forest* untuk mendeteksi apakah gempa bumi yang terjadi memiliki karakteristik yang tidak biasa (anomali) dibandingkan dengan pola gempa historis.

* **Cara Mengakses:** Ketuk menu **Deteksi Anomali** di menu lainnya atau di halaman gempa.
* **Fungsi:** Berguna bagi akademisi, relawan, atau pihak berwenang untuk mengidentifikasi gempa langka, seperti gempa vulkanik dalam, atau aktivitas seismik tak biasa yang berpotensi memicu rentetan gempa susulan.

---

## 4. Kalkulator Dampak Gempa Bumi
Alat simulasi mandiri untuk mengukur dampak kerusakan gempa berdasarkan masukan parameter dari Anda sendiri.

* **Cara Menggunakan:**
  1. Masuk ke fitur **Kalkulator Dampak**.
  2. Input nilai **Magnitudo** (skala Richter) yang ingin disimulasikan.
  3. Input nilai **Kedalaman** (km).
  4. Tekan **Hitung Dampak**.
* **Output:** Sistem akan menampilkan estimasi skala intensitas getaran (dalam skala MMI) serta panduan keselamatan dan tindakan cepat yang harus Anda ambil sesuai hasil kalkulasi tersebut.

---

## 5. Edukasi Mitigasi & Media Pembelajaran
Pusat pembelajaran interaktif untuk mempersiapkan diri sebelum, sesaat, dan sesudah gempa bumi terjadi.

* **Artikel Taktis:** Panduan langkah demi langkah saat gempa melanda di berbagai kondisi (di dalam rumah, di dalam mobil, di pegunungan, di pantai).
* **Video Edukasi:** Pembelajaran visual interaktif yang menjelaskan fenomena gempa bumi dan cara mempersiapkan tas siaga bencana.
* **Survival Kit List:** Panduan menyusun tas siaga bencana mandiri, mencakup kebutuhan air bersih, obat-obatan P3K, senter, makanan instan, dokumen penting, dan peluit darurat.

---

## 6. Toko Siaga Bencana & Layanan Asuransi
* **Toko Siaga:** Menyediakan akses mudah untuk membeli peralatan keselamatan darurat terverifikasi seperti helm penyelamat, tas siaga bencana lengkap, peluit berkekuatan tinggi, senter dinamo, dan alat P3K portable.
* **Asuransi Bencana:** Memfasilitasi pendaftaran perlindungan asuransi khusus gempa bumi untuk menjamin keselamatan finansial dan aset properti Anda dari dampak kerusakan gempa.

---

## 7. Tips Siaga Darurat Gempa Bumi
* **Sebelum Gempa:** Siapkan tas siaga bencana, perbaiki konstruksi rumah yang rapuh, dan tentukan titik kumpul aman bersama keluarga.
* **Saat Gempa:**
  * **Di Dalam Ruangan:** Lakukan metode **Drop, Cover, and Hold On** (Merunduk, Berlindung di bawah meja kokoh, dan Berpegangan). Jauhi jendela kaca.
  * **Di Luar Ruangan:** Cari area terbuka, jauhi tiang listrik, pohon, reklame, dan bangunan tinggi.
  * **Di Pantai:** Jika merasakan getaran kuat, segera lari ke tempat tinggi tanpa menunggu peringatan sirine tsunami.
  * **Di Pegunungan:** Waspadai potensi tanah longsor dari tebing di atas Anda.
* **Setelah Gempa:** Waspadai gempa susulan, periksa kebocoran gas/korsleting listrik, dan dengarkan informasi resmi dari BMKG melalui aplikasi AMANIN.

---

> *"Bersiap Lebih Awal, Amanin Bersama."*
