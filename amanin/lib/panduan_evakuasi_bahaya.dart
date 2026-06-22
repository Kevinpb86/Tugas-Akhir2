import 'package:flutter/material.dart';

class PanduanEvakuasiBahayaPage extends StatefulWidget {
  final String cityName;
  final int initialTabIndex;

  const PanduanEvakuasiBahayaPage({
    super.key,
    required this.cityName,
    this.initialTabIndex = 0,
  });

  @override
  State<PanduanEvakuasiBahayaPage> createState() =>
      _PanduanEvakuasiBahayaPageState();
}

class _PanduanEvakuasiBahayaPageState extends State<PanduanEvakuasiBahayaPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5), // Premium warm soft white
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              'Panduan Evakuasi Kritis',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Bahaya Tinggi • ${widget.cityName}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFD32F2F), // Warning Red
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3.5,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          tabs: const [
            Tab(
              icon: Icon(Icons.home_work_rounded, size: 18),
              text: 'Siaga (Sebelum)',
            ),
            Tab(
              icon: Icon(Icons.security_rounded, size: 18),
              text: 'Selamatkan Diri (Saat)',
            ),
            Tab(
              icon: Icon(Icons.directions_run_rounded, size: 18),
              text: 'Evakuasi (Setelah)',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildSiagaTab(),
          _buildSelamatkanDiriTab(),
          _buildEvakuasiTab(),
        ],
      ),
    );
  }

  // --- TAB 1: SIAGA (SEBELUM GEMPA) ---
  Widget _buildSiagaTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildPriorityCard(
          title: 'ZONA RISIKO TINGGI',
          message:
              'Wilayah Anda memiliki sejarah seismik aktif. Persiapan yang matang sebelum gempa dapat meminimalkan cedera hingga 90%.',
          color: const Color(0xFFD32F2F),
          icon: Icons.error_outline_rounded,
        ),
        const SizedBox(height: 16),
        _buildSectionHeader('1. Tata Ruang & Perabotan Aman'),
        _buildInstructionTile(
          icon: Icons.grid_view_rounded,
          color: const Color(0xFF1976D2),
          title: 'Amankan Benda Berat',
          desc:
              'Pasang sekrup/braket pada lemari tinggi, rak buku, dan kulkas agar tidak roboh saat guncangan.',
        ),
        _buildInstructionTile(
          icon: Icons.broken_image_outlined,
          color: const Color(0xFF1976D2),
          title: 'Jauhkan Barang Pecah Belah',
          desc:
              'Simpan piring, gelas, barang pecah belah, dan zat kimia berbahaya di laci bawah atau kabinet yang terkunci.',
        ),
        _buildInstructionTile(
          icon: Icons.bedtime_outlined,
          color: const Color(0xFF1976D2),
          title: 'Bebaskan Tempat Tidur',
          desc:
              'Jangan gantung cermin, lukisan besar, atau AC tepat di atas tempat tidur Anda.',
        ),
        const SizedBox(height: 18),
        _buildSectionHeader('2. Perencanaan Darurat Keluarga'),
        _buildInstructionTile(
          icon: Icons.family_restroom_rounded,
          color: const Color(0xFF388E3C),
          title: 'Tentukan Titik Kumpul Aman',
          desc:
              'Pilih tanah lapang terbuka yang jauh dari tiang listrik, gedung, dan pohon besar sebagai tempat berkumpul keluarga.',
        ),
        _buildInstructionTile(
          icon: Icons.route_rounded,
          color: const Color(0xFF388E3C),
          title: 'Kenali Jalur Keluar Utama',
          desc:
              'Pastikan pintu keluar dan lorong rumah selalu bersih dari barang-barang yang menghalangi jalan evakuasi.',
        ),
        _buildInstructionTile(
          icon: Icons.contact_phone_rounded,
          color: const Color(0xFF388E3C),
          title: 'Siapkan Kontak Darurat',
          desc:
              'Catat nomor telepon BPBD setempat, Basarnas, dan rumah sakit terdekat. Simpan di ponsel dan tempel di area kulkas.',
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // --- TAB 2: SELAMATKAN DIRI (SAAT GEMPA) ---
  Widget _buildSelamatkanDiriTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildPriorityCard(
          title: 'TINDAKAN KRITIS INSTAN',
          message:
              'Tetap tenang dan jangan mencoba berlari ke luar saat guncangan sedang kuat berlangsung. Sebagian besar cedera terjadi saat orang berlarian.',
          color: const Color(0xFFE64A19),
          icon: Icons.bolt_rounded,
        ),
        const SizedBox(height: 16),
        _buildSectionHeader('Panduan Keselamatan Saat Gempa'),
        _buildInstructionTile(
          icon: Icons.landscape_rounded,
          color: const Color(0xFF388E3C),
          title: 'Pilih Titik Aman di Ruang Terbuka',
          desc:
              'Bergeraklah ke area yang tidak berada di dekat bangunan, tembok tinggi, papan reklame, jembatan, atau struktur lain yang berpotensi runtuh ketika terjadi guncangan.',
        ),
        _buildInstructionTile(
          icon: Icons.visibility_rounded,
          color: const Color(0xFFF57C00),
          title: 'Amati Sumber Bahaya di Sekitar',
          desc:
              'Perhatikan benda tinggi seperti tiang listrik, pohon besar, lampu jalan, dan kabel menggantung. Jaga jarak dari benda tersebut karena dapat roboh atau jatuh akibat guncangan.',
        ),
        _buildInstructionTile(
          icon: Icons.domain_disabled_rounded,
          color: const Color(0xFFD32F2F),
          title: 'Hindari Sisi Luar Bangunan',
          desc:
              'Jangan berdiri di dekat dinding gedung, kaca, etalase, pagar beton, atau bangunan yang terlihat retak karena bagian tersebut dapat pecah atau runtuh.',
        ),
        _buildInstructionTile(
          icon: Icons.shield_rounded,
          color: const Color(0xFF1976D2),
          title: 'Lindungi Bagian Kepala dan Leher',
          desc:
              'Gunakan tas, jaket, tangan, atau benda lain yang tersedia untuk mengurangi risiko terkena pecahan kaca, material bangunan, atau benda jatuh.',
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // --- TAB 3: SEGERA EVAKUASI (SETELAH GEMPA) ---
  Widget _buildEvakuasiTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildPriorityCard(
          title: 'EVAKUASI TERTIB & CEPAT',
          message:
              'Selalu waspadai potensi gempa susulan. Setelah guncangan berhenti, segera keluar gedung menuju zona aman luar ruangan.',
          color: const Color(0xFF388E3C),
          icon: Icons.check_circle_outline_rounded,
        ),
        const SizedBox(height: 16),
        _buildSectionHeader('1. Langkah Segera Setelah Gempa'),
        _buildInstructionTile(
          icon: Icons.exit_to_app_rounded,
          color: const Color(0xFF388E3C),
          title: 'Keluar dengan Tenang',
          desc:
              'Gunakan jalur tangga darurat. Jangan pernah menggunakan lift karena berisiko terjebak akibat listrik padam.',
        ),
        _buildInstructionTile(
          icon: Icons.fire_extinguisher_rounded,
          color: const Color(0xFF388E3C),
          title: 'Periksa Kebocoran Gas & Api',
          desc:
              'Matikan kompor, cabut selang tabung gas, dan matikan saklar listrik utama sebelum keluar rumah jika memungkinkan.',
        ),
        _buildInstructionTile(
          icon: Icons.health_and_safety_rounded,
          color: const Color(0xFF388E3C),
          title: 'Bantu Orang yang Rentan',
          desc:
              'Berikan pertolongan atau tuntun anak-anak, lansia, wanita hamil, dan penyandang disabilitas di dekat Anda.',
        ),
        const SizedBox(height: 18),
        _buildSectionHeader('2. Di Titik Kumpul Darurat'),
        _buildInstructionTile(
          icon: Icons.cell_tower_rounded,
          color: const Color(0xFF1976D2),
          title: 'Pantau Informasi Resmi BMKG',
          desc:
              'Gunakan radio portabel atau internet ponsel untuk memantau status bahaya atau potensi tsunami dari BMKG. Jangan termakan hoaks.',
        ),
        _buildInstructionTile(
          icon: Icons.warning_rounded,
          color: const Color(0xFFD32F2F),
          title: 'Jauhi Bangunan Rusak',
          desc:
              'Jangan kembali ke dalam rumah atau gedung yang mengalami keretakan struktur sebelum dipastikan aman oleh petugas berwenang.',
        ),
        const SizedBox(height: 20),
        _buildEmergencyCallSection(),
        const SizedBox(height: 20),
      ],
    );
  }

  // --- WIDGET PENDUKUNG ---
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: Color(0xFF555555),
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildPriorityCard({
    required String title,
    required String message,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF2C3E50),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionTile({
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F1F1), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyCallSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: const Color(0xFFECEFF1), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.phone_in_talk_rounded,
                color: Color(0xFFD32F2F),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Hubungi Pihak Berwajib',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildCallButton(
                  'BASARNAS',
                  '115',
                  const Color(0xFFE64A19),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildCallButton(
                  'Darurat Umum',
                  '112',
                  const Color(0xFF1976D2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCallButton(String label, String number, Color color) {
    return OutlinedButton.icon(
      onPressed: () {
        // Aksi panggilan (simulasi)
      },
      icon: Icon(Icons.call, size: 14, color: color),
      label: Text(
        '$label ($number)',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withValues(alpha: 0.5), width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      ),
    );
  }
}
