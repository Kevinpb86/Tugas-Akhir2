# Aturan Khusus Gemini

Dokumen ini berisi panduan dan aturan khusus yang wajib diikuti oleh AI Agent saat bekerja di repositori ini. Aturan dibagi menjadi dua bagian utama: aturan untuk perilaku AI dan aturan terkait proyek.

## 1. Aturan Perilaku AI Agent
* **Wajib Bertanya untuk Klarifikasi:** Selalu tanyakan kembali jika ada instruksi yang kurang dimengerti, ambigu, atau rancu.
* **Jangan Berasumsi (Tidak Boleh Sok Tahu):** Jangan pernah mencoba menjelaskan atau menebak-nebak tindakan jika Anda tidak mengerti apa yang dimaksud oleh user. Anda hanya diizinkan untuk mengeksekusi instruksi dan memberikan penjelasan ketika permintaan user sudah benar-benar *clear* (jelas).

## 2. Aturan Terkait Proyek
* **Jadikan `DevDocs.md` & File Lain Sebagai Referensi Utama:** Anda diwajibkan untuk selalu merujuk pada file `.md` lain (khususnya `DevDocs.md` dan `README.md`) untuk memahami aturan arsitektur dasar proyek (contoh: aturan semua *Fetch API* eksternal harus lewat Backend).
* **PENGECUALIAN PENTING (Modul Fuad):** Meskipun `DevDocs.md` menjadi referensi, **ABAIKAN TOTAL** informasi di dalamnya yang menjelaskan tentang detail teknis modul anomali gempa milik Fuad (Fitur 3). Karena informasi di dokumen tersebut kurang ter-*update*. Untuk modul Fuad, gunakan parameter aktual ini:
  - Hanya menggunakan algoritma **Isolation Forest** (Tanpa XGBoost).
  - Model `isolation_forest_bmkg.pkl` **HANYA** menerima 4 parameter input: `mag`, `depth`, `latitude`, dan `longitude`. (Abaikan parameter `gap, dmin, nst, bulan, jam` yang tertulis di DevDocs).
  - **Sumber Data:** Endpoint Anomali (`/anomali-terkini`) mengambil data dari **`gempadirasakan.json`** agar tersinkronisasi dan menampilkan riwayat gempa yang persis sama dengan halaman "Gempabumi Dirasakan". Selain itu, terdapat endpoint `/anomali-history` yang mengambil seluruh data dari tabel `earthquakes` di database untuk prediksi batch, dengan fitur *fallback* otomatis membaca data dari file CSV (`historical_data_bmkg_2021-2026.csv`) apabila koneksi ke database mati atau tabel kosong.
  - **Aturan UI:** Tampilan untuk fitur Anomali harus berorientasi pada masyarakat awam (layman-friendly). **DILARANG** menampilkan penjelasan teknis *Machine Learning* (seperti nama file `.pkl` atau rincian *input parameter*) di UI pengguna.
  - **Aturan UX:** Selalu utamakan kenyamanan visual dan User Experience. Jangan membuat elemen UI yang memakan terlalu banyak ruang di layar hingga mengganggu fitur utama (misalnya peta). Gunakan kalimat yang singkat, padat, dan langsung pada intinya alih-alih kalimat bertele-tele.
* **Catat Perubahan Besar (Major Changes):** Setiap kali terdapat perubahan besar pada arsitektur atau alur proyek (khusus untuk fitur/modul yang saya kerjakan, bukan modul teman kelompok lain), Anda **wajib memperbarui file `gemini.md` ini** di latar belakang untuk mencatat logika/aturan baru tersebut. Setelah itu, berikan konfirmasi bahwa `gemini.md` telah di-*update*.
* **Abaikan Perubahan Minor:** Jika pembaruan yang dilakukan hanya bersifat *minor* (seperti perbaikan *bug* kecil, *typo*, atau penyesuaian UI ringan), Anda dilarang memperbarui file `gemini.md` ini.
