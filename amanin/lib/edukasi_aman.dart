import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
      siagaDesc = 'Kondisi aman, namun tetap perhatikan jalur pendakian yang stabil dan cuaca sekitar.';
      saatGempaDesc = 'Jika terasa getaran kecil, berhentilah sejenak. Jaga keseimbangan agar tidak tergelincir.';
      pascaGempaDesc = 'Periksa keadaan sekitar dengan tenang sebelum melanjutkan perjalanan atau aktivitas di alam.';
    } else if (widget.locationCategory == 'Pesisir Pantai') {
      siagaDesc = 'Kenali area sekitar pantai. Pahami letak posko keselamatan dan rute jalan umum.';
      saatGempaDesc = 'Getaran sangat kecil atau tidak terasa. Tetap tenang dan amati ombak secara wajar.';
      pascaGempaDesc = 'Kondisi laut aman. Lanjutkan aktivitas liburan atau pekerjaan Anda di pesisir dengan normal.';
    } else if (widget.locationCategory == 'Luar Ruangan') {
      siagaDesc = 'Lingkungan aman. Kenali lokasi dengan baik dan nikmati aktivitas ruang terbuka.';
      saatGempaDesc = 'Getaran skala kecil. Berhentilah sejenak jika Anda merasa limbung, dan tetap tenang.';
      pascaGempaDesc = 'Lanjutkan perjalanan atau aktivitas Anda dengan normal setelah merasa getaran berhenti.';
    } else {
      // Dalam Ruangan
      siagaDesc = 'Lingkungan aman. Biasakan menata ruangan agar rapi dan simpan barang berat di bawah.';
      saatGempaDesc = 'Guncangan skala aman tidak merusak. Tetap di tempat Anda dan tunggu getaran reda.';
      pascaGempaDesc = 'Periksa kondisi di sekitar dengan tenang. Lanjutkan aktivitas normal setelah dirasa aman.';
    }

    final categoryIcons = {
      'Dalam Ruangan': Icons.home_rounded,
      'Luar Ruangan': Icons.landscape_rounded,
      'Pesisir Pantai': Icons.beach_access_rounded,
      'Pegunungan': Icons.terrain_rounded,
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Modern subtle background
      appBar: AppBar(
        title: const Text(
          'Panduan Status Aman',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF4ADE80), // Matches gradient start
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
                  colors: [Color(0xFF4ADE80), Color(0xFF16A34A)],
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
                    'Kategori Aman'.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Zona Risiko Gempa Rendah\n(${widget.cityName})',
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
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF4CAF50).withValues(alpha: 0.50),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              categoryIcons[widget.locationCategory],
                              size: 14,
                              color: const Color(0xFF388E3C),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.locationCategory,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF388E3C),
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
                    'Langkah Keselamatan (3S)',
                    Icons.flash_on_rounded,
                    const Color(0xFF4CAF50),
                  ),
                  const SizedBox(height: 10),
                  _buildEvacuationCard(
                    '1. SIAGA (Sebelum Gempa)',
                    siagaDesc,
                    Icons.home_work_rounded,
                    const Color(0xFF4CAF50),
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
                    const Color(0xFF4CAF50),
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
                          const Color(0xFFEF4444),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildEmergencyContactCard(
                          'PANGGILAN DARURAT',
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
    Color accentColor,
    int tabIndex,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Opacity(
                opacity: 0.08,
                child: Icon(
                  icon,
                  size: 85,
                  color: accentColor,
                ),
              ),
            ),
            Material(
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
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: accentColor, size: 22),
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
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w900,
                                      color: accentColor, // Green heading
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: accentColor.withValues(alpha: 0.80),
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

  Widget _buildEmergencyContactCard(
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
                      Expanded(
                        child: Column(
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
                                Flexible(
                                  child: Text(
                                    number,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      height: 1.1,
                                    ),
                                    overflow: TextOverflow.ellipsis,
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
