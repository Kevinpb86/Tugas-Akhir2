import os
from fpdf import FPDF

class MasterBriefPDF(FPDF):
    def header(self):
        if self.page_no() > 1:
            self.set_font("Helvetica", "I", 8)
            self.set_text_color(120, 120, 120)
            self.cell(100, 10, "MASTER BRIEF - APLIKASI MITIGASI BENCANA AMANIN", 0, 0, "L")
            self.cell(80, 10, "TUGAS AKHIR", 0, 1, "R")
            self.set_draw_color(220, 220, 220)
            self.line(15, 20, 195, 20)
            self.ln(5)

    def footer(self):
        self.set_y(-15)
        self.set_font("Helvetica", "I", 8)
        self.set_text_color(120, 120, 120)
        self.set_draw_color(220, 220, 220)
        self.line(15, 282, 195, 282)
        self.cell(100, 10, "AMANIN Proyek Tugas Akhir - Rahasia Internal Tim", 0, 0, "L")
        self.cell(80, 10, f"Halaman {self.page_no()}", 0, 1, "R")

    def chapter_title(self, label):
        self.set_font("Helvetica", "B", 14)
        self.set_text_color(26, 82, 118) # Deep Blue
        self.cell(0, 10, label, 0, 1, "L")
        self.ln(2)

    def section_title(self, label):
        self.set_font("Helvetica", "B", 11)
        self.set_text_color(22, 160, 133) # Teal
        self.cell(0, 8, label, 0, 1, "L")
        self.ln(1)

    def paragraph(self, text):
        self.set_font("Helvetica", "", 10)
        self.set_text_color(44, 62, 80) # Charcoal
        self.multi_cell(0, 6, text)
        self.ln(3)

    def bullet_point(self, label, text):
        self.set_font("Helvetica", "B", 10)
        self.set_text_color(44, 62, 80)
        self.write(6, f"- {label}: ")
        self.set_font("Helvetica", "", 10)
        self.write(6, f"{text}\n")

    def code_block(self, code_text):
        self.set_fill_color(245, 247, 250)
        self.set_text_color(44, 62, 80)
        self.set_font("Courier", "", 8.5)
        
        # Calculate height needed
        lines = code_text.strip().split("\n")
        h = len(lines) * 4.5 + 4
        
        # Keep block together if it fits on page
        if self.get_y() + h > 270:
            self.add_page()
            
        # Background block
        x_start = self.get_x()
        y_start = self.get_y()
        self.rect(x_start, y_start, 180, h, "F")
        
        self.set_xy(x_start + 4, y_start + 2)
        for line in lines:
            self.cell(172, 4.5, line, 0, 1, "L")
            
        self.set_x(x_start)
        self.ln(4)

