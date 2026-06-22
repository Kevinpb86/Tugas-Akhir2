import 'package:flutter/material.dart';
import 'mitigasi_gempa.dart';
import 'panduan_evakuasi_bahaya.dart';

class EdukasiBahayaPage extends StatefulWidget {
  final String cityName;
  const EdukasiBahayaPage({super.key, required this.cityName});

  @override
  State<EdukasiBahayaPage> createState() => _EdukasiBahayaPageState();
}

class _EdukasiBahayaPageState extends State<EdukasiBahayaPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6), // Warm off-white
      appBar: AppBar(
        title: const Text(
          'Panduan Bahaya Tinggi',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFD32F2F), // Warning Red
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
                  colors: [Color(0xFFD32F2F), Color(0xFFC2185B)],
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
                    'Peringatan Kategori Tinggi'.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Zona Risiko Gempa Bumi Tinggi\n(${widget.cityName})',
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
                    'Wilayah Anda teridentifikasi memiliki tingkat kerawanan gempa bumi yang tinggi. Harap pelajari instruksi keselamatan di bawah ini dan siapkan rencana evakuasi mandiri.',
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
                    'Langkah Evakuasi Utama (3S)',
                    Icons.flash_on_rounded,
                    const Color(0xFFD32F2F),
                  ),
                  const SizedBox(height: 10),
                  _buildEvacuationCard(
                    '1. SIAGA (Sebelum Gempa)',
                    'Identifikasi tempat aman di rumah Anda (kolong meja kuat, pilar utama) dan tentukan jalur tercepat menuju ruang terbuka luas.',
                    Icons.home_work_rounded,
                    const Color(0xFF1976D2),
                    0,
                  ),
                  const SizedBox(height: 10),
                  _buildEvacuationCard(
                    '2. SELAMATKAN DIRI (Saat Gempa)',
                    'DROP, COVER, HOLD ON! Merunduklah, lindungi kepala dengan lengan/bantal, berlindung di bawah meja kokoh, dan jauhi jendela kaca.',
                    Icons.security_rounded,
                    const Color(0xFFF57C00),
                    1,
                  ),
                  const SizedBox(height: 10),
                  _buildEvacuationCard(
                    '3. SEGERA EVAKUASI (Setelah Gempa)',
                    'Keluar gedung dengan tertib lewat jalur evakuasi. Jangan gunakan lift. Menujulah ke titik kumpul terbuka di luar area bangunan.',
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
                        backgroundColor: const Color(0xFFD32F2F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        shadowColor: const Color(
                          0xFFD32F2F,
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
                  builder: (context) => PanduanEvakuasiBahayaPage(
                    cityName: widget.cityName,
                    initialTabIndex: tabIndex,
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
