import 'package:flutter/material.dart';
import 'mitigasi_gempa.dart';
import 'panduan_evakuasi_aman.dart';

class EdukasiAmanPage extends StatefulWidget {
  final String cityName;
  final String locationCategory;

  const EdukasiAmanPage({
    super.key,
    required this.cityName,
    this.locationCategory = 'Dalam Ruangan',
  });

  @override
  State<EdukasiAmanPage> createState() => _EdukasiAmanPageState();
}

class _EdukasiAmanPageState extends State<EdukasiAmanPage> {
  @override
  Widget build(BuildContext context) {
    String siagaDesc = '';
    String saatGempaDesc = '';
    String pascaGempaDesc = '';

    if (widget.locationCategory == 'Pegunungan') {
      siagaDesc = 'Kondisi aman, namun pastikan fisik Anda prima dan bekal mencukupi untuk kenyamanan aktivitas di alam.';
      saatGempaDesc = 'Jika sedang berjalan, berhentilah sejenak. Jaga keseimbangan tubuh agar tidak tergelincir saat ada getaran kecil.';
      pascaGempaDesc = 'Lihat sepintas apakah ada kerikil yang jatuh ke jalur pendakian. Lanjutkan perjalanan jika sudah bersih.';
    } else if (widget.locationCategory == 'Pesisir Pantai') {
      siagaDesc = 'Pahami letak posko keselamatan dan rute jalan keluar umum dari pantai untuk kenyamanan berlibur Anda.';
      saatGempaDesc = 'Guncangan yang terjadi tergolong ringan. Jangan panik berlarian; berhentilah sejenak dari aktivitas Anda.';
      pascaGempaDesc = 'Gempa berisiko rendah tidak mengganggu kegiatan. Anda bisa kembali menikmati suasana pantai dengan rileks.';
    } else if (widget.locationCategory == 'Luar Ruangan') {
      siagaDesc = 'Perhatikan lingkungan sekitar saat beraktivitas di taman atau jalan umum agar Anda familiar dengan lokasi.';
      saatGempaDesc = 'Getaran skala kecil di luar ruangan mungkin nyaris tidak terasa. Berhentilah jika Anda merasa sedikit limbung.';
      pascaGempaDesc = 'Tidak ada kerusakan atau bahaya yang mengancam. Silakan beraktivitas secara normal kembali.';
    } else {
      // Dalam Ruangan
      siagaDesc = 'Kondisi lingkungan aman. Biasakan menata ruangan agar rapi dan letakkan barang berat di bagian bawah lemari.';
      saatGempaDesc = 'Guncangan skala aman tidak merusak bangunan. Tetap di tempat Anda dan tunggu hingga getaran reda.';
      pascaGempaDesc = 'Kondisi telah kembali normal sepenuhnya. Anda bisa melanjutkan aktivitas bekerja atau bersantai.';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6), // Warm off-white
      appBar: AppBar(
        title: const Text(
          'Panduan Status Aman',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF4CAF50), // Warning Yellow
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Warning Header Card
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Kategori Aman'.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Zona Risiko Gempa Bumi Rendah\n(${widget.cityName})',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Wilayah Anda teridentifikasi memiliki tingkat kerawanan gempa bumi rendah/aman. Tidak ada potensi kerusakan berarti, namun tetap kenali lingkungan sekitar Anda.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section 1: Protokol Evakuasi Cepat
                  _buildSectionTitle(
                    'Langkah Keselamatan (3S)',
                    Icons.flash_on_rounded,
                    const Color(0xFF4CAF50),
                  ),
                  const SizedBox(height: 10),
                  _buildEvacuationCard(
                    '1. SIAGA (Sebelum Gempa)',
                    siagaDesc,
                    Icons.home_work_rounded,
                    const Color(0xFF1976D2),
                    0,
                  ),
                  const SizedBox(height: 10),
                  _buildEvacuationCard(
                    '2. SAAT GEMPA (Guncangan)',
                    saatGempaDesc,
                    Icons.security_rounded,
                    const Color(0xFF4CAF50),
                    1,
                  ),
                  const SizedBox(height: 10),
                  _buildEvacuationCard(
                    '3. PASCA GEMPA (Setelah Gempa)',
                    pascaGempaDesc,
                    Icons.directions_run_rounded,
                    const Color(0xFF388E3C),
                    2,
                  ),
                  const SizedBox(height: 24),
                  
                  // Section 3: Kontak Darurat
                  _buildSectionTitle(
                    'Panggilan Darurat Cepat',
                    Icons.phone_in_talk_rounded,
                    const Color(0xFF1976D2),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildEmergencyContactCard(
                          'BASARNAS',
                          '115',
                          Icons.local_hospital_rounded,
                          const Color(0xFFE64A19),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildEmergencyContactCard(
                          'Panggilan Darurat',
                          '112',
                          Icons.phone_android_rounded,
                          const Color(0xFF388E3C),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Bottom Action: Lihat Panduan Lengkap
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        shadowColor: const Color(
                          0xFF4CAF50,
                        ).withValues(alpha: 0.3),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const MitigasiGempaPage(),
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.menu_book_rounded, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Pelajari Panduan Lengkap Mitigasi',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2C3E50),
          ),
        ),
      ],
    );
  }

  Widget _buildEvacuationCard(
    String title,
    String body,
    IconData icon,
    Color color,
    int tabIndex,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PanduanEvakuasiAmanPage(
                    cityName: widget.cityName,
                    initialTabIndex: tabIndex,
                    locationCategory: widget.locationCategory,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          body,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF4B5563),
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyContactCard(
    String name,
    String phone,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            name,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            phone,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
