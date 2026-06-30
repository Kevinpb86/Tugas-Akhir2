import 'package:flutter/material.dart';
import 'mitigasi_gempa.dart';
import 'panduan_evakuasi_bahaya.dart';

class EdukasiBahayaPage extends StatefulWidget {
  final String cityName;
  final String locationCategory;

  const EdukasiBahayaPage({
    super.key,
    required this.cityName,
    this.locationCategory = 'Dalam Ruangan',
  });

  @override
  State<EdukasiBahayaPage> createState() => _EdukasiBahayaPageState();
}

class _EdukasiBahayaPageState extends State<EdukasiBahayaPage> {
  @override
  Widget build(BuildContext context) {
    String siagaDesc = '';
    String saatGempaDesc = '';
    String pascaGempaDesc = '';

    if (widget.locationCategory == 'Pegunungan') {
      siagaDesc = 'Pahami area longsor kritis dan tebing rapuh. Tentukan titik kumpul yang jauh dari bukit curam.';
      saatGempaDesc = 'Segera menjauh dari tebing dan lereng curam. Waspadai jatuhan batu besar dan longsor susulan.';
      pascaGempaDesc = 'Tinggalkan area tebing secepatnya. Jangan pernah kembali ke lereng yang retak atau labil.';
    } else if (widget.locationCategory == 'Pesisir Pantai') {
      siagaDesc = 'Pastikan jalur evakuasi tsunami dan titik kumpul di area tinggi telah diketahui pasti.';
      saatGempaDesc = 'LARI! Tinggalkan barang bawaan dan segera evakuasi ke tempat tinggi menjauhi garis pantai.';
      pascaGempaDesc = 'Jangan turun ke pantai hingga ada pencabutan peringatan tsunami resmi dari BMKG.';
    } else if (widget.locationCategory == 'Luar Ruangan') {
      siagaDesc = 'Ketahui letak tanah lapang yang benar-benar terbuka tanpa gedung tinggi atau tiang listrik.';
      saatGempaDesc = 'Jauhi struktur bangunan, jembatan, tiang listrik, dan pohon besar. Berlindung di tanah lapang.';
      pascaGempaDesc = 'Waspadai gempa susulan. Jauhi area yang tampak retak, tiang miring, atau kabel terputus.';
    } else {
      // Dalam Ruangan
      siagaDesc = 'Identifikasi tempat aman di rumah Anda dan pastikan rute evakuasi bersih dari hambatan.';
      saatGempaDesc = 'DROP, COVER, HOLD ON! Lindungi kepala, berlindung di bawah meja kokoh, dan jauhi kaca.';
      pascaGempaDesc = 'Setelah guncangan utama reda, segera tinggalkan gedung melalui tangga darurat dengan cepat.';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Modern subtle background
      appBar: AppBar(
        title: const Text(
          'Panduan Bahaya Tinggi',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: -0.5,
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
                  colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
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
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Zona Risiko Gempa Tinggi\n(${widget.cityName})',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      letterSpacing: -0.5,
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
                    siagaDesc,
                    Icons.home_work_rounded,
                    const Color(0xFFD32F2F),
                    0,
                  ),
                  const SizedBox(height: 10),
                  _buildEvacuationCard(
                    '2. SAAT GEMPA (Guncangan)',
                    saatGempaDesc,
                    Icons.security_rounded,
                    const Color(0xFFD32F2F),
                    1,
                  ),
                  const SizedBox(height: 10),
                  _buildEvacuationCard(
                    '3. PASCA GEMPA (Setelah Gempa)',
                    pascaGempaDesc,
                    Icons.directions_run_rounded,
                    const Color(0xFFD32F2F),
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PanduanEvakuasiBahayaPage(
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
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: color,
                            letterSpacing: -0.2,
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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
