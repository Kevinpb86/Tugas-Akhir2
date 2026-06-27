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
    required Color primaryColor,
    required Color lightBgColor,
    required Color borderColor,
    required Color iconBgColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Center(
                child: Icon(icon, color: primaryColor, size: 24),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'LANGKAH $number',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          action,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            color: primaryColor,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Color(0xFF475569), // Slate-600
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
    return Container(
      color: const Color(0xFFF8FAFC), // Slate-50 (Lighter background for safe status)
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 280.0,
            backgroundColor: gradientColors.last,
            elevation: 0,
            pinned: true,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Column(
              children: [
                Text(
                  headerTitle,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.0),
                ),
                const SizedBox(height: 2),
                Text(
                  'Kondisi Lingkungan: Aman',
                  style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Positioned(
                    top: -60,
                    right: -40,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    left: -50,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -20,
                    top: -10,
                    child: Icon(Icons.shield_outlined, size: 240, color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  Positioned(
                    top: 50,
                    left: 60,
                    child: Icon(Icons.circle, size: 8, color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  Positioned(
                    top: 100,
                    right: 180,
                    child: Icon(Icons.star_rounded, size: 20, color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  Positioned(
                    bottom: 120,
                    right: 60,
                    child: Icon(Icons.circle, size: 12, color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.verified_user_rounded, color: Colors.white, size: 16),
                              SizedBox(width: 8),
                              Text(
                                'Kondisi Aman Terkendali',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Panduan bersikap tenang dan rutinitas kesiapan standar untuk menjaga kenyamanan Anda.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                            height: 1.5,
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
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Icon(Icons.tips_and_updates_rounded, color: gradientColors.last, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Tindakan yang Disarankan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: gradientColors.last,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...cards,
                      const SizedBox(height: 80), // Padding untuk FloatingActionButton
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
