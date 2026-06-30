import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'panduan_evakuasi_waspada.dart';

class EdukasiWaspadaPage extends StatefulWidget {
  final String cityName;
  final String locationCategory;

  const EdukasiWaspadaPage({
    super.key,
    required this.cityName,
    this.locationCategory = 'Dalam Ruangan',
  });

  @override
  State<EdukasiWaspadaPage> createState() => _EdukasiWaspadaPageState();
}

class _EdukasiWaspadaPageState extends State<EdukasiWaspadaPage> {
  late String _currentCategory;

  @override
  void initState() {
    super.initState();
    _currentCategory = widget.locationCategory;
  }

  @override
  Widget build(BuildContext context) {
    String siagaDesc = '';
    String saatGempaDesc = '';
    String pascaGempaDesc = '';

    if (_currentCategory == 'Pegunungan') {
      siagaDesc = 'Waspadai jalur longsor. Kenali titik kumpul dan perhatikan informasi cuaca sebelum mendaki.';
      saatGempaDesc = 'Menjauh dari tebing. Hentikan aktivitas, cari perlindungan dari benda jatuh, dan jangan panik.';
      pascaGempaDesc = 'Tetap waspada longsor susulan. Cari area datar yang aman dan pantau arahan petugas.';
    } else if (_currentCategory == 'Pesisir Pantai') {
      siagaDesc = 'Kenali jalur evakuasi dan titik kumpul. Pahami tanda bahaya tsunami di area pesisir.';
      saatGempaDesc = 'Segera jauhi bibir pantai. Cari area tinggi dan perhatikan kondisi air laut secara waspada.';
      pascaGempaDesc = 'Tetap bertahan di tempat tinggi. Jangan kembali ke pantai sebelum ada arahan resmi.';
    } else if (_currentCategory == 'Luar Ruangan') {
      siagaDesc = 'Ketahui area lapang yang aman. Hindari tempat dengan banyak pohon besar atau papan reklame.';
      saatGempaDesc = 'Jauhi bangunan tinggi, tiang, dan pohon. Cari tanah lapang dan lindungi kepala Anda.';
      pascaGempaDesc = 'Periksa keadaan sekitar dari benda yang berisiko jatuh. Tetap tenang di titik kumpul.';
    } else {
      // Dalam Ruangan
      siagaDesc = 'Kenali titik aman, perhatikan jalur keluar, dan rapikan benda yang mudah jatuh.';
      saatGempaDesc = 'Berhenti beraktivitas dan berlindung di tempat aman. Lindungi kepala, jauhi kaca, dan jangan gunakan lift.';
      pascaGempaDesc = 'Tunggu guncangan reda, lalu evakuasi perlahan menuju titik kumpul yang aman di luar gedung.';
    }

    final categoryIcons = {
      'Dalam Ruangan': Icons.home_rounded,
      'Luar Ruangan': Icons.landscape_rounded,
      'Pesisir Pantai': Icons.beach_access_rounded,
      'Pegunungan': Icons.terrain_rounded,
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Consistent subtle background
      appBar: AppBar(
        title: const Text(
          'Panduan Status Waspada',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFC107), // Bright Yellow
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
                  colors: [Color(0xFFFFC107), Color(0xFFFFB300)], // Bright Yellow gradient
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
                      color: Colors.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'PERINGATAN KATEGORI WASPADA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Zona Risiko Gempa Bumi Waspada\n(${widget.cityName})',
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
                    'Wilayah Anda teridentifikasi memiliki tingkat kerawanan gempa bumi menengah/waspada. Tetap tenang, tingkatkan kewaspadaan, dan kenali lingkungan sekitar Anda.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.90),
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
                  // Lokasi Terdeteksi Badge
                  Row(
                    children: [
                      const Text(
                        'Lokasi Terdeteksi:',
                        style: TextStyle(
                          color: Color(0xFF374151),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC107).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFFFC107).withValues(alpha: 0.50),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              categoryIcons[_currentCategory],
                              size: 14,
                              color: const Color(0xFFFFC107),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _currentCategory,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFFFC107),
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Section Title
                  _buildSectionTitle(
                    'Langkah Edukasi Mandiri',
                    Icons.menu_book_rounded,
                    const Color(0xFFFFC107),
                  ),
                  const SizedBox(height: 10),

                  // Mitigation Cards
                  _buildMitigationCard(
                    '1. PRABENCANA (SIAGA)',
                    siagaDesc,
                    Icons.home_work_rounded,
                    const Color(0xFFFFCB47),
                    0,
                  ),
                  const SizedBox(height: 10),
                  _buildMitigationCard(
                    '2. SAAT BENCANA (RESPONS)',
                    saatGempaDesc,
                    Icons.crisis_alert_rounded,
                    const Color(0xFFFFD54F),
                    1,
                  ),
                  const SizedBox(height: 10),
                  _buildMitigationCard(
                    '3. PASCABENCANA (PULIH)',
                    pascaGempaDesc,
                    Icons.check_circle_rounded,
                    const Color(0xFF10B981),
                    2,
                  ),
                  const SizedBox(height: 24),

                  // Emergency Contact Section
                  _buildSectionTitle(
                    'Panggilan Darurat Cepat',
                    Icons.phone_in_talk_rounded,
                    const Color(0xFF1976D2),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _buildEmergencyCard(
                          'BASARNAS',
                          '115',
                          Icons.local_hospital_rounded,
                          const Color(0xFFEF4444),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildEmergencyCard(
                          'PANGGILAN DARURAT',
                          '112',
                          Icons.phone_android_rounded,
                          const Color(0xFF3B82F6),
                        ),
                      ),
                    ],
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
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: Colors.black87, // Black title text
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildMitigationCard(
    String title,
    String body,
    IconData icon,
    Color accentColor,
    int tabIndex,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Flat white card
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // Watermark background icon
            Positioned(
              right: -12,
              bottom: -12,
              child: Opacity(
                opacity: 0.08,
                child: Icon(
                  icon,
                  size: 85,
                  color: const Color(0xFFFFC107),
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PanduanEvakuasiWaspadaPage(
                        cityName: widget.cityName,
                        initialTabIndex: tabIndex,
                        locationCategory: _currentCategory,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC107).withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: const Color(0xFFFFC107), size: 22),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFFFFC107), // Yellow heading
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: const Color(0xFFFFC107).withValues(alpha: 0.80),
                                  size: 11,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              body,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87, // Black description
                                height: 1.45,
                                fontWeight: FontWeight.w600,
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
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyCard(
    String label,
    String number,
    IconData icon,
    Color accentColor,
  ) {

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          final messenger = ScaffoldMessenger.of(context);
          final Uri url = Uri.parse('tel:$number');
          if (await canLaunchUrl(url)) {
            await launchUrl(url);
          } else {
            messenger.showSnackBar(
              SnackBar(
                content: Text('Tidak dapat memanggil nomor $number secara otomatis.'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: accentColor, // Flat solid red or blue
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Watermark background icon
                Positioned(
                  right: -15,
                  bottom: -15,
                  child: Opacity(
                    opacity: 0.15,
                    child: Icon(
                      icon,
                      size: 65,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.20),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              color: Colors.white70,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                number,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.phone_forwarded_rounded,
                                size: 11,
                                color: Colors.white.withValues(alpha: 0.70),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