def build_pdf(filename="MASTER_BRIEF_AI_AMANIN.pdf"):
    pdf = MasterBriefPDF(orientation="P", unit="mm", format="A4")
    pdf.set_margins(15, 15, 15)
    pdf.add_page()

    # --- COVER / TITLE BANNER ---
    pdf.set_fill_color(26, 82, 118) # Deep Blue
    pdf.rect(15, 15, 180, 25, "F")
    pdf.set_xy(15, 20)
    pdf.set_font("Helvetica", "B", 16)
    pdf.set_text_color(255, 255, 255)
    pdf.cell(180, 8, "MASTER BRIEF - APLIKASI MITIGASI BENCANA AMANIN", 0, 1, "C")
    pdf.set_font("Helvetica", "", 10)
    pdf.cell(180, 6, "Pedoman Standar Integrasi AI Agent & Pengembangan Kolaboratif (Tugas Akhir)", 0, 1, "C")
    
    pdf.set_xy(15, 45)

    # --- SECTION 1: KONTEKS PROYEK ---
    pdf.chapter_title("1. Konteks Proyek")
    pdf.paragraph(
        "Kalian membangun sistem AMANIN (Aplikasi Peringatan Dini dan Mitigasi Bencana Gempa Bumi & Cuaca) "
        "berbasis Flutter (Frontend) + FastAPI (Backend) + MySQL (Database). Sistem ini mengintegrasikan model "
        "Machine Learning untuk memprediksi tingkat risiko gempa bumi (menggunakan SVM) dan mendeteksi anomali seismik."
    )
    
    pdf.paragraph("Fokus Utama Pengembangan:")
    pdf.bullet_point("Data Flow Mediator", "Semua data gempa bumi eksternal wajib dilewatkan melalui Backend FastAPI terlebih dahulu. Aplikasi Flutter (client) dilarang menembak API BMKG secara langsung.")
    pdf.bullet_point("Clean Repository", "Menjaga kebersihan direktori Flutter client. File Jupyter Notebook (.ipynb), file model ML (.pkl/.keras), dan script Python pembantu dilarang keras ditaruh di dalam folder Flutter 'amanin/'.")
    pdf.bullet_point("AI Agent Rules", "Wajib melampirkan Master Brief ini ketika berinteraksi dengan AI Agent (Antigravity, Claude, atau ChatGPT) agar AI tidak menghasilkan kode yang melanggar batasan arsitektur.")
    pdf.ln(4)

    # --- SECTION 2: PEMBAGIAN MODUL ---
    pdf.chapter_title("2. Pembagian Modul Kelompok")
    
    pdf.paragraph(
        "Semua anggota tim berkontribusi secara kolaboratif pada pengembangan frontend Flutter, "
        "riset machine learning, dan backend. Poin pembeda utama terletak pada proses deployment "
        "model ML ke dalam fitur aplikasi masing-masing sebagai berikut:"
    )
    
    # Table header
    pdf.set_font("Helvetica", "B", 9.5)
    pdf.set_fill_color(230, 240, 250)
    pdf.set_text_color(26, 82, 118)
    pdf.cell(40, 8, " Modul / Peran", 1, 0, "L", True)
    pdf.cell(40, 8, " Anggota Tim", 1, 0, "L", True)
    pdf.cell(100, 8, " Deskripsi & Scope Kerja", 1, 1, "L", True)
    
    # Rows
    rows = [
        (
            "Modul 1:\nDeploy SVM\n(Tingkat Risiko)", 
            "Dava", 
            "- Deploy model SVM (Support Vector Machine) ke backend.\n- Mengklasifikasikan tingkat risiko gempa bumi (Rendah, Sedang, Tinggi) berdasarkan magnitudo, kedalaman, dan koordinat dari data BMKG & USGS."
        ),
        (
            "Modul 2:\nDeploy K-Means\n(Rekomendasi Edukasi)", 
            "Kevin", 
            "- Deploy model K-Means Clustering ke backend.\n- Menganalisis aktivitas gempa bumi dan memetakan wilayah GPS kecamatan pengguna ke kluster risiko terdekat.\n- Menyajikan rekomendasi artikel edukasi siaga bencana yang relevan."
        ),
        (
            "Modul 3:\nDeploy Isolation Forest\n& XGBoost (Anomali)", 
            "Fuad", 
            "- Deploy pipeline model Isolation Forest & XGBoost ke backend.\n- Melakukan deteksi anomali seismisitas real-time berdasarkan parameter latitude, longitude, kedalaman, gap, dmin, nst, bulan, dan jam."
        ),
        (
            "Modul 4:\nDeploy Random Forest\n(Main/Aftershock)", 
            "Gilang", 
            "- Deploy model Random Forest berbasis Nearest-Neighbor ke backend.\n- Mengklasifikasikan status kejadian gempa apakah merupakan gempa utama (Mainshock) atau gempa susulan (Aftershock) berdasarkan kemiripan spasial-temporal."
        )
    ]
    
    pdf.set_text_color(44, 62, 80)
    for modul, anggota, deskripsi in rows:
        y_start = pdf.get_y()
        
        # 1. Estimate height of description using dry_run in FPDF2
        pdf.set_font("Helvetica", "", 8.5)
        lines = pdf.multi_cell(96, 4.5, deskripsi, dry_run=True, output="LINES")
        row_height = max(len(lines) * 4.5 + 4, 18)  # Set min height 18 to align nicely
        y_end = y_start + row_height
        
        # 2. Draw border cells for the row
        pdf.set_xy(15, y_start)
        pdf.cell(40, row_height, "", 1)
        pdf.cell(40, row_height, "", 1)
        pdf.cell(100, row_height, "", 1)
        
        # 3. Draw text in Column 1 (Modul)
        pdf.set_xy(17, y_start + 2)
        pdf.set_font("Helvetica", "B", 8.5)
        pdf.multi_cell(36, 4.5, modul, 0, "L")
        
        # 4. Draw text in Column 2 (Anggota)
        pdf.set_xy(57, y_start + 2)
        pdf.set_font("Helvetica", "", 8.5)
        pdf.multi_cell(36, 4.5, anggota, 0, "L")
        
        # 5. Draw text in Column 3 (Deskripsi)
        pdf.set_xy(97, y_start + 2)
        pdf.set_font("Helvetica", "", 8.5)
        pdf.multi_cell(96, 4.5, deskripsi, 0, "L")
        
        # 6. Set Y cursor to y_end for the next row
        pdf.set_xy(15, y_end)
        
    pdf.ln(6)

    # --- SECTION 3: STACK TEKNIS ---
    pdf.chapter_title("3. Stack Teknis Standar (Wajib Sama)")
    pdf.bullet_point("Mobile Client", "Flutter 3.x & Dart 3.x (HTTP library: http, Geolocation: geolocator).")
    pdf.bullet_point("Backend Framework", "Python FastAPI (Uvicorn server, running on port 8000).")
    pdf.bullet_point("Database", "MySQL (Port 3308, nama database: db_amanin).")
    pdf.bullet_point("Libraries ML (Backend)", "joblib, numpy, scikit-learn.")
    pdf.bullet_point("Password Hashing", "passlib (Bcrypt).")
    pdf.ln(6)

    # --- PAGE 2 ---
    pdf.add_page()
    
    # --- SECTION 4: STRUKTUR FOLDER ---
    pdf.chapter_title("4. Struktur Folder Repositori")
    pdf.paragraph("Struktur folder yang rapi dan terstandardisasi sangat krusial agar tidak membingungkan penguji sidang:")
    
    folder_tree = """Tugas-Akhir2/
|-- .gitignore                     # Menentukan file yang diabaikan Git di root
|-- README.md                      # File pengenalan Project
|-- DevDocs.md                     # File dokumentasi Development (Master Brief)
|-- backend/                       # Direktori utama backend mobile app AMANIN
|   |-- app/
|   |   |-- api/                   # Route endpoint API (*.py)
|   |   |-- auth/                  # Logika verifikasi token JWT (*.py)
|   |   |-- services/              # Logika bisnis & preprocessing data (*.py)
|   |   |-- models/                # Skema database (*.py)
|   |   |-- config/                # Env, config db, setup.sql
|   |-- ml_models/                 # Model ML hasil ekspor (.pkl)
|   |-- main.py                    # File entrypoint utama backend
|   |-- requirements.txt           # Library dependensi python backend
|-- amanin/                        # Direktori utama mobile app AMANIN
    |-- android/                   # Build & konfigurasi aplikasi Android (Gradle, manifest, dll)
    |-- assets/                    # Resource statis aplikasi
    |   |-- images/                # Gambar (logo, ilustrasi, UI assets)
    |-- ios/                       # Build & konfigurasi aplikasi iOS (Xcode project)
    |-- lib/                       # Core source code Flutter
    |   |-- services/              # API request ke backend (*.dart)
    |   |-- utils/                 # Utility & helper function (*.dart)
    |   |-- *.dart                 # Halaman UI (main, login, home)
    |   .gitignore                 # Mengabaikan build/ dan .dart_tool/"""
    
    # Replace unicode vertical bars in manual text block
    folder_tree = folder_tree.replace("│", "|").replace("├", "|").replace("└", "+").replace("─", "-")
    
    pdf.code_block(folder_tree)

    # --- SECTION 5: SKEMA DATABASE ---
    pdf.chapter_title("5. Skema Database Global (db_amanin)")
    pdf.paragraph("Tabel users digunakan untuk autentikasi pengguna pada aplikasi AMANIN:")
    
    db_schema = """CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);"""
    pdf.code_block(db_schema)

    # --- PAGE 3 ---
    pdf.add_page()

    # --- SECTION 6: LOGIC PENTING ---
    pdf.chapter_title("6. Logic Penting & Endpoint Backend ML (Wajib Ada)")
    
    pdf.section_title("6.1. Aliran Data Gempa Terpusat (Mediator)")
    pdf.paragraph(
        "Aplikasi Flutter melakukan request ke backend FastAPI. Backend menembak API BMKG, "
        "mengambil respon JSON eksternal, melakukan preprocessing, memanggil model ML masing-masing "
        "fitur, lalu mengembalikan satu respon gabungan yang bersih ke Flutter."
    )
    
    pdf.section_title("6.2. Fitur 1 (Dava) - Klasifikasi Tingkat Risiko (SVM)")
    pdf.paragraph(
        "Mengklasifikasikan risiko gempa bumi (Rendah, Sedang, Tinggi) berdasarkan magnitudo, kedalaman, "
        "dan koordinat. Endpoint: POST /predict. Menggunakan preprocessing manual Min-Max Scaling berdasarkan "
        "batas dataset training: BMKG Min [1.0, 1.0, -7.998, 106.0], Max [7.191, 649.067, -5.501, 108.998]."
    )
    
    pdf.section_title("6.3. Fitur 2 (Kevin) - Rekomendasi Edukasi (K-Means)")
    pdf.paragraph(
        "Mengelompokkan daerah bencana gempa bumi berdasarkan magnitude, kedalaman, dan koordinat. "
        "Endpoint: POST /predict-edukasi. Logika backend mencocokkan koordinat GPS kecamatan pengguna ke cluster "
        "risiko terdekat untuk menampilkan artikel edukasi mitigasi bencana yang relevan."
    )
    
    pdf.section_title("6.4. Fitur 3 (Fuad) - Deteksi Anomali Seismisitas (Isolation Forest & XGBoost)")
    pdf.paragraph(
        "Mendeteksi anomali seismisitas berdasarkan parameter spasial dan temporal (gap, dmin, nst, kedalaman, "
        "bulan, jam). Endpoint: POST /predict-anomali. Respon mengembalikan status is_anomali (True/False) dan "
        "confidence score."
    )

    pdf.section_title("6.5. Fitur 4 (Gilang) - Klasifikasi Main/Aftershock (Random Forest)")
    pdf.paragraph(
        "Mengklasifikasikan status gempa apakah merupakan gempa utama (Mainshock) atau gempa susulan "
        "(Aftershock) berdasarkan kesamaan spasial-temporal dengan gempa besar sebelumnya menggunakan Random Forest. "
        "Endpoint: POST /predict-shock."
    )
    
    # --- PAGE 4 ---
    pdf.add_page()
    
    # --- SECTION 7: STANDAR RESPONSE API ---
    pdf.chapter_title("7. Standar Response API")
    
    pdf.section_title("7.1. Login Success Response (POST /login)")
    login_resp = """{
  "message": "Login berhasil!",
  "user_id": 1,
  "full_name": "Dava Ihza",
  "email": "dava@mail.com"
}"""
    pdf.code_block(login_resp)

    pdf.section_title("7.2. Prediksi Risiko Gempa Response (POST /predict)")
    pred_resp = """{
  "risk_level": "Sedang",
  "prediction_code": 1,
  "confidence": 0.8421
}"""
    pdf.code_block(pred_resp)

    # --- PAGE 5 ---
    pdf.add_page()

    # --- SECTION 9: ATURAN & ALUR KERJA GIT (WAJIB DIPATUHI) ---
    pdf.chapter_title("8. Aturan & Alur Kerja Git (Wajib Dipatuhi)")
    pdf.paragraph(
        "Untuk menghindari konflik kode (merge conflict) dan menjaga kebersihan riwayat commit repositori "
        "GitHub, seluruh anggota kelompok wajib mematuhi panduan Git berikut secara ketat."
    )
    
    pdf.section_title("8.1. Format Pesan Commit (Conventional Commits)")
    pdf.paragraph(
        "Pesan commit harus informatif dan mencerminkan perubahan yang dilakukan. Gunakan prefix berikut:\n"
        "- feat: untuk penambahan fitur baru (contoh: feat: tambah endpoint predict-anomali)\n"
        "- fix: untuk perbaikan bug/error (contoh: fix: perbaikan base url koneksi database)\n"
        "- refactor: untuk restrukturisasi kode tanpa mengubah fungsi (contoh: refactor: bersihkan file ipynb)\n"
        "- chore: untuk pemeliharaan berkas konfigurasi/dependensi (contoh: chore: update requirements.txt)\n\n"
        "Dilarang keras menulis pesan commit satu kata atau tidak jelas (contoh: 'push', 'update', 'fix')."
    )
    
    pdf.section_title("8.2. Alur Kerja Git Harian (Git Daily Workflow)")
    
    git_workflow_text = """# Langkah 1: Sinkronisasi Awal (di branch main)
git checkout main
git pull origin main

# Langkah 2: Buat Branch Baru untuk Fitur/Bugfix
git checkout -b feat/nama-fitur-anda
# (Kerjakan codingan Anda di branch ini)

# Langkah 3: Tambahkan Berkas dan Commit Lokal
git add .
git commit -m "feat: deskripsi singkat perubahan Anda"

# Langkah 4: Push Branch Anda ke GitHub
git push origin feat/nama-fitur-anda

# Langkah 5: Buat Pull Request & Merge di Website GitHub
# (Buka github.com/Kevinpb86/Tugas-Akhir2 dan klik 'Compare & pull request')
# (Lakukan merge ke main setelah dikoordinasikan dengan tim)

# Langkah 6: Kembali ke main lokal dan sinkronisasi kembali
git checkout main
git pull origin main
git branch -d feat/nama-fitur-anda"""

    pdf.code_block(git_workflow_text)

    # --- PAGE 6 ---
    pdf.add_page()

    # --- SECTION 8: TEMPLATE PROMPT AI ---
    pdf.chapter_title("9. Template Prompt AI (Wajib Dipakai)")
    pdf.paragraph(
        "Gunakan template prompt berikut saat memulai obrolan baru dengan AI Agent "
        "(Antigravity / Claude / ChatGPT) untuk menjaga konsistensi pengerjaan kode:"
    )
    
    prompt_template = """Halo! Saya sedang mengembangkan proyek Tugas Akhir bernama AMANIN
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
[TULIS PERMINTAAN SPESIFIK KAMU DI SINI]"""
    
    pdf.code_block(prompt_template)
    
    target_path = os.path.join("c:\\Users\\DAVA\\Documents\\SEMUA FILE TUGAS\\FOLDER KULIAH\\SEMESTER 8\\TUGAS AKHIR (TA)", filename)
    pdf.output(target_path)
    print(f"PDF successfully generated at: {target_path}")

if __name__ == "__main__":
    build_pdf()
