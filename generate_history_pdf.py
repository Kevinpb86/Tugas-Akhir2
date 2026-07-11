import os
from fpdf import FPDF

class FlowPDF(FPDF):
    def header(self):
        self.set_font("Helvetica", "B", 12)
        self.cell(0, 10, "Flow History Gempa Lengkap - Aplikasi AMANIN", 0, 1, "C")
        self.line(10, 20, 200, 20)
        self.ln(10)

    def footer(self):
        self.set_y(-15)
        self.set_font("Helvetica", "I", 8)
        self.cell(0, 10, f"Halaman {self.page_no()}", 0, 0, "C")

    def chapter_title(self, label):
        self.set_font("Helvetica", "B", 14)
        self.set_fill_color(200, 220, 255)
        self.cell(0, 10, f" {label}", 0, 1, "L", 1)
        self.ln(4)

    def paragraph(self, text):
        self.set_font("Helvetica", "", 11)
        # Mengganti karakter non-ascii jika ada agar tidak error di FPDF
        clean_text = text.replace("≥", ">=")
        self.multi_cell(0, 6, clean_text)
        self.ln(4)

    def bullet_point(self, text):
        self.set_font("Helvetica", "", 11)
        self.multi_cell(0, 6, f"- {text}")
        self.ln(2)

pdf = FlowPDF()
pdf.add_page()

pdf.chapter_title("1. Pengantar")
pdf.paragraph("Dokumen ini menjelaskan alur (flow) kerja secara menyeluruh (end-to-end) dari fitur 'Riwayat Gempa' pada aplikasi AMANIN. Penjelasan mencakup dari awal halaman diakses oleh pengguna hingga bagaimana data ditarik dari berbagai sumber API pihak ketiga maupun backend internal.")

pdf.chapter_title("2. Alur Inisiasi UI (User Interface)")
pdf.paragraph("Awal mula fitur ini dapat diakses melalui halaman 'Fitur Aplikasi' (fitur.dart). Saat pengguna menekan menu 'Riwayat Gempa', aplikasi akan melakukan navigasi ke halaman RiwayatGempaPage (riwayat_gempa.dart).")
pdf.paragraph("Pada saat halaman pertama kali dimuat (initState):")
pdf.bullet_point("Aplikasi akan mengecek apakah posisi GPS (userPosition) tersedia. Jika belum, fungsi _getCurrentLocation() akan dipanggil untuk mengaktifkan Geolocator dan mengambil kordinat terbaru pengguna.")
pdf.bullet_point("Aplikasi juga akan mengecek ketersediaan data awal. Jika kosong, fungsi _fetchAndFilterData() akan langsung berjalan untuk menarik data riwayat gempa dengan filter bawaan (Terkini).")

pdf.chapter_title("3. Alur Pengambilan Data Berdasarkan Filter")
pdf.paragraph("Terdapat 5 (lima) kategori filter yang masing-masing mengambil data dari sumber (endpoint) yang berbeda untuk disajikan kepada pengguna:")

pdf.set_font("Helvetica", "B", 11)
pdf.cell(0, 6, "A. Terkini (Index 0)", 0, 1)
pdf.paragraph("Menggunakan UsgsService.fetchIndonesiaEarthquakes(). Servis ini melakukan HTTP GET ke API United States Geological Survey (USGS): https://earthquake.usgs.gov/fdsnws/event/1/query. Data ini mencakup gempa bumi global secara real-time namun difilter spesifik dengan parameter bounding box (kordinat geografis) wilayah Indonesia.")

pdf.set_font("Helvetica", "B", 11)
pdf.cell(0, 6, "B. M >= 5 (Index 1)", 0, 1)
pdf.paragraph("Menggunakan BmkgService.fetchEarthquakeList(). Data diambil dari API terbuka Badan Meteorologi, Klimatologi, dan Geofisika (BMKG) melalui endpoint: https://data.bmkg.go.id/DataMKG/TEWS/gempaterkini.json yang difokuskan pada gempa berkekuatan (Magnitudo) di atas 5.0.")

pdf.set_font("Helvetica", "B", 11)
pdf.cell(0, 6, "C. Jarak Jauh & Jarak Dekat (Index 2 & 3)", 0, 1)
pdf.paragraph("Filter ini kembali menarik data dari API USGS secara real-time. Namun, sebelum disajikan, aplikasi akan mengeksekusi perhitungan matematis di sisi device (client-side). Fungsi Geolocator.distanceBetween() digunakan untuk menghitung selisih jarak antara titik koordinat pengguna (Latitude, Longitude) dengan titik pusat gempa (Epicenter). Setelah itu, List data akan di-urutkan (sorting) secara ascending atau descending berdasarkan jarak (Distance).")

pdf.set_font("Helvetica", "B", 11)
pdf.cell(0, 6, "D. Anomali (Index 4)", 0, 1)
pdf.paragraph("Menggunakan AnomaliService.fetchAnomaliTerkini() yang berinteraksi dengan arsitektur internal AMANIN:")
pdf.bullet_point("Tahap 1: Aplikasi mengirim HTTP GET ke Backend FastAPI internal (http://127.0.0.1:8000/api/predict/anomali-terkini).")
pdf.bullet_point("Tahap 2: Backend FastAPI kemudian menarik data mentah gempa yang dirasakan dari BMKG (gempadirasakan.json).")
pdf.bullet_point("Tahap 3: Backend memproses setiap data gempa tersebut menggunakan Model Machine Learning Isolation Forest (isolation_forest_bmkg.pkl).")
pdf.bullet_point("Tahap 4: Gempa yang diprediksi sebagai anomali dikembalikan ke aplikasi (Flutter) lengkap dengan skor dan analisis SHAP-nya (penjelasan mengapa gempa tersebut anomali).")

pdf.chapter_title("4. Alur Penyajian Data ke Layar (Rendering)")
pdf.paragraph("Setelah data mentah (JSON) berhasil diambil dari sumber masing-masing, data tersebut akan di-parsing (diurai) ke dalam format objek Dart (GempaModel).")
pdf.paragraph("Jika proses fetch sedang berlangsung, layar akan menampilkan indikator loading melingkar (CircularProgressIndicator). Jika tidak ada data yang berhasil ditarik, akan muncul teks 'Tidak ada data riwayat gempa'.")
pdf.paragraph("Jika data tersedia, layar akan dirender menggunakan widget ListView.builder. Setiap data akan ditampilkan dalam bentuk kartu (Card). Sebagai indikator visual tambahan, aplikasi menerapkan 'Color Coding' (pewarnaan) berdasarkan besarnya Magnitudo:")
pdf.bullet_point("Hijau: Skala kecil (Aman)")
pdf.bullet_point("Kuning/Oranye: Skala menengah (Waspada)")
pdf.bullet_point("Merah: Skala besar (Bahaya)")

out_path = r"C:\Users\fuadf\OneDrive\Documents\Tugas Akhir\Flow History Gempa Lengkap.pdf"
pdf.output(out_path)
print(f"Berhasil membuat PDF di {out_path}")
