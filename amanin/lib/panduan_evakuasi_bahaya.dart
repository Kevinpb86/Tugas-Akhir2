import 'package:flutter/material.dart';

class PanduanEvakuasiBahayaPage extends StatelessWidget {
  final String cityName;
  final int initialTabIndex; // Represents the phase: 0=Sebelum, 1=Saat, 2=Setelah
  final String locationCategory; // 'Dalam Ruangan' | 'Luar Ruangan' | 'Pesisir Pantai'

  const PanduanEvakuasiBahayaPage({
    super.key,
    required this.cityName,
    this.initialTabIndex = 0,
    this.locationCategory = 'Dalam Ruangan',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // Dark background for urgency
      appBar: null, // Sembunyikan AppBar standar karena semua halaman sudah menggunakan SliverAppBar
      body: _buildContent(context, initialTabIndex),
      floatingActionButton: initialTabIndex == 2 
        ? FloatingActionButton.extended(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mensimulasikan panggilan darurat ke 112...')),
              );
            },
            backgroundColor: const Color(0xFFFFD600), // High vis yellow
            icon: const Icon(Icons.phone_in_talk_rounded, color: Colors.black, size: 22),
            label: const Text(
              'PANGGIL DARURAT 112',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
            elevation: 6,
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



  Widget _buildSiagaContent(BuildContext context) {
    if (locationCategory == 'Pesisir Pantai') {
      return _buildPremiumSliverView(
        context: context,
        headerTitle: 'PANDUAN SIAGA BENCANA',
        title: 'Siaga Gempa\ndi Pesisir Pantai',
        gradientColors: const [Color(0xFF2DD4BF), Color(0xFF0D9488)], // Ocean Teal
        cards: [
          _buildStandardStepCard(
            number: '1', action: 'KENALI JALUR EVAKUASI',
            desc: 'Pengguna perlu mengetahui jalur evakuasi terdekat dari area pantai menuju tempat yang lebih tinggi atau lokasi evakuasi resmi.',
            icon: Icons.directions_run_rounded,
            primaryColor: const Color(0xFF0D9488), lightBgColor: const Color(0xFFCCFBF1), borderColor: const Color(0xFF99F6E4), iconBgColor: const Color(0xFFF0FDFA),
          ),
          _buildStandardStepCard(
            number: '2', action: 'KETAHUI TITIK KUMPUL',
            desc: 'Pengguna perlu mengenali titik kumpul yang berada jauh dari garis pantai, muara sungai, atau area rendah.',
            icon: Icons.location_on_rounded,
            primaryColor: const Color(0xFF0D9488), lightBgColor: const Color(0xFFCCFBF1), borderColor: const Color(0xFF99F6E4), iconBgColor: const Color(0xFFF0FDFA),
          ),
          _buildStandardStepCard(
            number: '3', action: 'PAHAMI TANDA TSUNAMI',
            desc: 'Guncangan gempa kuat, gempa berdurasi lama, atau air laut yang tiba-tiba surut adalah tanda bahaya tsunami alami.',
            icon: Icons.waves_rounded,
            primaryColor: const Color(0xFF0D9488), lightBgColor: const Color(0xFFCCFBF1), borderColor: const Color(0xFF99F6E4), iconBgColor: const Color(0xFFF0FDFA),
          ),
          _buildStandardStepCard(
            number: '4', action: 'SIMPAN NOMOR DARURAT',
            desc: 'Pengguna disarankan menyimpan akses informasi resmi BMKG/BPBD, nomor keluarga, layanan darurat, dan petugas setempat.',
            icon: Icons.contact_phone_rounded,
            primaryColor: const Color(0xFF0D9488), lightBgColor: const Color(0xFFCCFBF1), borderColor: const Color(0xFF99F6E4), iconBgColor: const Color(0xFFF0FDFA),
          ),
          _buildStandardStepCard(
            number: '5', action: 'SIAPKAN TAS SIAGA',
            desc: 'Siapkan tas berisi air minum, makanan ringan, obat pribadi, senter, peluit, dan dokumen penting yang mudah dibawa.',
            icon: Icons.work_rounded,
            primaryColor: const Color(0xFF0D9488), lightBgColor: const Color(0xFFCCFBF1), borderColor: const Color(0xFF99F6E4), iconBgColor: const Color(0xFFF0FDFA),
          ),
        ],
      );
    } else if (locationCategory == 'Pegunungan') {
      return _buildPremiumSliverView(
        context: context,
        headerTitle: 'PANDUAN SIAGA BENCANA',
        title: 'Siaga Gempa\ndi Pegunungan',
        gradientColors: const [Color(0xFF38BDF8), Color(0xFF0284C7)], // Cool blue gradient
        cards: [
          _buildStandardStepCard(
            number: '1', action: 'KENALI POTENSI LONGSOR',
            desc: 'Pahami bahwa wilayah lereng dan pegunungan sangat rawan longsor saat terjadi gempa bumi. Kenali tanda-tanda awal seperti tanah retak atau pohon yang mendadak miring.',
            icon: Icons.landscape_rounded,
            primaryColor: const Color(0xFF0284C7), lightBgColor: const Color(0xFFE0F2FE), borderColor: const Color(0xFFBAE6FD), iconBgColor: const Color(0xFFF0F9FF),
          ),
          _buildStandardStepCard(
            number: '2', action: 'KETAHUI JALUR EVAKUASI',
            desc: 'Tentukan rute evakuasi yang menjauhi tebing, lereng curam, atau aliran sungai yang berpotensi membawa material longsor dan bebatuan jatuh.',
            icon: Icons.directions_run_rounded,
            primaryColor: const Color(0xFF0284C7), lightBgColor: const Color(0xFFE0F2FE), borderColor: const Color(0xFFBAE6FD), iconBgColor: const Color(0xFFF0F9FF),
          ),
          _buildStandardStepCard(
            number: '3', action: 'HINDARI BANGUNAN RAWAN',
            desc: 'Jika memungkinkan, pastikan rumah atau tempat beraktivitas tidak berada tepat di bawah lereng curam, di bibir jurang, atau di jalur aliran air dari gunung.',
            icon: Icons.home_work_rounded,
            primaryColor: const Color(0xFF0284C7), lightBgColor: const Color(0xFFE0F2FE), borderColor: const Color(0xFFBAE6FD), iconBgColor: const Color(0xFFF0F9FF),
          ),
          _buildStandardStepCard(
            number: '4', action: 'PERHATIKAN CUACA HUJAN',
            desc: 'Gempa yang terjadi saat atau setelah hujan lebat memiliki potensi berlipat ganda untuk memicu tanah longsor. Selalu tingkatkan kewaspadaan ekstra di musim hujan.',
            icon: Icons.cloud_rounded,
            primaryColor: const Color(0xFF0284C7), lightBgColor: const Color(0xFFE0F2FE), borderColor: const Color(0xFFBAE6FD), iconBgColor: const Color(0xFFF0F9FF),
          ),
          _buildStandardStepCard(
            number: '5', action: 'SIAPKAN TAS SIAGA',
            desc: 'Bawa kebutuhan dasar seperti P3K, senter, peluit, air minum, dan pakaian tebal. Suhu pegunungan yang dingin memerlukan kesiapan ekstra jika harus mengungsi di luar.',
            icon: Icons.work_rounded,
            primaryColor: const Color(0xFF0284C7), lightBgColor: const Color(0xFFE0F2FE), borderColor: const Color(0xFFBAE6FD), iconBgColor: const Color(0xFFF0F9FF),
          ),
        ],
      );
    } else if (locationCategory == 'Dalam Ruangan') {
      return _buildPremiumSliverView(
        context: context,
        headerTitle: 'PANDUAN SIAGA BENCANA',
        title: 'Siaga Gempa\ndi Dalam Ruangan',
        gradientColors: const [Color(0xFFC084FC), Color(0xFF9333EA)], // Amethyst Violet
        cards: [
          _buildStandardStepCard(
            number: '1', action: 'KENALI JALUR KELUAR',
            desc: 'Pengguna perlu mengetahui letak pintu keluar, tangga darurat, dan area yang dapat digunakan untuk berlindung.',
            icon: Icons.exit_to_app_rounded,
            primaryColor: const Color(0xFF9333EA), lightBgColor: const Color(0xFFF3E8FF), borderColor: const Color(0xFFE9D5FF), iconBgColor: const Color(0xFFFAF5FF),
          ),
          _buildStandardStepCard(
            number: '2', action: 'PASTIKAN PERABOT AMAN',
            desc: 'Lemari, rak, kabinet, atau benda berat lainnya sebaiknya diletakkan menempel pada dinding agar tidak mudah roboh.',
            icon: Icons.kitchen_rounded,
            primaryColor: const Color(0xFF9333EA), lightBgColor: const Color(0xFFF3E8FF), borderColor: const Color(0xFFE9D5FF), iconBgColor: const Color(0xFFFAF5FF),
          ),
          _buildStandardStepCard(
            number: '3', action: 'JAUHKAN BENDA MUDAH PECAH',
            desc: 'Benda seperti kaca, vas, pajangan, atau barang yang mudah jatuh sebaiknya tidak diletakkan di pinggir meja atau rak tinggi.',
            icon: Icons.broken_image_rounded,
            primaryColor: const Color(0xFF9333EA), lightBgColor: const Color(0xFFF3E8FF), borderColor: const Color(0xFFE9D5FF), iconBgColor: const Color(0xFFFAF5FF),
          ),
          _buildStandardStepCard(
            number: '4', action: 'KETAHUI BENDA PELINDUNG',
            desc: 'Kenali benda yang dapat digunakan untuk melindungi tubuh, seperti meja kuat, kursi kokoh, tas, atau bantal.',
            icon: Icons.desk_rounded,
            primaryColor: const Color(0xFF9333EA), lightBgColor: const Color(0xFFF3E8FF), borderColor: const Color(0xFFE9D5FF), iconBgColor: const Color(0xFFFAF5FF),
          ),
          _buildStandardStepCard(
            number: '5', action: 'SIMPAN INFORMASI RESMI',
            desc: 'Simpan nomor penting keluarga, BPBD, rumah sakit, dan biasakan mengikuti informasi resmi dari BMKG.',
            icon: Icons.contact_phone_rounded,
            primaryColor: const Color(0xFF9333EA), lightBgColor: const Color(0xFFF3E8FF), borderColor: const Color(0xFFE9D5FF), iconBgColor: const Color(0xFFFAF5FF),
          ),
        ],
      );
    } else {
      // Luar Ruangan
      return _buildPremiumSliverView(
        context: context,
        headerTitle: 'PANDUAN SIAGA BENCANA',
        title: 'Siaga Gempa\ndi Luar Ruangan',
        gradientColors: const [Color(0xFFD6D3D1), Color(0xFF78716C)], // Sand/Brown
        cards: [
          _buildStandardStepCard(
            number: '1', action: 'MENGETAHUI TITIK KUMPUL',
            desc: 'Ketahui lokasi titik kumpul aman di sekitar tempat tinggal, sekolah, kampus, kantor, atau area umum.',
            icon: Icons.location_on_rounded,
            primaryColor: const Color(0xFF78716C), lightBgColor: const Color(0xFFF5F5F4), borderColor: const Color(0xFFE7E5E4), iconBgColor: const Color(0xFFFAFAF9),
          ),
          _buildStandardStepCard(
            number: '2', action: 'MENYIMPAN NOMOR DARURAT',
            desc: 'Simpan nomor penting keluarga, BPBD, layanan rumah sakit, agar segera mendapat bantuan saat kondisi darurat.',
            icon: Icons.contact_phone_rounded,
            primaryColor: const Color(0xFF78716C), lightBgColor: const Color(0xFFF5F5F4), borderColor: const Color(0xFFE7E5E4), iconBgColor: const Color(0xFFFAFAF9),
          ),
          _buildStandardStepCard(
            number: '3', action: 'MEMAHAMI INFORMASI BMKG',
            desc: 'Pahami informasi resmi dari BMKG mengenai potensi gempa lanjutan untuk mengambil keputusan secara tepat.',
            icon: Icons.public_rounded,
            primaryColor: const Color(0xFF78716C), lightBgColor: const Color(0xFFF5F5F4), borderColor: const Color(0xFFE7E5E4), iconBgColor: const Color(0xFFFAFAF9),
          ),
          _buildStandardStepCard(
            number: '4', action: 'MENYIAPKAN TAS SIAGA',
            desc: 'Siapkan tas siaga yang berisi kebutuhan penting, seperti air minum, makanan, obat, senter, peluit, dan uang tunai.',
            icon: Icons.work_rounded,
            primaryColor: const Color(0xFF78716C), lightBgColor: const Color(0xFFF5F5F4), borderColor: const Color(0xFFE7E5E4), iconBgColor: const Color(0xFFFAFAF9),
          ),
          _buildStandardStepCard(
            number: '5', action: 'MENGENALI JALUR EVAKUASI',
            desc: 'Mengenali jalur evakuasi di sekitar area umum akan membantu Anda keluar dari area bahaya lebih cepat.',
            icon: Icons.directions_run_rounded,
            primaryColor: const Color(0xFF78716C), lightBgColor: const Color(0xFFF5F5F4), borderColor: const Color(0xFFE7E5E4), iconBgColor: const Color(0xFFFAFAF9),
          ),
        ],
      );
    }
  }





  Widget _buildSaatGempaContent(BuildContext context) {
    if (locationCategory == 'Pesisir Pantai') {
      return _buildPremiumSliverView(
        context: context,
        headerTitle: 'PANDUAN SAAT GEMPA',
        title: 'Saat Gempa\ndi Pesisir Pantai',
        gradientColors: const [Color(0xFFF87171), Color(0xFFDC2626)], // Danger Red
        cards: [
          _buildStandardStepCard(
            number: '1', action: 'TETAP TENANG & LINDUNGI DIRI',
            desc: 'Saat guncangan terjadi, berusaha tetap tenang dan melindungi kepala dari benda jatuh. Jauhi bangunan, tiang listrik, dan pohon besar.',
            icon: Icons.shield_rounded,
            primaryColor: const Color(0xFFDC2626), lightBgColor: const Color(0xFFFEF2F2), borderColor: const Color(0xFFFECACA), iconBgColor: const Color(0xFFFEF2F2),
          ),
          _buildStandardStepCard(
            number: '2', action: 'JANGAN MENDEKATI PANTAI',
            desc: 'Tidak disarankan mendekati pantai untuk melihat kondisi laut setelah gempa. Gempa kuat dapat menimbulkan bahaya lanjutan.',
            icon: Icons.do_not_step_rounded,
            primaryColor: const Color(0xFFDC2626), lightBgColor: const Color(0xFFFEF2F2), borderColor: const Color(0xFFFECACA), iconBgColor: const Color(0xFFFEF2F2),
          ),
          _buildStandardStepCard(
            number: '3', action: 'SEGERA KE TEMPAT TINGGI',
            desc: 'Jika guncangan terasa kuat atau berlangsung lama, segera menjauh dari pantai menuju tempat yang lebih tinggi.',
            icon: Icons.landscape_rounded,
            primaryColor: const Color(0xFFDC2626), lightBgColor: const Color(0xFFFEF2F2), borderColor: const Color(0xFFFECACA), iconBgColor: const Color(0xFFFEF2F2),
          ),
          _buildStandardStepCard(
            number: '4', action: 'GUNAKAN JALUR AMAN',
            desc: 'Ikuti jalur evakuasi yang tersedia dan hindari jalan sempit, jembatan rusak, atau area berpotensi runtuh.',
            icon: Icons.directions_run_rounded,
            primaryColor: const Color(0xFFDC2626), lightBgColor: const Color(0xFFFEF2F2), borderColor: const Color(0xFFFECACA), iconBgColor: const Color(0xFFFEF2F2),
          ),
          _buildStandardStepCard(
            number: '5', action: 'HINDARI KENDARAAN',
            desc: 'Jika lokasi evakuasi dapat dicapai dengan jalan kaki, hindari kendaraan agar tidak menimbulkan kemacetan.',
            icon: Icons.directions_car_rounded,
            primaryColor: const Color(0xFFDC2626), lightBgColor: const Color(0xFFFEF2F2), borderColor: const Color(0xFFFECACA), iconBgColor: const Color(0xFFFEF2F2),
          ),
        ],
      );
    } else if (locationCategory == 'Pegunungan') {
      return _buildPremiumSliverView(
        context: context,
        headerTitle: 'PANDUAN SAAT GEMPA',
        title: 'Saat Gempa\ndi Pegunungan',
        gradientColors: const [Color(0xFFFFB74D), Color(0xFFF57C00)], // Warm orange gradient
        cards: [
          _buildStandardStepCard(
            number: '1', action: 'JAUHI TEBING & LERENG',
            desc: 'Segera berlari menjauh dari bawah tebing, bukit, atau lereng yang berpotensi longsor. Cari area datar yang lapang dan aman dari jatuhan batu.',
            icon: Icons.warning_rounded,
          ),
          _buildStandardStepCard(
            number: '2', action: 'AWASI MATERIAL JATUH',
            desc: 'Waspada terhadap batu atau material tanah yang mulai berguguran. Lindungi kepala dengan tas, helm, atau tangan saat bergerak mencari tempat aman.',
            icon: Icons.shield_rounded,
          ),
          _buildStandardStepCard(
            number: '3', action: 'JAUHI ALIRAN SUNGAI',
            desc: 'Gempa dapat memicu banjir bandang atau aliran material longsor (debris flow) melalui jalur sungai pegunungan. Jangan berlindung di dekat atau melintasi sungai.',
            icon: Icons.waves_rounded,
          ),
          _buildStandardStepCard(
            number: '4', action: 'HINDARI POHON BESAR',
            desc: 'Pohon di lereng gunung bisa tumbang akibat guncangan tanah yang tidak stabil. Carilah area terbuka yang bersih dari pohon besar.',
            icon: Icons.park_rounded,
          ),
          _buildStandardStepCard(
            number: '5', action: 'WASPADA SAAT BERGERAK',
            desc: 'Bergerak hati-hati menghindari rekahan tanah yang mungkin muncul tiba-tiba akibat pergerakan patahan atau awal terjadinya longsor.',
            icon: Icons.directions_walk_rounded,
          ),
        ],
      );
    } else if (locationCategory == 'Dalam Ruangan') {
      return _buildPremiumSliverView(
        context: context,
        headerTitle: 'PANDUAN SAAT GEMPA',
        title: 'Saat Gempa\ndi Dalam Ruangan',
        gradientColors: const [Color(0xFFFBBF24), Color(0xFFD97706)], // Amber/Yellow
        cards: [
          _buildStandardStepCard(
            number: '1', action: 'TETAP TENANG',
            desc: 'Berusaha tetap tenang agar dapat menentukan langkah aman. Panik dapat membuat Anda berlari tanpa arah dan cedera.',
            icon: Icons.self_improvement_rounded,
            primaryColor: const Color(0xFFD97706), lightBgColor: const Color(0xFFFFFBEB), borderColor: const Color(0xFFFDE68A), iconBgColor: const Color(0xFFFFFBEB),
          ),
          _buildStandardStepCard(
            number: '2', action: 'BERLINDUNG DI BAWAH MEJA',
            desc: 'Segera berlindung di bawah meja kokoh untuk melindungi tubuh dari benda jatuh seperti lampu, plafon, atau kaca.',
            icon: Icons.desk_rounded,
            primaryColor: const Color(0xFFD97706), lightBgColor: const Color(0xFFFFFBEB), borderColor: const Color(0xFFFDE68A), iconBgColor: const Color(0xFFFFFBEB),
          ),
          _buildStandardStepCard(
            number: '3', action: 'LINDUNGI KEPALA',
            desc: 'Gunakan tangan, tas, bantal, atau jaket untuk melindungi bagian kepala dan leher karena paling rentan.',
            icon: Icons.shield_rounded,
            primaryColor: const Color(0xFFD97706), lightBgColor: const Color(0xFFFFFBEB), borderColor: const Color(0xFFFDE68A), iconBgColor: const Color(0xFFFFFBEB),
          ),
          _buildStandardStepCard(
            number: '4', action: 'JAUHI KACA & BENDA GANTUNG',
            desc: 'Menjauh dari jendela kaca, etalase, lemari, rak tinggi, lampu gantung, atau benda lain yang mudah jatuh.',
            icon: Icons.grid_view_rounded,
            primaryColor: const Color(0xFFD97706), lightBgColor: const Color(0xFFFFFBEB), borderColor: const Color(0xFFFDE68A), iconBgColor: const Color(0xFFFFFBEB),
          ),
          _buildStandardStepCard(
            number: '5', action: 'JANGAN GUNAKAN LIFT',
            desc: 'Jika berada di gedung bertingkat, dilarang menggunakan lift karena dapat berhenti mendadak.',
            icon: Icons.elevator_rounded,
            primaryColor: const Color(0xFFD97706), lightBgColor: const Color(0xFFFFFBEB), borderColor: const Color(0xFFFDE68A), iconBgColor: const Color(0xFFFFFBEB),
          ),
          _buildStandardStepCard(
            number: '6', action: 'JANGAN LARI KELUAR',
            desc: 'Jangan langsung berlari keluar saat guncangan kuat karena berisiko terkena material bangunan jatuh.',
            icon: Icons.front_hand_rounded,
            primaryColor: const Color(0xFFD97706), lightBgColor: const Color(0xFFFFFBEB), borderColor: const Color(0xFFFDE68A), iconBgColor: const Color(0xFFFFFBEB),
          ),
        ],
      );
    } else {
      // Luar Ruangan
      return _buildPremiumSliverView(
        context: context,
        headerTitle: 'PANDUAN SAAT GEMPA',
        title: 'Saat Gempa\ndi Luar Ruangan',
        gradientColors: const [Color(0xFFFB7185), Color(0xFFE11D48)], // Rose/Pink
        cards: [
          _buildStandardStepCard(
            number: '1', action: 'PILIH TITIK AMAN',
            desc: 'Bergeraklah ke area yang tidak berada di dekat bangunan, tembok tinggi, papan reklame, jembatan, atau struktur runtuh.',
            icon: Icons.landscape_rounded,
            primaryColor: const Color(0xFFE11D48), lightBgColor: const Color(0xFFFFF1F2), borderColor: const Color(0xFFFECDD3), iconBgColor: const Color(0xFFFFF1F2),
          ),
          _buildStandardStepCard(
            number: '2', action: 'AMATI SUMBER BAHAYA',
            desc: 'Perhatikan benda tinggi seperti tiang listrik, pohon besar, dan kabel menggantung. Jaga jarak dari benda tersebut.',
            icon: Icons.visibility_rounded,
            primaryColor: const Color(0xFFE11D48), lightBgColor: const Color(0xFFFFF1F2), borderColor: const Color(0xFFFECDD3), iconBgColor: const Color(0xFFFFF1F2),
          ),
          _buildStandardStepCard(
            number: '3', action: 'HINDARI SISI BANGUNAN',
            desc: 'Jangan berdiri di dekat dinding gedung, kaca, etalase, atau bangunan yang terlihat retak karena dapat roboh.',
            icon: Icons.domain_disabled_rounded,
            primaryColor: const Color(0xFFE11D48), lightBgColor: const Color(0xFFFFF1F2), borderColor: const Color(0xFFFECDD3), iconBgColor: const Color(0xFFFFF1F2),
          ),
          _buildStandardStepCard(
            number: '4', action: 'LINDUNGI KEPALA DAN LEHER',
            desc: 'Gunakan tas, jaket, tangan, atau benda lain yang tersedia untuk mengurangi risiko terkena pecahan kaca.',
            icon: Icons.shield_rounded,
            primaryColor: const Color(0xFFE11D48), lightBgColor: const Color(0xFFFFF1F2), borderColor: const Color(0xFFFECDD3), iconBgColor: const Color(0xFFFFF1F2),
          ),
        ],
      );
    }
  }





  Widget _buildEvakuasiContent(BuildContext context) {
    if (locationCategory == 'Pesisir Pantai') {
      return _buildPremiumSliverView(
        context: context,
        headerTitle: 'PANDUAN PASCA GEMPA',
        title: 'Pasca Gempa\ndi Pesisir Pantai',
        gradientColors: const [Color(0xFF818CF8), Color(0xFF4F46E5)], // Deep Indigo
        cards: [
          _buildStandardStepCard(
            number: '1', action: 'TETAP DI TEMPAT TINGGI',
            desc: 'Jangan segera kembali ke pantai atau area rendah meskipun guncangan telah berhenti, hingga ada pengumuman resmi.',
            icon: Icons.landscape_rounded,
            primaryColor: const Color(0xFF4F46E5), lightBgColor: const Color(0xFFEEF2FF), borderColor: const Color(0xFFE0E7FF), iconBgColor: const Color(0xFFEEF2FF),
          ),
          _buildStandardStepCard(
            number: '2', action: 'DENGARKAN INFO RESMI',
            desc: 'Dengarkan informasi dari radio, pengeras suara peringatan dini, atau petugas terkait peringatan tsunami.',
            icon: Icons.campaign_rounded,
            primaryColor: const Color(0xFF4F46E5), lightBgColor: const Color(0xFFEEF2FF), borderColor: const Color(0xFFE0E7FF), iconBgColor: const Color(0xFFEEF2FF),
          ),
          _buildStandardStepCard(
            number: '3', action: 'HINDARI BANGUNAN RUSAK',
            desc: 'Jauhi bangunan yang terlihat retak atau rusak parah karena berpotensi runtuh saat terjadi gempa susulan.',
            icon: Icons.domain_disabled_rounded,
            primaryColor: const Color(0xFF4F46E5), lightBgColor: const Color(0xFFEEF2FF), borderColor: const Color(0xFFE0E7FF), iconBgColor: const Color(0xFFEEF2FF),
          ),
          _buildStandardStepCard(
            number: '4', action: 'PERHATIKAN LINGKUNGAN',
            desc: 'Waspadai jalan retak, tiang listrik miring, atau kabel putus saat bergerak di sekitar area pengungsian.',
            icon: Icons.visibility_rounded,
            primaryColor: const Color(0xFF4F46E5), lightBgColor: const Color(0xFFEEF2FF), borderColor: const Color(0xFFE0E7FF), iconBgColor: const Color(0xFFEEF2FF),
          ),
          _buildStandardStepCard(
            number: '5', action: 'JANGAN PERCAYA HOAX',
            desc: 'Hindari menyebarkan atau mempercayai informasi yang tidak berasal dari BMKG/BNPB untuk mencegah kepanikan.',
            icon: Icons.gpp_bad_rounded,
            primaryColor: const Color(0xFF4F46E5), lightBgColor: const Color(0xFFEEF2FF), borderColor: const Color(0xFFE0E7FF), iconBgColor: const Color(0xFFEEF2FF),
          ),
        ],
      );
    } else if (locationCategory == 'Pegunungan') {
      return _buildPremiumSliverView(
        context: context,
        headerTitle: 'PANDUAN PASCA GEMPA',
        title: 'Pasca Gempa\ndi Pegunungan',
        gradientColors: const [Color(0xFF4ADE80), Color(0xFF16A34A)], // Emerald Green gradient
        cards: [
          _buildStandardStepCard(
            number: '1', action: 'WASPADAI LONGSOR SUSULAN',
            desc: 'Jangan segera kembali ke area lereng atau tebing setelah gempa mereda. Longsor masih bisa terjadi sewaktu-waktu akibat pergerakan tanah atau gempa susulan.',
            icon: Icons.sensors_rounded,
            primaryColor: const Color(0xFF16A34A), lightBgColor: const Color(0xFFDCFCE7), borderColor: const Color(0xFF86EFAC), iconBgColor: const Color(0xFFF0FDF4),
          ),
          _buildStandardStepCard(
            number: '2', action: 'JANGAN MELEWATI JALUR RETAK',
            desc: 'Hindari jalan aspal atau jembatan yang menunjukkan retakan karena struktur tanah di bawahnya bisa runtuh mendadak jika dilewati.',
            icon: Icons.do_not_step_rounded,
            primaryColor: const Color(0xFF16A34A), lightBgColor: const Color(0xFFDCFCE7), borderColor: const Color(0xFF86EFAC), iconBgColor: const Color(0xFFF0FDF4),
          ),
          _buildStandardStepCard(
            number: '3', action: 'CARI INFORMASI RESMI',
            desc: 'Tunggu instruksi dari aparat desa setempat atau BPBD mengenai status keamanan wilayah pegunungan sebelum melakukan aktivitas kembali.',
            icon: Icons.radio_rounded,
            primaryColor: const Color(0xFF16A34A), lightBgColor: const Color(0xFFDCFCE7), borderColor: const Color(0xFF86EFAC), iconBgColor: const Color(0xFFF0FDF4),
          ),
          _buildStandardStepCard(
            number: '4', action: 'JAUHI HUTAN ATAU JURANG',
            desc: 'Jangan mencoba mencari jalan pintas melalui jurang atau hutan lebat karena kondisi pijakan tanah mungkin sangat rapuh dan tidak stabil pasca gempa.',
            icon: Icons.not_listed_location_rounded,
            primaryColor: const Color(0xFF16A34A), lightBgColor: const Color(0xFFDCFCE7), borderColor: const Color(0xFF86EFAC), iconBgColor: const Color(0xFFF0FDF4),
          ),
          _buildStandardStepCard(
            number: '5', action: 'LAPORKAN RETAKAN BARU',
            desc: 'Jika Anda melihat adanya retakan tanah yang panjang atau dalam di dekat area pemukiman pegunungan, segera laporkan ke aparat berwenang.',
            icon: Icons.add_alert_rounded,
            primaryColor: const Color(0xFF16A34A), lightBgColor: const Color(0xFFDCFCE7), borderColor: const Color(0xFF86EFAC), iconBgColor: const Color(0xFFF0FDF4),
          ),
        ],
      );
    } else if (locationCategory == 'Dalam Ruangan') {
      return _buildPremiumSliverView(
        context: context,
        headerTitle: 'PANDUAN PASCA GEMPA',
        title: 'Pasca Gempa\ndi Dalam Ruangan',
        gradientColors: const [Color(0xFFA3E635), Color(0xFF65A30D)], // Lime/Olive Green
        cards: [
          _buildStandardStepCard(
            number: '1', action: 'KELUAR DENGAN TERTIB',
            desc: 'Setelah guncangan berhenti, keluarlah dari ruangan secara tertib, tidak berdesakan, dan hindari menggunakan lift.',
            icon: Icons.directions_walk_rounded,
            primaryColor: const Color(0xFF65A30D), lightBgColor: const Color(0xFFECFCCB), borderColor: const Color(0xFFD9F99D), iconBgColor: const Color(0xFFECFCCB),
          ),
          _buildStandardStepCard(
            number: '2', action: 'PERIKSA KONDISI BANGUNAN',
            desc: 'Perhatikan apakah ada kerusakan struktural yang membahayakan sebelum memutuskan untuk kembali ke dalam.',
            icon: Icons.domain_verification_rounded,
            primaryColor: const Color(0xFF65A30D), lightBgColor: const Color(0xFFECFCCB), borderColor: const Color(0xFFD9F99D), iconBgColor: const Color(0xFFECFCCB),
          ),
          _buildStandardStepCard(
            number: '3', action: 'MATIKAN LISTRIK & GAS',
            desc: 'Cabut peralatan listrik dan matikan aliran gas jika Anda mencium bau gas atau melihat kerusakan pada instalasi.',
            icon: Icons.power_off_rounded,
            primaryColor: const Color(0xFF65A30D), lightBgColor: const Color(0xFFECFCCB), borderColor: const Color(0xFFD9F99D), iconBgColor: const Color(0xFFECFCCB),
          ),
          _buildStandardStepCard(
            number: '4', action: 'HINDARI AREA RAWAN',
            desc: 'Jangan berdiri di dekat jendela kaca, lemari besar, atau benda yang berisiko jatuh akibat gempa susulan.',
            icon: Icons.warning_amber_rounded,
            primaryColor: const Color(0xFF65A30D), lightBgColor: const Color(0xFFECFCCB), borderColor: const Color(0xFFD9F99D), iconBgColor: const Color(0xFFECFCCB),
          ),
          _buildStandardStepCard(
            number: '5', action: 'BERKUMPUL DI TITIK AMAN',
            desc: 'Segera menuju ke titik kumpul atau area terbuka yang jauh dari pohon besar, tiang listrik, dan bangunan tinggi.',
            icon: Icons.location_on_rounded,
            primaryColor: const Color(0xFF65A30D), lightBgColor: const Color(0xFFECFCCB), borderColor: const Color(0xFFD9F99D), iconBgColor: const Color(0xFFECFCCB),
          ),
        ],
      );
    } else {
      // Luar Ruangan
      return _buildPremiumSliverView(
        context: context,
        headerTitle: 'PANDUAN PASCA GEMPA',
        title: 'Pasca Gempa\ndi Luar Ruangan',
        gradientColors: const [Color(0xFF94A3B8), Color(0xFF334155)], // Slate/Blue-Gray
        cards: [
          _buildStandardStepCard(
            number: '1', action: 'JAUHI AREA LONGSOR',
            desc: 'Jika berada di sekitar perbukitan, waspadai tanah longsor. Jika di sekitar pantai, segera menjauh ke dataran tinggi.',
            icon: Icons.landscape_rounded,
            primaryColor: const Color(0xFF334155), lightBgColor: const Color(0xFFF8FAFC), borderColor: const Color(0xFFF1F5F9), iconBgColor: const Color(0xFFF8FAFC),
          ),
          _buildStandardStepCard(
            number: '2', action: 'WASPADA GEMPA SUSULAN',
            desc: 'Bersiaplah untuk gempa susulan yang mungkin terjadi dan tetap berada di area terbuka yang aman.',
            icon: Icons.sensors_rounded,
            primaryColor: const Color(0xFF334155), lightBgColor: const Color(0xFFF8FAFC), borderColor: const Color(0xFFF1F5F9), iconBgColor: const Color(0xFFF8FAFC),
          ),
          _buildStandardStepCard(
            number: '3', action: 'JAUHI KABEL PUTUS',
            desc: 'Hindari genangan air atau area di dekat kabel listrik yang putus untuk mencegah bahaya tersengat listrik.',
            icon: Icons.electrical_services_rounded,
            primaryColor: const Color(0xFF334155), lightBgColor: const Color(0xFFF8FAFC), borderColor: const Color(0xFFF1F5F9), iconBgColor: const Color(0xFFF8FAFC),
          ),
          _buildStandardStepCard(
            number: '4', action: 'HUBUNGI KELUARGA',
            desc: 'Gunakan pesan singkat (SMS/Chat) daripada panggilan suara agar jaringan telekomunikasi tidak kelebihan beban.',
            icon: Icons.contact_phone_rounded,
            primaryColor: const Color(0xFF334155), lightBgColor: const Color(0xFFF8FAFC), borderColor: const Color(0xFFF1F5F9), iconBgColor: const Color(0xFFF8FAFC),
          ),
          _buildStandardStepCard(
            number: '5', action: 'IKUTI ARAHAN PETUGAS',
            desc: 'Patuhi instruksi dari petugas evakuasi, relawan, atau pihak berwenang di lokasi kejadian secara tertib.',
            icon: Icons.person_pin_circle_rounded,
            primaryColor: const Color(0xFF334155), lightBgColor: const Color(0xFFF8FAFC), borderColor: const Color(0xFFF1F5F9), iconBgColor: const Color(0xFFF8FAFC),
          ),
        ],
      );
    }
  }

  Widget _buildPremiumSliverView({
    required BuildContext context,
    required String headerTitle,
    required String title,
    required List<Color> gradientColors, // Keeping signature, but we will override with Bahaya theme
    required List<Widget> cards,
  }) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light background matching Waspada
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 180.0,
            backgroundColor: const Color(0xFFDC2626), // Pinned Appbar color (Red)
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
                  'Zona Bahaya: $cityName',
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
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFEF4444), // Vivid Red
                          Color(0xFFDC2626), // Medium Red
                          Color(0xFF991B1B), // Dark Red
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
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
                            const Color(0xFFEF4444).withValues(alpha: 0.45),
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
                              color: const Color(0xFFFCA5A5).withValues(alpha: 0.40),
                              width: 1.0,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome_rounded, color: Color(0xFFFCA5A5), size: 12),
                              SizedBox(width: 6),
                              Text(
                                'Panduan Keselamatan',
                                style: TextStyle(
                                  color: Color(0xFFFCA5A5),
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
                  color: Color(0xFFF8F9FA), // Light background
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
                                    color: const Color(0xFFEF4444), // Flat red circle
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFEF4444).withValues(alpha: 0.35),
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
                                      : const Color(0xFFEF4444).withValues(alpha: 0.40),
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

  Widget _buildStandardStepCard({
    required String number,
    required String action,
    required String desc,
    required IconData icon,
    Color primaryColor = const Color(0xFFEF4444),
    Color lightBgColor = const Color(0xFFFEF2F2),
    Color borderColor = const Color(0xFFFCA5A5),
    Color iconBgColor = const Color(0xFFFEF2F2),
  }) {
    // Force override with Edukasi Bahaya's Red Theme
    primaryColor = const Color(0xFFEF4444); // Vivid Red
    borderColor = const Color(0xFFFCA5A5); // Lighter red
    iconBgColor = const Color(0xFFFEF2F2); // Very light red
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withValues(alpha: 0.12),
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
                opacity: 0.18,
                child: Icon(icon, size: 95, color: const Color(0xFFEF4444)),
              ),
            ),

            // ── Left accent bar ──
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 5,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  borderRadius: BorderRadius.only(
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
                      // Icon in rounded red container
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.30),
                            width: 1,
                          ),
                        ),
                        child: Icon(icon, size: 18, color: const Color(0xFFEF4444)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              action,
                              style: const TextStyle(
                                color: Color(0xFF991B1B), // Deeper red for title
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.3,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 5),
                            // "Langkah Penting" badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.bolt_rounded,
                                      size: 10,
                                      color: const Color(0xFFEF4444)),
                                  const SizedBox(width: 3),
                                  const Text(
                                    'Langkah Penting',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF991B1B),
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
                          const Color(0xFFEF4444).withValues(alpha: 0.60),
                          const Color(0xFFEF4444).withValues(alpha: 0.0),
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
