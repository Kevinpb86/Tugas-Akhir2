import 'package:flutter/material.dart';

class PanduanEvakuasiAmanPage extends StatelessWidget {
  final String cityName;
  final int initialTabIndex; // Represents the phase: 0=Sebelum, 1=Saat, 2=Setelah
  final String locationCategory; // 'Dalam Ruangan' | 'Luar Ruangan' | 'Pesisir Pantai' | 'Pegunungan'

  const PanduanEvakuasiAmanPage({
    super.key,
    required this.cityName,
    this.initialTabIndex = 0,
    this.locationCategory = 'Dalam Ruangan',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Light calm background
      appBar: null,
      body: _buildContent(context, initialTabIndex),
      floatingActionButton: initialTabIndex == 2
          ? FloatingActionButton.extended(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mensimulasikan panggilan layanan informasi...')),
                );
              },
              backgroundColor: const Color(0xFF10B981), // Safe Green
              icon: const Icon(Icons.info_outline_rounded, color: Colors.white, size: 22),
              label: const Text(
                'INFO BMKG',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
              elevation: 4,
            )
          : null,
    );
  }

  Widget _buildContent(BuildContext context, int index) {
    switch (index) {
      case 0:
        return _buildSiagaContent(context);
      case 1:
        return _buildSaatGempaContent(context);
      case 2:
        return _buildEvakuasiContent(context);
      default:
        return const SizedBox.shrink();
    }
  }

  // ===========================================================================
  // FASE 0: SIAGA (SEBELUM GEMPA)
  // ===========================================================================
  Widget _buildSiagaContent(BuildContext context) {
    if (locationCategory == 'Pesisir Pantai') {
      return _buildPremiumSliverView(
        context: context,
        headerTitle: 'PERSIAPAN DASAR',
        title: 'Kesiapan Aman\ndi Pesisir Pantai',
        gradientColors: const [Color(0xFF2DD4BF), Color(0xFF0F766E)], // Calm Teal
        cards: [
          _buildStandardStepCard(
            number: '1', action: 'KENALI LINGKUNGAN PANTAI',
            desc: 'Pahami letak posko keselamatan dan rute jalan keluar umum dari pantai untuk kenyamanan berlibur Anda.',
            icon: Icons.beach_access_rounded,
            primaryColor: const Color(0xFF0F766E), lightBgColor: const Color(0xFFCCFBF1), borderColor: const Color(0xFF99F6E4), iconBgColor: const Color(0xFFF0FDFA),
          ),
          _buildStandardStepCard(
            number: '2', action: 'BAWA BARANG SECUKUPNYA',
            desc: 'Bawa barang bawaan secukupnya dalam satu tas agar mudah dibawa bergerak jika sewaktu-waktu cuaca berubah.',
            icon: Icons.work_outline_rounded,
            primaryColor: const Color(0xFF0F766E), lightBgColor: const Color(0xFFCCFBF1), borderColor: const Color(0xFF99F6E4), iconBgColor: const Color(0xFFF0FDFA),
          ),
          _buildStandardStepCard(
            number: '3', action: 'PERHATIKAN INFO CUACA',
            desc: 'Selalu ikuti update cuaca normal harian dari BMKG agar aktivitas di pesisir pantai tetap menyenangkan dan aman.',
            icon: Icons.cloud_queue_rounded,
            primaryColor: const Color(0xFF0F766E), lightBgColor: const Color(0xFFCCFBF1), borderColor: const Color(0xFF99F6E4), iconBgColor: const Color(0xFFF0FDFA),
          ),
        ],
      );
    } else if (locationCategory == 'Pegunungan') {
      return _buildPremiumSliverView(
        context: context,
        headerTitle: 'PERSIAPAN DASAR',
        title: 'Kesiapan Aman\ndi Pegunungan',
        gradientColors: const [Color(0xFF34D399), Color(0xFF047857)], // Nature Green
        cards: [
          _buildStandardStepCard(
            number: '1', action: 'PERSIAPKAN FISIK & BEKAL',
            desc: 'Kondisi wilayah aman, namun pastikan fisik Anda prima dan bekal mencukupi untuk kenyamanan aktivitas di alam.',
            icon: Icons.directions_walk_rounded,
            primaryColor: const Color(0xFF047857), lightBgColor: const Color(0xFFD1FAE5), borderColor: const Color(0xFFA7F3D0), iconBgColor: const Color(0xFFECFDF5),
          ),
          _buildStandardStepCard(
            number: '2', action: 'KETAHUI JALUR RESMI',
            desc: 'Gunakan jalur pendakian atau jalan yang sudah resmi dan aman. Jangan membuka jalur baru sendirian.',
            icon: Icons.map_rounded,
            primaryColor: const Color(0xFF047857), lightBgColor: const Color(0xFFD1FAE5), borderColor: const Color(0xFFA7F3D0), iconBgColor: const Color(0xFFECFDF5),
          ),
          _buildStandardStepCard(
            number: '3', action: 'BAWA ALAT KOMUNIKASI',
            desc: 'Pastikan ponsel terisi penuh dan bawa powerbank sebagai langkah komunikasi standar saat berada di pegunungan.',
            icon: Icons.smartphone_rounded,
            primaryColor: const Color(0xFF047857), lightBgColor: const Color(0xFFD1FAE5), borderColor: const Color(0xFFA7F3D0), iconBgColor: const Color(0xFFECFDF5),
          ),
        ],
      );
    } else if (locationCategory == 'Dalam Ruangan') {
      return _buildPremiumSliverView(
        context: context,
        headerTitle: 'PERSIAPAN DASAR',
        title: 'Kesiapan Aman\ndi Dalam Ruangan',
        gradientColors: const [Color(0xFF60A5FA), Color(0xFF1D4ED8)], // Soft Blue
        cards: [
          _buildStandardStepCard(
            number: '1', action: 'TATA BARANG DENGAN RAPI',
            desc: 'Kondisi lingkungan aman. Biasakan menata ruangan agar rapi dan letakkan barang berat di bagian bawah lemari.',
            icon: Icons.home_rounded,
            primaryColor: const Color(0xFF1D4ED8), lightBgColor: const Color(0xFFDBEAFE), borderColor: const Color(0xFFBFDBFE), iconBgColor: const Color(0xFFEFF6FF),
          ),
          _buildStandardStepCard(
            number: '2', action: 'BEBASKAN JALUR KELUAR',
            desc: 'Pastikan pintu keluar dan lorong tidak terhalang oleh barang-barang besar agar aktivitas sehari-hari lebih nyaman.',
            icon: Icons.meeting_room_rounded,
            primaryColor: const Color(0xFF1D4ED8), lightBgColor: const Color(0xFFDBEAFE), borderColor: const Color(0xFFBFDBFE), iconBgColor: const Color(0xFFEFF6FF),
          ),
          _buildStandardStepCard(
            number: '3', action: 'SIAPKAN KOTAK P3K',
            desc: 'Miliki kotak P3K standar di dalam rumah atau kantor untuk pertolongan pertama kecelakaan ringan sehari-hari.',
            icon: Icons.medical_services_rounded,
            primaryColor: const Color(0xFF1D4ED8), lightBgColor: const Color(0xFFDBEAFE), borderColor: const Color(0xFFBFDBFE), iconBgColor: const Color(0xFFEFF6FF),
          ),
        ],
      );
    } else {
      // Luar Ruangan
      return _buildPremiumSliverView(
        context: context,
        headerTitle: 'PERSIAPAN DASAR',
        title: 'Kesiapan Aman\ndi Luar Ruangan',
        gradientColors: const [Color(0xFFA78BFA), Color(0xFF6D28D9)], // Soft Purple
        cards: [
          _buildStandardStepCard(
            number: '1', action: 'KENALI AREA SEKITAR',
            desc: 'Perhatikan lingkungan sekitar saat beraktivitas di taman atau jalan umum agar Anda familiar dengan lokasi.',
            icon: Icons.nature_people_rounded,
            primaryColor: const Color(0xFF6D28D9), lightBgColor: const Color(0xFFEDE9FE), borderColor: const Color(0xFFDDD6FE), iconBgColor: const Color(0xFFF5F3FF),
          ),
          _buildStandardStepCard(
            number: '2', action: 'SIMPAN KONTAK KELUARGA',
            desc: 'Selalu pastikan Anda memiliki kontak darurat kerabat terdekat di ponsel pintar Anda untuk kebutuhan harian.',
            icon: Icons.contact_page_rounded,
            primaryColor: const Color(0xFF6D28D9), lightBgColor: const Color(0xFFEDE9FE), borderColor: const Color(0xFFDDD6FE), iconBgColor: const Color(0xFFF5F3FF),
          ),
          _buildStandardStepCard(
            number: '3', action: 'NIKMATI AKTIVITAS',
            desc: 'Tingkat risiko gempa sangat rendah. Nikmati kegiatan luar ruangan Anda dengan nyaman tanpa perlu rasa cemas berlebih.',
            icon: Icons.sentiment_satisfied_alt_rounded,
            primaryColor: const Color(0xFF6D28D9), lightBgColor: const Color(0xFFEDE9FE), borderColor: const Color(0xFFDDD6FE), iconBgColor: const Color(0xFFF5F3FF),
          ),
        ],
      );
    }
  }

  // ===========================================================================
  // FASE 1: SAAT GEMPA
  // ===========================================================================
  Widget _buildSaatGempaContent(BuildContext context) {
    if (locationCategory == 'Pesisir Pantai') {
      return _buildPremiumSliverView(
        context: context,
        headerTitle: 'PANDUAN SAAT GUNCANGAN',
        title: 'Saat Ada Guncangan\ndi Pesisir Pantai',
        gradientColors: const [Color(0xFF2DD4BF), Color(0xFF0F766E)],
        cards: [
          _buildStandardStepCard(
            number: '1', action: 'TETAP TENANG',
            desc: 'Guncangan yang terjadi tergolong ringan. Jangan panik berlarian; berhentilah sejenak dari aktivitas Anda.',
            icon: Icons.self_improvement_rounded,
            primaryColor: const Color(0xFF0F766E), lightBgColor: const Color(0xFFCCFBF1), borderColor: const Color(0xFF99F6E4), iconBgColor: const Color(0xFFF0FDFA),
          ),
          _buildStandardStepCard(
            number: '2', action: 'PERHATIKAN SEKITAR',
            desc: 'Lihat kondisi ombak secara wajar. Gempa skala aman jarang memicu gelombang ekstrem, namun tetaplah awas.',
            icon: Icons.visibility_rounded,
            primaryColor: const Color(0xFF0F766E), lightBgColor: const Color(0xFFCCFBF1), borderColor: const Color(0xFF99F6E4), iconBgColor: const Color(0xFFF0FDFA),
          ),
        ],
      );
    } else if (locationCategory == 'Pegunungan') {
      return _buildPremiumSliverView(
        context: context,
        headerTitle: 'PANDUAN SAAT GUNCANGAN',
        title: 'Saat Ada Guncangan\ndi Pegunungan',
        gradientColors: const [Color(0xFF34D399), Color(0xFF047857)],
        cards: [
          _buildStandardStepCard(
            number: '1', action: 'BERHENTI MELANGKAH',
            desc: 'Jika sedang berjalan, berhentilah sejenak. Jaga keseimbangan tubuh agar tidak tergelincir saat ada getaran kecil.',
            icon: Icons.accessibility_new_rounded,
            primaryColor: const Color(0xFF047857), lightBgColor: const Color(0xFFD1FAE5), borderColor: const Color(0xFFA7F3D0), iconBgColor: const Color(0xFFECFDF5),
          ),
          _buildStandardStepCard(
            number: '2', action: 'JAUHI TEPI JURANG',
            desc: 'Meski guncangan ringan, biasakan untuk mundur beberapa langkah dari tepi tebing curam sebagai tindakan antisipasi.',
            icon: Icons.back_hand_rounded,
            primaryColor: const Color(0xFF047857), lightBgColor: const Color(0xFFD1FAE5), borderColor: const Color(0xFFA7F3D0), iconBgColor: const Color(0xFFECFDF5),
          ),
        ],
      );
    } else if (locationCategory == 'Dalam Ruangan') {
      return _buildPremiumSliverView(
        context: context,
        headerTitle: 'PANDUAN SAAT GUNCANGAN',
        title: 'Saat Ada Guncangan\ndi Dalam Ruangan',
        gradientColors: const [Color(0xFF60A5FA), Color(0xFF1D4ED8)],
        cards: [
          _buildStandardStepCard(
            number: '1', action: 'TIDAK PERLU PANIK KELUAR',
            desc: 'Guncangan skala aman tidak merusak bangunan. Tetap di tempat Anda dan tunggu hingga getaran reda.',
            icon: Icons.weekend_rounded,
            primaryColor: const Color(0xFF1D4ED8), lightBgColor: const Color(0xFFDBEAFE), borderColor: const Color(0xFFBFDBFE), iconBgColor: const Color(0xFFEFF6FF),
          ),
          _buildStandardStepCard(
            number: '2', action: 'AMATKAN BARANG DI ATAS',
            desc: 'Cukup waspadai barang kecil yang mungkin bergeser di atas meja atau lemari. Pegang jika dirasa perlu.',
            icon: Icons.touch_app_rounded,
            primaryColor: const Color(0xFF1D4ED8), lightBgColor: const Color(0xFFDBEAFE), borderColor: const Color(0xFFBFDBFE), iconBgColor: const Color(0xFFEFF6FF),
          ),
        ],
      );
    } else {
      // Luar Ruangan
      return _buildPremiumSliverView(
        context: context,
        headerTitle: 'PANDUAN SAAT GUNCANGAN',
        title: 'Saat Ada Guncangan\ndi Luar Ruangan',
        gradientColors: const [Color(0xFFA78BFA), Color(0xFF6D28D9)],
        cards: [
          _buildStandardStepCard(
            number: '1', action: 'TETAP RILEKS',
            desc: 'Getaran skala kecil di luar ruangan mungkin nyaris tidak terasa. Berhentilah jika Anda merasa sedikit limbung.',
            icon: Icons.nature_rounded,
            primaryColor: const Color(0xFF6D28D9), lightBgColor: const Color(0xFFEDE9FE), borderColor: const Color(0xFFDDD6FE), iconBgColor: const Color(0xFFF5F3FF),
          ),
          _buildStandardStepCard(
            number: '2', action: 'HINDARI TIANG LISTRIK',
            desc: 'Hanya sebagai kebiasaan baik, jangan berdiri tepat di bawah tiang listrik gantung meskipun gempa tergolong aman.',
            icon: Icons.power_rounded,
            primaryColor: const Color(0xFF6D28D9), lightBgColor: const Color(0xFFEDE9FE), borderColor: const Color(0xFFDDD6FE), iconBgColor: const Color(0xFFF5F3FF),
          ),
        ],
      );
    }
  }

  // ===========================================================================
  // FASE 2: SETELAH GEMPA (PASCA)
  // ===========================================================================
  Widget _buildEvakuasiContent(BuildContext context) {
    if (locationCategory == 'Pesisir Pantai') {
      return _buildPremiumSliverView(
        context: context,
        headerTitle: 'PASCA GUNCANGAN',
        title: 'Setelah Guncangan\ndi Pesisir Pantai',
        gradientColors: const [Color(0xFF2DD4BF), Color(0xFF0F766E)],
        cards: [
          _buildStandardStepCard(
            number: '1', action: 'LANJUTKAN AKTIVITAS',
            desc: 'Gempa berisiko rendah tidak mengganggu kegiatan. Anda bisa kembali menikmati suasana pantai dengan rileks.',
            icon: Icons.directions_walk_rounded,
            primaryColor: const Color(0xFF0F766E), lightBgColor: const Color(0xFFCCFBF1), borderColor: const Color(0xFF99F6E4), iconBgColor: const Color(0xFFF0FDFA),
          ),
          _buildStandardStepCard(
            number: '2', action: 'CEK NOTIFIKASI BMKG',
            desc: 'Sekadar konfirmasi, Anda bisa mengecek aplikasi BMKG atau Amanin untuk memastikan pusat dan kekuatan gempa.',
            icon: Icons.verified_rounded,
            primaryColor: const Color(0xFF0F766E), lightBgColor: const Color(0xFFCCFBF1), borderColor: const Color(0xFF99F6E4), iconBgColor: const Color(0xFFF0FDFA),
          ),
        ],
      );
    } else if (locationCategory == 'Pegunungan') {
      return _buildPremiumSliverView(
        context: context,
        headerTitle: 'PASCA GUNCANGAN',
        title: 'Setelah Guncangan\ndi Pegunungan',
        gradientColors: const [Color(0xFF34D399), Color(0xFF047857)],
        cards: [
          _buildStandardStepCard(
            number: '1', action: 'PERIKSA JALUR DEPAN',
            desc: 'Lihat sepintas apakah ada kerikil yang jatuh ke jalur pendakian. Lanjutkan perjalanan jika sudah bersih.',
            icon: Icons.check_circle_outline_rounded,
            primaryColor: const Color(0xFF047857), lightBgColor: const Color(0xFFD1FAE5), borderColor: const Color(0xFFA7F3D0), iconBgColor: const Color(0xFFECFDF5),
          ),
          _buildStandardStepCard(
            number: '2', action: 'NIKMATI PERJALANAN',
            desc: 'Karena masuk kategori aman, risiko longsor besar sangat minim. Tetap fokus dan nikmati petualangan Anda.',
            icon: Icons.hiking_rounded,
            primaryColor: const Color(0xFF047857), lightBgColor: const Color(0xFFD1FAE5), borderColor: const Color(0xFFA7F3D0), iconBgColor: const Color(0xFFECFDF5),
          ),
        ],
      );
    } else if (locationCategory == 'Dalam Ruangan') {
      return _buildPremiumSliverView(
        context: context,
        headerTitle: 'PASCA GUNCANGAN',
        title: 'Setelah Guncangan\ndi Dalam Ruangan',
        gradientColors: const [Color(0xFF60A5FA), Color(0xFF1D4ED8)],
        cards: [
          _buildStandardStepCard(
            number: '1', action: 'KEMBALI BERAKTIVITAS',
            desc: 'Kondisi telah kembali normal sepenuhnya. Anda bisa melanjutkan aktivitas bekerja atau bersantai.',
            icon: Icons.coffee_rounded,
            primaryColor: const Color(0xFF1D4ED8), lightBgColor: const Color(0xFFDBEAFE), borderColor: const Color(0xFFBFDBFE), iconBgColor: const Color(0xFFEFF6FF),
          ),
          _buildStandardStepCard(
            number: '2', action: 'RAPILKAN BARANG',
            desc: 'Jika ada barang kecil atau bingkai foto yang miring karena getaran, cukup luruskan kembali posisinya.',
            icon: Icons.view_comfy_rounded,
            primaryColor: const Color(0xFF1D4ED8), lightBgColor: const Color(0xFFDBEAFE), borderColor: const Color(0xFFBFDBFE), iconBgColor: const Color(0xFFEFF6FF),
          ),
        ],
      );
    } else {
      // Luar Ruangan
      return _buildPremiumSliverView(
        context: context,
        headerTitle: 'PASCA GUNCANGAN',
        title: 'Setelah Guncangan\ndi Luar Ruangan',
        gradientColors: const [Color(0xFFA78BFA), Color(0xFF6D28D9)],
        cards: [
          _buildStandardStepCard(
            number: '1', action: 'TETAP NYAMAN',
            desc: 'Tidak ada kerusakan atau bahaya yang mengancam. Silakan beraktivitas secara normal kembali.',
            icon: Icons.thumb_up_alt_rounded,
            primaryColor: const Color(0xFF6D28D9), lightBgColor: const Color(0xFFEDE9FE), borderColor: const Color(0xFFDDD6FE), iconBgColor: const Color(0xFFF5F3FF),
          ),
          _buildStandardStepCard(
            number: '2', action: 'HUBUNGI TEMAN',
            desc: 'Sapa kerabat jika mereka membicarakan getaran tersebut, sampaikan bahwa kondisi di tempat Anda aman terkendali.',
            icon: Icons.chat_bubble_outline_rounded,
            primaryColor: const Color(0xFF6D28D9), lightBgColor: const Color(0xFFEDE9FE), borderColor: const Color(0xFFDDD6FE), iconBgColor: const Color(0xFFF5F3FF),
          ),
        ],
      );
    }
  }

  // ===========================================================================
  // WIDGET HELPERS
  // ===========================================================================

  Widget _buildStandardStepCard({
    required String number,
    required String action,
    required String desc,
    required IconData icon,
    Color primaryColor = const Color(0xFF10B981),
    Color lightBgColor = const Color(0xFFD1FAE5),
    Color borderColor = const Color(0xFFA7F3D0),
    Color iconBgColor = const Color(0xFFECFDF5),
  }) {
    // Force override with Edukasi Aman's Green Theme
    primaryColor = const Color(0xFF16A34A); // Green 600
    borderColor = const Color(0xFF86EFAC); // Green 300
    iconBgColor = const Color(0xFFF0FDF4); // Green 50

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // ── Watermark icon (large, faint) ──
            Positioned(
              right: -15,
              bottom: -15,
              child: Opacity(
                opacity: 0.12,
                child: Icon(icon, size: 95, color: primaryColor),
              ),
            ),

            // ── Left accent bar ──
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 5,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
            ),

            // ── Main Content ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row: icon box + title + badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon in rounded container
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                            color: primaryColor.withValues(alpha: 0.30),
                            width: 1,
                          ),
                        ),
                        child: Icon(icon, size: 18, color: primaryColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              action,
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.3,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 5),
                            // "Langkah Aman" badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle_rounded,
                                      size: 10,
                                      color: primaryColor),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Langkah Aman',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: primaryColor,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Divider
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor.withValues(alpha: 0.50),
                          primaryColor.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Description text
                  Text(
                    desc,
                    style: const TextStyle(
                      color: Color(0xFF374151),
                      fontSize: 12.5,
                      height: 1.60,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumSliverView({
    required BuildContext context,
    required String headerTitle,
    required String title,
    required List<Color> gradientColors,
    required List<Widget> cards,
  }) {
    // Force override to use Edukasi Aman's Green Theme
    final Color mainThemeColor = const Color(0xFF16A34A); // Green 600
    return Container(
      color: const Color(0xFFF8FAFC), // Slate-50 background
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 180.0,
            backgroundColor: mainThemeColor, // Dynamic Green
            elevation: 0,
            pinned: true,
            automaticallyImplyLeading: false,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.20),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            title: Column(
              children: [
                Text(
                  headerTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Zona Aman: $cityName',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.70),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: mainThemeColor, // Flat solid Green
                    ),
                  ),
                  // Diagonal strip decor
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _SliverDiagonalPainter(
                        color: Colors.white.withValues(alpha: 0.035),
                      ),
                    ),
                  ),
                  // Radial glow
                  Positioned(
                    bottom: -50,
                    right: -25,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.15),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Bottom text content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.40),
                              width: 1.0,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_user_rounded, color: Colors.white, size: 12),
                              SizedBox(width: 6),
                              Text(
                                'Panduan Keselamatan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 9,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC), // Light background
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 48, 20, 40),
                child: Column(
                  children: cards.asMap().entries.map((entry) {
                    final int idx = entry.key;
                    final Widget card = entry.value;
                    final bool isLast = idx == cards.length - 1;
                    final String stepNum = (idx + 1).toString();

                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── Timeline Path Column ──
                          SizedBox(
                            width: 32,
                            child: Column(
                              children: [
                                // Node: Glowing Number Circle
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: mainThemeColor, // Green circle
                                    boxShadow: [
                                      BoxShadow(
                                        color: mainThemeColor.withValues(alpha: 0.35),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                   child: Center(
                                    child: Text(
                                      stepNum,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
                                        height: 1.0,
                                      ),
                                    ),
                                  ),
                                ),
                                // Tail: Vertical connector line
                                Expanded(
                                  child: Container(
                                    width: 2.5,
                                    color: isLast 
                                      ? Colors.transparent 
                                      : mainThemeColor.withValues(alpha: 0.40),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),

                          // ── Detail Card Column ──
                          Expanded(
                            child: card,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverDiagonalPainter extends CustomPainter {
  final Color color;
  const _SliverDiagonalPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    const spacing = 24.0;
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SliverDiagonalPainter old) => old.color != color;
}
