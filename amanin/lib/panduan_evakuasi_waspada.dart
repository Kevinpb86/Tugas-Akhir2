import 'package:flutter/material.dart';

class PanduanEvakuasiWaspadaPage extends StatelessWidget {
  final String cityName;
  final int initialTabIndex; // Represents the phase: 0=Sebelum, 1=Saat, 2=Setelah
  final String locationCategory; // 'Dalam Ruangan' | 'Luar Ruangan' | 'Pesisir Pantai'

  const PanduanEvakuasiWaspadaPage({
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
        title: 'Kesiapsiagaan Waspada\ndi Pesisir Pantai',
        gradientColors: const [Color(0xFF2DD4BF), Color(0xFF0D9488)], // Ocean Teal
        cards: [
          _buildStandardStepCard(
            number: '1', action: 'PERIKSA KONDISI JALUR EVAKUASI',
            desc: 'Lihat secara langsung kondisi jalur yang mengarah menjauhi pantai. Pastikan jalur tidak tertutup kendaraan, pagar, bangunan, atau hambatan lain yang dapat memperlambat perpindahan.',
            icon: Icons.directions_run_rounded,
            primaryColor: const Color(0xFF0D9488), lightBgColor: const Color(0xFFCCFBF1), borderColor: const Color(0xFF99F6E4), iconBgColor: const Color(0xFFF0FDFA),
          ),
          _buildStandardStepCard(
            number: '2', action: 'TENTUKAN PEMICU EVAKUASI MANDIRI',
            desc: 'Ingat bahwa gempa yang terasa sangat kuat, berlangsung lama, air laut surut atau naik secara tidak biasa, serta suara gemuruh dari laut merupakan tanda untuk segera melakukan evakuasi.',
            icon: Icons.location_on_rounded,
            primaryColor: const Color(0xFF0D9488), lightBgColor: const Color(0xFFCCFBF1), borderColor: const Color(0xFF99F6E4), iconBgColor: const Color(0xFFF0FDFA),
          ),
          _buildStandardStepCard(
            number: '3', action: 'SEPAKATI TITIK TEMU KELUARGA',
            desc: 'Tentukan satu lokasi pertemuan yang berada jauh dari garis pantai dan area rendah. Kesepakatan ini membantu anggota keluarga tetap terarah apabila terpisah saat keadaan darurat.',
            icon: Icons.waves_rounded,
            primaryColor: const Color(0xFF0D9488), lightBgColor: const Color(0xFFCCFBF1), borderColor: const Color(0xFF99F6E4), iconBgColor: const Color(0xFFF0FDFA),
          ),
          _buildStandardStepCard(
            number: '4', action: 'KENALI PILIHAN EVAKUASI VERTIKAL',
            desc: 'Apabila tempat tinggi sulit dijangkau, kenali bangunan evakuasi atau bangunan bertingkat yang kokoh dan telah ditetapkan sebagai tempat evakuasi sementara.',
            icon: Icons.signpost_rounded,
            primaryColor: const Color(0xFF0D9488), lightBgColor: const Color(0xFFCCFBF1), borderColor: const Color(0xFF99F6E4), iconBgColor: const Color(0xFFF0FDFA),
          ),
          _buildStandardStepCard(
            number: '5', action: 'SIAPKAN BARANG DALAM JANGKAUAN',
            desc: 'Letakkan alas kaki, ponsel, identitas, obat pribadi, air minum, dan alat penerangan di tempat yang mudah diambil tanpa menghabiskan waktu untuk mengemas barang.',
            icon: Icons.contact_phone_rounded,
            primaryColor: const Color(0xFF0D9488), lightBgColor: const Color(0xFFCCFBF1), borderColor: const Color(0xFF99F6E4), iconBgColor: const Color(0xFFF0FDFA),
          ),
          _buildStandardStepCard(
            number: '6', action: 'KURANGI AKTIVITAS DI AREA RENDAH',
            desc: 'Hindari berlama-lama di bibir pantai, muara sungai, dermaga, atau cekungan rendah ketika terdapat informasi peningkatan aktivitas gempa di sekitar wilayah pesisir.',
            icon: Icons.backpack_rounded,
            primaryColor: const Color(0xFF0D9488), lightBgColor: const Color(0xFFCCFBF1), borderColor: const Color(0xFF99F6E4), iconBgColor: const Color(0xFFF0FDFA),
          ),
          _buildStandardStepCard(
            number: '7', action: 'AKTIFKAN INFORMASI RESMI',
            desc: 'Pastikan ponsel dapat menerima informasi dari BMKG, BPBD, pemerintah daerah, atau sistem peringatan setempat. Hindari menjadikan pesan berantai sebagai dasar pengambilan keputusan.',
            icon: Icons.explore_rounded,
            primaryColor: const Color(0xFF0D9488), lightBgColor: const Color(0xFFCCFBF1), borderColor: const Color(0xFF99F6E4), iconBgColor: const Color(0xFFF0FDFA),
          ),
        ],
      );
    } else if (locationCategory == 'Pegunungan') {
      return _buildPremiumSliverView(
        context: context,
        headerTitle: 'PANDUAN SIAGA BENCANA',
        title: 'Kesiapsiagaan Waspada\ndi Pegunungan',
        gradientColors: const [Color(0xFF38BDF8), Color(0xFF0284C7)], // Cool blue gradient
        cards: [
          _buildStandardStepCard(
            number: '1', action: 'KENALI KONDISI MEDAN DI SEKITAR',
            desc: 'Perhatikan apakah Anda berada dekat lereng curam, tebing, jurang, batu besar, atau jalur sempit. Pengenalan kondisi medan membantu Anda lebih cepat menentukan arah aman saat terjadi guncangan.',
            icon: Icons.landscape_rounded,
            primaryColor: const Color(0xFF0284C7), lightBgColor: const Color(0xFFE0F2FE), borderColor: const Color(0xFFBAE6FD), iconBgColor: const Color(0xFFF0F9FF),
          ),
          _buildStandardStepCard(
            number: '2', action: 'TENTUKAN TITIK BERHENTI SEMENTARA',
            desc: 'Selain jalur evakuasi, kenali juga tempat berhenti sementara yang relatif datar, terbuka, dan tidak berada tepat di bawah tebing atau pohon besar.',
            icon: Icons.place_rounded,
            primaryColor: const Color(0xFF0284C7), lightBgColor: const Color(0xFFE0F2FE), borderColor: const Color(0xFFBAE6FD), iconBgColor: const Color(0xFFF0F9FF),
          ),
          _buildStandardStepCard(
            number: '3', action: 'AMATI TANDA MEDAN YANG TIDAK STABIL',
            desc: 'Waspadai retakan tanah, batu kecil yang sering jatuh, tanah gembur, bekas longsoran, atau pohon yang miring. Tanda-tanda ini menunjukkan area yang perlu dihindari lebih awal.',
            icon: Icons.warning_amber_rounded,
            primaryColor: const Color(0xFF0284C7), lightBgColor: const Color(0xFFE0F2FE), borderColor: const Color(0xFFBAE6FD), iconBgColor: const Color(0xFFF0F9FF),
          ),
          _buildStandardStepCard(
            number: '4', action: 'PILIH JALUR YANG LEBIH AMAN',
            desc: 'Gunakan jalur resmi atau jalur yang paling stabil. Hindari memotong lereng curam, tepi jurang, atau jalur dekat dinding batu yang rawan runtuh.',
            icon: Icons.directions_walk_rounded,
            primaryColor: const Color(0xFF0284C7), lightBgColor: const Color(0xFFE0F2FE), borderColor: const Color(0xFFBAE6FD), iconBgColor: const Color(0xFFF0F9FF),
          ),
          _buildStandardStepCard(
            number: '5', action: 'PERHATIKAN KONDISI CUACA',
            desc: 'Jika cuaca berkabut, hujan, atau tanah terasa licin, tingkatkan kewaspadaan karena gempa dapat memperbesar risiko longsor atau terpeleset saat berpindah.',
            icon: Icons.cloud_rounded,
            primaryColor: const Color(0xFF0284C7), lightBgColor: const Color(0xFFE0F2FE), borderColor: const Color(0xFFBAE6FD), iconBgColor: const Color(0xFFF0F9FF),
          ),
          _buildStandardStepCard(
            number: '6', action: 'SIAPKAN PERLENGKAPAN PRAKTIS',
            desc: 'Bawa ponsel, power bank, peluit, senter, jaket, air minum, dan obat pribadi dalam tas yang mudah dijangkau agar siap digunakan sewaktu diperlukan.',
            icon: Icons.backpack_rounded,
            primaryColor: const Color(0xFF0284C7), lightBgColor: const Color(0xFFE0F2FE), borderColor: const Color(0xFFBAE6FD), iconBgColor: const Color(0xFFF0F9FF),
          ),
          _buildStandardStepCard(
            number: '7', action: 'GUNAKAN SISTEM BERPASANGAN',
            desc: 'Jika beraktivitas di pegunungan bersama orang lain, usahakan tidak berpencar terlalu jauh. Dengan tetap berdekatan, proses saling membantu akan lebih mudah saat kondisi darurat.',
            icon: Icons.people_rounded,
            primaryColor: const Color(0xFF0284C7), lightBgColor: const Color(0xFFE0F2FE), borderColor: const Color(0xFFBAE6FD), iconBgColor: const Color(0xFFF0F9FF),
          ),
          _buildStandardStepCard(
            number: '8', action: 'SIMPAN KONTAK DAN INFO RESMI',
            desc: 'Simpan nomor keluarga, pengelola kawasan, BPBD, atau layanan darurat setempat. Pantau informasi resmi dari BMKG atau pihak kawasan sebelum dan selama aktivitas.',
            icon: Icons.contact_phone_rounded,
            primaryColor: const Color(0xFF0284C7), lightBgColor: const Color(0xFFE0F2FE), borderColor: const Color(0xFFBAE6FD), iconBgColor: const Color(0xFFF0F9FF),
          ),
        ],
      );
    } else if (locationCategory == 'Dalam Ruangan') {
      return _buildPremiumSliverView(
        context: context,
        headerTitle: 'PANDUAN SIAGA BENCANA',
        title: 'Kesiapsiagaan Waspada\ndi Dalam Ruangan',
        gradientColors: const [Color(0xFFC084FC), Color(0xFF9333EA)], // Amethyst Violet
        cards: [
          _buildStandardStepCard(
            number: '1', action: 'PERIKSA POTENSI BENDA JATUH',
            desc: 'Perhatikan rak, televisi, lampu gantung, pajangan, dan barang yang berada di tempat tinggi. Pindahkan posisi duduk atau tempat beraktivitas apabila berada tepat di bawah benda yang berpotensi jatuh.',
            icon: Icons.safety_check_rounded,
            primaryColor: const Color(0xFF9333EA), lightBgColor: const Color(0xFFF3E8FF), borderColor: const Color(0xFFE9D5FF), iconBgColor: const Color(0xFFFAF5FF),
          ),
          _buildStandardStepCard(
            number: '2', action: 'TENTUKAN TEMPAT BERLINDUNG TERDEKAT',
            desc: 'Kenali meja yang kokoh atau bagian ruangan yang jauh dari kaca dan lemari tinggi. Tentukan tempat perlindungan berdasarkan posisi Anda agar tidak harus berlari jauh saat guncangan terjadi.',
            icon: Icons.exit_to_app_rounded,
            primaryColor: const Color(0xFF9333EA), lightBgColor: const Color(0xFFF3E8FF), borderColor: const Color(0xFFE9D5FF), iconBgColor: const Color(0xFFFAF5FF),
          ),
          _buildStandardStepCard(
            number: '3', action: 'PASTIKAN PINTU MUDAH DIBUKA',
            desc: 'Periksa pintu utama dan pintu ruangan agar tidak terkunci, macet, atau terhalang barang. Pintu yang dapat digunakan dengan baik akan memudahkan perpindahan setelah guncangan berhenti.',
            icon: Icons.broken_image_rounded,
            primaryColor: const Color(0xFF9333EA), lightBgColor: const Color(0xFFF3E8FF), borderColor: const Color(0xFFE9D5FF), iconBgColor: const Color(0xFFFAF5FF),
          ),
          _buildStandardStepCard(
            number: '4', action: 'LETAKKAN ALAS KAKI DI TEMPAT TERJANGKAU',
            desc: 'Simpan sandal atau sepatu di dekat tempat tidur atau area yang sering digunakan. Alas kaki dapat melindungi kaki dari pecahan kaca dan benda tajam setelah gempa.',
            icon: Icons.weekend_rounded,
            primaryColor: const Color(0xFF9333EA), lightBgColor: const Color(0xFFF3E8FF), borderColor: const Color(0xFFE9D5FF), iconBgColor: const Color(0xFFFAF5FF),
          ),
          _buildStandardStepCard(
            number: '5', action: 'SIAPKAN PENERANGAN PORTABEL',
            desc: 'Letakkan senter atau lampu darurat di lokasi yang mudah ditemukan. Pastikan baterainya masih berfungsi untuk digunakan apabila listrik padam.',
            icon: Icons.shield_rounded,
            primaryColor: const Color(0xFF9333EA), lightBgColor: const Color(0xFFF3E8FF), borderColor: const Color(0xFFE9D5FF), iconBgColor: const Color(0xFFFAF5FF),
          ),
          _buildStandardStepCard(
            number: '6', action: 'SEPAKATI TITIK KUMPUL',
            desc: 'Tentukan lokasi pertemuan bersama keluarga atau penghuni bangunan setelah melakukan evakuasi. Titik kumpul sebaiknya berada di area terbuka dan jauh dari bangunan.',
            icon: Icons.backpack_rounded,
            primaryColor: const Color(0xFF9333EA), lightBgColor: const Color(0xFFF3E8FF), borderColor: const Color(0xFFE9D5FF), iconBgColor: const Color(0xFFFAF5FF),
          ),
          _buildStandardStepCard(
            number: '7', action: 'LAKUKAN LATIHAN PERLINDUNGAN',
            desc: 'Biasakan melakukan gerakan merunduk, berlindung, dan berpegangan agar setiap penghuni memahami tindakan yang dilakukan saat gempa tanpa harus menunggu instruksi orang lain.',
            icon: Icons.campaign_rounded,
            primaryColor: const Color(0xFF9333EA), lightBgColor: const Color(0xFFF3E8FF), borderColor: const Color(0xFFE9D5FF), iconBgColor: const Color(0xFFFAF5FF),
          ),
        ],
      );
    } else {
      // Luar Ruangan
      return _buildPremiumSliverView(
        context: context,
        headerTitle: 'PANDUAN SIAGA BENCANA',
        title: 'Kesiapsiagaan Waspada\ndi Luar Ruangan',
        gradientColors: const [Color(0xFFD6D3D1), Color(0xFF78716C)], // Sand/Brown
        cards: [
          _buildStandardStepCard(
            number: '1', action: 'TENTUKAN AREA TERBUKA TERDEKAT',
            desc: 'Perhatikan lokasi lapangan, taman terbuka, halaman luas, atau area kosong yang dapat dicapai tanpa melewati bangunan tinggi dan jalan yang terlalu padat.',
            icon: Icons.park_rounded,
            primaryColor: const Color(0xFF78716C), lightBgColor: const Color(0xFFF5F5F4), borderColor: const Color(0xFFE7E5E4), iconBgColor: const Color(0xFFFAFAF9),
          ),
          _buildStandardStepCard(
            number: '2', action: 'AMATI BENDA DI ATAS JALUR',
            desc: 'Periksa keberadaan papan reklame, lampu jalan, kabel, balkon, kaca gedung, pot tanaman, dan benda lain yang dapat jatuh ke jalur pejalan kaki.',
            icon: Icons.visibility_rounded,
            primaryColor: const Color(0xFF78716C), lightBgColor: const Color(0xFFF5F5F4), borderColor: const Color(0xFFE7E5E4), iconBgColor: const Color(0xFFFAFAF9),
          ),
          _buildStandardStepCard(
            number: '3', action: 'KENALI ARAH PERPINDAHAN',
            desc: 'Tentukan arah bergerak dari tempat Anda beraktivitas menuju area terbuka. Pilih jalur yang tidak berada di antara gedung tinggi, di bawah jembatan, atau di dekat tembok panjang.',
            icon: Icons.directions_walk_rounded,
            primaryColor: const Color(0xFF78716C), lightBgColor: const Color(0xFFF5F5F4), borderColor: const Color(0xFFE7E5E4), iconBgColor: const Color(0xFFFAFAF9),
          ),
          _buildStandardStepCard(
            number: '4', action: 'PERHATIKAN BANGUNAN SEMENTARA',
            desc: 'Hindari beristirahat terlalu lama di bawah tenda besar, kanopi, panggung, halte, atau bangunan sementara yang terlihat tidak terpasang dengan kuat.',
            icon: Icons.domain_disabled_rounded,
            primaryColor: const Color(0xFF78716C), lightBgColor: const Color(0xFFF5F5F4), borderColor: const Color(0xFFE7E5E4), iconBgColor: const Color(0xFFFAFAF9),
          ),
          _buildStandardStepCard(
            number: '5', action: 'KETAHUI POSISI FASILITAS UMUM',
            desc: 'Kenali lokasi pos keamanan, pusat informasi, fasilitas kesehatan, dan titik kumpul yang dapat digunakan apabila terjadi gempa saat berada di tempat umum.',
            icon: Icons.location_on_rounded,
            primaryColor: const Color(0xFF78716C), lightBgColor: const Color(0xFFF5F5F4), borderColor: const Color(0xFFE7E5E4), iconBgColor: const Color(0xFFFAFAF9),
          ),
          _buildStandardStepCard(
            number: '6', action: 'SEPAKATI TEMPAT BERTEMU',
            desc: 'Apabila beraktivitas bersama keluarga atau kelompok, tentukan satu tempat bertemu di area terbuka agar tidak saling mencari di sekitar bangunan setelah gempa.',
            icon: Icons.people_rounded,
            primaryColor: const Color(0xFF78716C), lightBgColor: const Color(0xFFF5F5F4), borderColor: const Color(0xFFE7E5E4), iconBgColor: const Color(0xFFFAFAF9),
          ),
          _buildStandardStepCard(
            number: '7', action: 'PERHATIKAN KONDISI KERAMAIAN',
            desc: 'Saat berada di pasar, tempat wisata, stadion, atau pusat keramaian, perhatikan akses keluar yang tidak terlalu sempit agar tidak terjebak dalam kepadatan.',
            icon: Icons.explore_rounded,
            primaryColor: const Color(0xFF78716C), lightBgColor: const Color(0xFFF5F5F4), borderColor: const Color(0xFFE7E5E4), iconBgColor: const Color(0xFFFAFAF9),
          ),
          _buildStandardStepCard(
            number: '8', action: 'AKTIFKAN INFORMASI RESMI',
            desc: 'Pastikan ponsel dapat menerima informasi dari BMKG, BNPB, BPBD, atau pemerintah daerah. Gunakan informasi resmi untuk memahami perkembangan kondisi gempa.',
            icon: Icons.campaign_rounded,
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
        title: 'Tindakan Waspada Saat Gempa\ndi Pesisir Pantai',
        gradientColors: const [Color(0xFFF87171), Color(0xFFDC2626)], // Danger Red
        cards: [
          _buildStandardStepCard(
            number: '1', action: 'LINDUNGI DIRI SELAMA GUNCANGAN',
            desc: 'Tetap tenang dan lindungi kepala serta leher. Jauhi pohon besar, tiang listrik, papan, bangunan ringan, dan benda lain yang dapat roboh atau jatuh.',
            icon: Icons.shield_rounded,
            primaryColor: const Color(0xFFDC2626), lightBgColor: const Color(0xFFFEF2F2), borderColor: const Color(0xFFFECACA), iconBgColor: const Color(0xFFFEF2F2),
          ),
          _buildStandardStepCard(
            number: '2', action: 'JAUHI GARIS AIR DAN MUARA',
            desc: 'Jangan bergerak mendekati laut untuk melihat perubahan permukaan air. Menjauhlah dari bibir pantai, muara sungai, dermaga, dan kawasan yang lebih rendah.',
            icon: Icons.block_rounded,
            primaryColor: const Color(0xFFDC2626), lightBgColor: const Color(0xFFFEF2F2), borderColor: const Color(0xFFFECACA), iconBgColor: const Color(0xFFFEF2F2),
          ),
          _buildStandardStepCard(
            number: '3', action: 'TINDAK LANJUTI TANDA ALAMI',
            desc: 'Jika guncangan terasa kuat atau berlangsung lama, air laut berubah secara tiba-tiba, atau terdengar suara gemuruh, segera menuju tempat tinggi tanpa menunggu pesan atau sirene.',
            icon: Icons.hearing_rounded,
            primaryColor: const Color(0xFFDC2626), lightBgColor: const Color(0xFFFEF2F2), borderColor: const Color(0xFFFECACA), iconBgColor: const Color(0xFFFEF2F2),
          ),
          _buildStandardStepCard(
            number: '4', action: 'GUNAKAN RUTE TERCEPAT YANG AMAN',
            desc: 'Ikuti rambu evakuasi dan pilih jalur yang menjauhi pantai. Hindari jalan sempit, jembatan, bangunan retak, kabel listrik, serta jalur yang berpotensi mengalami kemacetan.',
            icon: Icons.directions_walk_rounded,
            primaryColor: const Color(0xFFDC2626), lightBgColor: const Color(0xFFFEF2F2), borderColor: const Color(0xFFFECACA), iconBgColor: const Color(0xFFFEF2F2),
          ),
          _buildStandardStepCard(
            number: '5', action: 'UTAMAKAN EVAKUASI BERJALAN KAKI',
            desc: 'Apabila tempat aman masih dapat dijangkau dengan berjalan kaki, hindari menggunakan kendaraan karena dapat menimbulkan kemacetan dan menghambat proses evakuasi masyarakat lainnya.',
            icon: Icons.domain_disabled_rounded,
            primaryColor: const Color(0xFFDC2626), lightBgColor: const Color(0xFFFEF2F2), borderColor: const Color(0xFFFECACA), iconBgColor: const Color(0xFFFEF2F2),
          ),
          _buildStandardStepCard(
            number: '6', action: 'BANTU KELOMPOK RENTAN',
            desc: 'Bantu anak-anak, lansia, penyandang disabilitas, atau orang yang mengalami kesulitan bergerak tanpa menghentikan perjalanan menuju tempat aman.',
            icon: Icons.person_pin_circle_rounded,
            primaryColor: const Color(0xFFDC2626), lightBgColor: const Color(0xFFFEF2F2), borderColor: const Color(0xFFFECACA), iconBgColor: const Color(0xFFFEF2F2),
          ),
          _buildStandardStepCard(
            number: '7', action: 'JANGAN BERHENTI UNTUK MEREKAM',
            desc: 'Jangan berhenti untuk mengambil foto, merekam video, mencari barang, atau mengamati laut. Keselamatan dan kecepatan menuju tempat tinggi harus menjadi prioritas.',
            icon: Icons.hourglass_empty_rounded,
            primaryColor: const Color(0xFFDC2626), lightBgColor: const Color(0xFFFEF2F2), borderColor: const Color(0xFFFECACA), iconBgColor: const Color(0xFFFEF2F2),
          ),
        ],
      );
    } else if (locationCategory == 'Pegunungan') {
      return _buildPremiumSliverView(
        context: context,
        headerTitle: 'PANDUAN SAAT GEMPA',
        title: 'Tindakan Waspada Saat Gempa\ndi Pegunungan',
        gradientColors: const [Color(0xFFFFB74D), Color(0xFFF57C00)], // Warm orange gradient
        cards: [
          _buildStandardStepCard(
            number: '1', action: 'TETAP TENANG AND HENTIKAN LANGKAH SEJENAK',
            desc: 'Saat guncangan mulai terasa, hentikan aktivitas sejenak untuk menjaga keseimbangan. Jangan langsung berlari tanpa melihat kondisi sekitar.',
            icon: Icons.self_improvement_rounded,
            primaryColor: const Color(0xFF0284C7), lightBgColor: const Color(0xFFE0F2FE), borderColor: const Color(0xFFBAE6FD), iconBgColor: const Color(0xFFF0F9FF),
          ),
          _buildStandardStepCard(
            number: '2', action: 'JAGA JARAK DARI TEBING DAN LERENG CURAM',
            desc: 'Jika posisi Anda dekat tebing, dinding batu, atau lereng yang rawan longsor, menjauhlah secara hati-hati menuju area yang lebih terbuka dan stabil.',
            icon: Icons.social_distance_rounded,
            primaryColor: const Color(0xFF0284C7), lightBgColor: const Color(0xFFE0F2FE), borderColor: const Color(0xFFBAE6FD), iconBgColor: const Color(0xFFF0F9FF),
          ),
          _buildStandardStepCard(
            number: '3', action: 'HINDARI BATU LONGGAR DAN MATERIAL GANTUNG',
            desc: 'Perhatikan batu di atas jalur, ranting besar, atau material yang tampak mudah jatuh. Jangan berlindung di tempat yang justru berada di bawah sumber bahaya.',
            icon: Icons.warning_amber_rounded,
            primaryColor: const Color(0xFF0284C7), lightBgColor: const Color(0xFFE0F2FE), borderColor: const Color(0xFFBAE6FD), iconBgColor: const Color(0xFFF0F9FF),
          ),
          _buildStandardStepCard(
            number: '4', action: 'BERGERAK KE AREA YANG LEBIH DATAR',
            desc: 'Apabila memungkinkan, arahkan perpindahan ke tanah yang lebih datar dan terbuka. Area seperti ini lebih aman dibanding jalur sempit, miring, atau dekat jurang.',
            icon: Icons.explore_rounded,
            primaryColor: const Color(0xFF0284C7), lightBgColor: const Color(0xFFE0F2FE), borderColor: const Color(0xFFBAE6FD), iconBgColor: const Color(0xFFF0F9FF),
          ),
          _buildStandardStepCard(
            number: '5', action: 'LINDUNGI KEPALA DAN LEHER',
            desc: 'Gunakan tas, jaket, helm, atau kedua tangan untuk melindungi kepala dan leher apabila terlihat ada kerikil, ranting, atau material kecil yang berjatuhan.',
            icon: Icons.shield_rounded,
            primaryColor: const Color(0xFF0284C7), lightBgColor: const Color(0xFFE0F2FE), borderColor: const Color(0xFFBAE6FD), iconBgColor: const Color(0xFFF0F9FF),
          ),
          _buildStandardStepCard(
            number: '6', action: 'JANGAN MENDEKATI ALIRAN SUNGAI ATAU JURANG',
            desc: 'Hindari jalur di dekat sungai kecil, jurang, atau cekungan sempit karena area tersebut dapat menjadi jalur material longsor atau menyulitkan perpindahan.',
            icon: Icons.block_rounded,
            primaryColor: const Color(0xFF0284C7), lightBgColor: const Color(0xFFE0F2FE), borderColor: const Color(0xFFBAE6FD), iconBgColor: const Color(0xFFF0F9FF),
          ),
          _buildStandardStepCard(
            number: '7', action: 'PERHATIKAN SUARA DAN GERAKAN TANAH',
            desc: 'Jika terdengar suara batu bergeser, pohon retak, atau tanah runtuh, segera menjauh dari arah sumber suara dengan tetap menjaga ketenangan.',
            icon: Icons.hearing_rounded,
            primaryColor: const Color(0xFF0284C7), lightBgColor: const Color(0xFFE0F2FE), borderColor: const Color(0xFFBAE6FD), iconBgColor: const Color(0xFFF0F9FF),
          ),
          _buildStandardStepCard(
            number: '8', action: 'IKUTI ARAH ORANG YANG MEMAHAMI MEDAN',
            desc: 'Apabila bersama pemandu, petugas, atau pengelola kawasan, ikuti arahan mereka agar perpindahan ke lokasi aman lebih teratur dan tidak salah arah.',
            icon: Icons.person_pin_circle_rounded,
            primaryColor: const Color(0xFF0284C7), lightBgColor: const Color(0xFFE0F2FE), borderColor: const Color(0xFFBAE6FD), iconBgColor: const Color(0xFFF0F9FF),
          ),
        ],
      );
    } else if (locationCategory == 'Dalam Ruangan') {
      return _buildPremiumSliverView(
        context: context,
        headerTitle: 'PANDUAN SAAT GEMPA',
        title: 'Tindakan Waspada Saat Gempa\ndi Dalam Ruangan',
        gradientColors: const [Color(0xFFFBBF24), Color(0xFFFFB300)], // Amber/Yellow
        cards: [
          _buildStandardStepCard(
            number: '1', action: 'HENTIKAN AKTIVITAS',
            desc: 'Berhenti melakukan aktivitas dan tetap tenang. Jangan melanjutkan pekerjaan yang menggunakan benda tajam, benda panas, atau peralatan yang dapat menimbulkan cedera.',
            icon: Icons.self_improvement_rounded,
            primaryColor: const Color(0xFFFFB300), lightBgColor: const Color(0xFFFFFBEB), borderColor: const Color(0xFFFDE68A), iconBgColor: const Color(0xFFFFFBEB),
          ),
          _buildStandardStepCard(
            number: '2', action: 'BERLINDUNG DI POSISI TERDEKAT',
            desc: 'Segera merunduk dan berlindung di bawah meja yang kokoh apabila tersedia. Jangan memaksakan diri menyeberangi ruangan untuk mencari meja lain yang letaknya terlalu jauh.',
            icon: Icons.desk_rounded,
            primaryColor: const Color(0xFFFFB300), lightBgColor: const Color(0xFFFFFBEB), borderColor: const Color(0xFFFDE68A), iconBgColor: const Color(0xFFFFFBEB),
          ),
          _buildStandardStepCard(
            number: '3', action: 'PEGANG TEMPAT PERLINDUNGAN',
            desc: 'Pegang kaki meja atau bagian pelindung agar posisi Anda tidak bergeser selama guncangan. Tetap berlindung sampai getaran benar-benar mereda.',
            icon: Icons.front_hand_rounded,
            primaryColor: const Color(0xFFFFB300), lightBgColor: const Color(0xFFFFFBEB), borderColor: const Color(0xFFFDE68A), iconBgColor: const Color(0xFFFFFBEB),
          ),
          _buildStandardStepCard(
            number: '4', action: 'JAUHI SEKAT DAN BENDA GANTUNG',
            desc: 'Jaga jarak dari jendela, cermin, lemari, rak, televisi, lampu gantung, dan sekat ruangan yang dapat bergeser, pecah, atau roboh.',
            icon: Icons.grid_view_rounded,
            primaryColor: const Color(0xFFFFB300), lightBgColor: const Color(0xFFFFFBEB), borderColor: const Color(0xFFFDE68A), iconBgColor: const Color(0xFFFFFBEB),
          ),
          _buildStandardStepCard(
            number: '5', action: 'LINDUNGI KEPALA DAN LEHER',
            desc: 'Gunakan tas, bantal, buku tebal, jaket, atau kedua tangan untuk melindungi kepala dan leher apabila tidak terdapat meja yang dapat digunakan.',
            icon: Icons.shield_rounded,
            primaryColor: const Color(0xFFFFB300), lightBgColor: const Color(0xFFFFFBEB), borderColor: const Color(0xFFFDE68A), iconBgColor: const Color(0xFFFFFBEB),
          ),
          _buildStandardStepCard(
            number: '6', action: 'TETAP DI LANTAI YANG SAMA',
            desc: 'Jangan menggunakan lift atau berlari menuju tangga ketika guncangan masih berlangsung. Perpindahan dilakukan setelah getaran berhenti dan jalur telah diperiksa.',
            icon: Icons.elevator_rounded,
            primaryColor: const Color(0xFFFFB300), lightBgColor: const Color(0xFFFFFBEB), borderColor: const Color(0xFFFDE68A), iconBgColor: const Color(0xFFFFFBEB),
          ),
          _buildStandardStepCard(
            number: '7', action: 'AMATI KONDISI TANPA PANIK',
            desc: 'Perhatikan apabila terdapat plafon yang jatuh, kaca pecah, lemari bergeser, atau bau yang tidak biasa. Informasi tersebut digunakan untuk menentukan tindakan setelah guncangan berhenti.',
            icon: Icons.visibility_rounded,
            primaryColor: const Color(0xFFFFB300), lightBgColor: const Color(0xFFFFFBEB), borderColor: const Color(0xFFFDE68A), iconBgColor: const Color(0xFFFFFBEB),
          ),
        ],
      );
    } else {
      // Luar Ruangan
      return _buildPremiumSliverView(
        context: context,
        headerTitle: 'PANDUAN SAAT GEMPA',
        title: 'Tindakan Waspada Saat Gempa\ndi Luar Ruangan',
        gradientColors: const [Color(0xFFFB7185), Color(0xFFE65100)], // Rose/Pink
        cards: [
          _buildStandardStepCard(
            number: '1', action: 'HENTIKAN AKTIVITAS DAN STABILKAN POSISI',
            desc: 'Berhenti berjalan atau melakukan aktivitas yang dapat membuat tubuh kehilangan keseimbangan. Rendahkan posisi tubuh apabila guncangan membuat Anda sulit berdiri.',
            icon: Icons.self_improvement_rounded,
            primaryColor: const Color(0xFFE65100), lightBgColor: const Color(0xFFFFF8E1), borderColor: const Color(0xFFFECDD3), iconBgColor: const Color(0xFFFFF8E1),
          ),
          _buildStandardStepCard(
            number: '2', action: 'PERIKSA ARAH SEBELUM BERGERAK',
            desc: 'Lihat kondisi di depan, belakang, dan atas sebelum berpindah. Jangan bergerak terburu-buru menuju area yang belum diketahui keamanannya.',
            icon: Icons.visibility_rounded,
            primaryColor: const Color(0xFFE65100), lightBgColor: const Color(0xFFFFF8E1), borderColor: const Color(0xFFFECDD3), iconBgColor: const Color(0xFFFFF8E1),
          ),
          _buildStandardStepCard(
            number: '3', action: 'BERGERAK SECARA TERKENDALI',
            desc: 'Apabila terdapat area terbuka yang mudah dijangkau, bergeraklah dengan tenang menuju area tersebut tanpa berlari, mendorong orang lain, atau melawan arah kerumunan.',
            icon: Icons.directions_walk_rounded,
            primaryColor: const Color(0xFFE65100), lightBgColor: const Color(0xFFFFF8E1), borderColor: const Color(0xFFFECDD3), iconBgColor: const Color(0xFFFFF8E1),
          ),
          _buildStandardStepCard(
            number: '4', action: 'KELUAR DARI JANGKAUAN BENDA ROBOH',
            desc: 'Atur posisi agar tidak berada dalam jangkauan robohnya tembok, pagar, pohon, tiang, papan informasi, atau bagian luar bangunan.',
            icon: Icons.domain_disabled_rounded,
            primaryColor: const Color(0xFFE65100), lightBgColor: const Color(0xFFFFF8E1), borderColor: const Color(0xFFFECDD3), iconBgColor: const Color(0xFFFFF8E1),
          ),
          _buildStandardStepCard(
            number: '5', action: 'GUNAKAN PELINDUNG YANG TERSEDIA',
            desc: 'Gunakan tas, jaket, helm, buku, atau kedua tangan untuk melindungi kepala dan leher apabila terlihat benda kecil berjatuhan.',
            icon: Icons.shield_rounded,
            primaryColor: const Color(0xFFE65100), lightBgColor: const Color(0xFFFFF8E1), borderColor: const Color(0xFFFECDD3), iconBgColor: const Color(0xFFFFF8E1),
          ),
          _buildStandardStepCard(
            number: '6', action: 'JANGAN BERHENTI DI JALUR KENDARAAN',
            desc: 'Hindari berdiri di tengah jalan ketika mencari area terbuka. Perhatikan kendaraan yang dapat kehilangan kendali atau berhenti secara mendadak.',
            icon: Icons.warning_amber_rounded,
            primaryColor: const Color(0xFFE65100), lightBgColor: const Color(0xFFFFF8E1), borderColor: const Color(0xFFFECDD3), iconBgColor: const Color(0xFFFFF8E1),
          ),
          _buildStandardStepCard(
            number: '7', action: 'JANGAN MASUK KE BANGUNAN',
            desc: 'Jangan masuk ke toko, halte, pos, atau bangunan lain untuk mencari perlindungan ketika guncangan masih berlangsung karena bagian luar bangunan dapat mengalami kerusakan.',
            icon: Icons.block_rounded,
            primaryColor: const Color(0xFFE65100), lightBgColor: const Color(0xFFFFF8E1), borderColor: const Color(0xFFFECDD3), iconBgColor: const Color(0xFFFFF8E1),
          ),
          _buildStandardStepCard(
            number: '8', action: 'IKUTI ARAH PETUGAS',
            desc: 'Apabila berada di tempat wisata, sekolah, kampus, stadion, atau fasilitas umum, ikuti arahan petugas menuju titik kumpul tanpa berpisah dari jalur evakuasi.',
            icon: Icons.person_pin_circle_rounded,
            primaryColor: const Color(0xFFE65100), lightBgColor: const Color(0xFFFFF8E1), borderColor: const Color(0xFFFECDD3), iconBgColor: const Color(0xFFFFF8E1),
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
        title: 'Tindakan Waspada Setelah Gempa\ndi Pesisir Pantai',
        gradientColors: const [Color(0xFF818CF8), Color(0xFF4F46E5)], // Deep Indigo
        cards: [
          _buildStandardStepCard(
            number: '1', action: 'BERTAHAN DI TITIK AMAN SEMENTARA',
            desc: 'Tetap berada di tempat tinggi, titik kumpul, atau bangunan evakuasi sambil menunggu informasi resmi mengenai kondisi gempa dan kemungkinan ancaman tsunami.',
            icon: Icons.visibility_rounded,
            primaryColor: const Color(0xFF4F46E5), lightBgColor: const Color(0xFFEEF2FF), borderColor: const Color(0xFFE0E7FF), iconBgColor: const Color(0xFFEEF2FF),
          ),
          _buildStandardStepCard(
            number: '2', action: 'WASPADAI GELOMBANG BERIKUTNYA',
            desc: 'Jangan menganggap keadaan telah aman hanya karena tidak terlihat gelombang atau karena gelombang pertama telah berlalu. Tsunami dapat terdiri atas beberapa gelombang.',
            icon: Icons.block_rounded,
            primaryColor: const Color(0xFF4F46E5), lightBgColor: const Color(0xFFEEF2FF), borderColor: const Color(0xFFE0E7FF), iconBgColor: const Color(0xFFEEF2FF),
          ),
          _buildStandardStepCard(
            number: '3', action: 'LAKUKAN PEMERIKSAAN CEPAT',
            desc: 'Periksa kondisi diri dan orang di sekitar. Berikan pertolongan pertama sederhana apabila memungkinkan dan laporkan korban yang membutuhkan bantuan kepada petugas.',
            icon: Icons.directions_run_rounded,
            primaryColor: const Color(0xFF4F46E5), lightBgColor: const Color(0xFFEEF2FF), borderColor: const Color(0xFFE0E7FF), iconBgColor: const Color(0xFFEEF2FF),
          ),
          _buildStandardStepCard(
            number: '4', action: 'HINDARI JALUR KEMBALI YANG RENDAH',
            desc: 'Jangan kembali melalui pantai, muara, jalan pesisir, atau daerah rendah. Perhatikan pula bangunan rusak, jalan retak, pohon tumbang, dan kabel listrik yang terputus.',
            icon: Icons.health_and_safety_rounded,
            primaryColor: const Color(0xFF4F46E5), lightBgColor: const Color(0xFFEEF2FF), borderColor: const Color(0xFFE0E7FF), iconBgColor: const Color(0xFFEEF2FF),
          ),
          _buildStandardStepCard(
            number: '5', action: 'KIRIM KABAR SECARA SINGKAT',
            desc: 'Beri tahu keluarga bahwa Anda berada di tempat aman melalui pesan singkat. Hindari penggunaan komunikasi berlebihan agar jaringan tetap tersedia untuk kebutuhan darurat.',
            icon: Icons.contact_phone_rounded,
            primaryColor: const Color(0xFF4F46E5), lightBgColor: const Color(0xFFEEF2FF), borderColor: const Color(0xFFE0E7FF), iconBgColor: const Color(0xFFEEF2FF),
          ),
          _buildStandardStepCard(
            number: '6', action: 'VERIFIKASI INFORMASI',
            desc: 'Periksa kebenaran informasi melalui BMKG, BPBD, BNPB, pemerintah daerah, atau petugas di lokasi sebelum meneruskan informasi kepada orang lain.',
            icon: Icons.campaign_rounded,
            primaryColor: const Color(0xFF4F46E5), lightBgColor: const Color(0xFFEEF2FF), borderColor: const Color(0xFFE0E7FF), iconBgColor: const Color(0xFFEEF2FF),
          ),
          _buildStandardStepCard(
            number: '7', action: 'KEMBALI SETELAH DINYATAKAN AMAN',
            desc: 'Kembali ke pantai atau tempat tinggal hanya setelah terdapat pengumuman resmi bahwa ancaman telah berakhir. Jangan mengambil keputusan hanya berdasarkan kondisi laut yang terlihat tenang.',
            icon: Icons.fact_check_rounded,
            primaryColor: const Color(0xFF4F46E5), lightBgColor: const Color(0xFFEEF2FF), borderColor: const Color(0xFFE0E7FF), iconBgColor: const Color(0xFFEEF2FF),
          ),
        ],
      );
    } else if (locationCategory == 'Pegunungan') {
      return _buildPremiumSliverView(
        context: context,
        headerTitle: 'PANDUAN PASCA GEMPA',
        title: 'Tindakan Waspada Setelah Gempa\ndi Pegunungan',
        gradientColors: const [Color(0xFF4ADE80), Color(0xFF16A34A)], // Emerald Green gradient
        cards: [
          _buildStandardStepCard(
            number: '1', action: 'BERTAHAN DI LOKASI AMAN SEMENTARA',
            desc: 'Setelah guncangan berhenti, tetaplah di tempat yang lebih aman terlebih dahulu. Jangan langsung kembali mendekati tebing, lereng curam, atau jalur yang belum diperiksa.',
            icon: Icons.place_rounded,
            primaryColor: const Color(0xFF16A34A), lightBgColor: const Color(0xFFDCFCE7), borderColor: const Color(0xFF86EFAC), iconBgColor: const Color(0xFFF0FDF4),
          ),
          _buildStandardStepCard(
            number: '2', action: 'PERIKSA KONDISI DIRI DAN TEMAN',
            desc: 'Periksa apakah ada luka, pusing, atau kesulitan bergerak. Bantu orang di sekitar sesuai kemampuan tanpa membahayakan diri sendiri.',
            icon: Icons.health_and_safety_rounded,
            primaryColor: const Color(0xFF16A34A), lightBgColor: const Color(0xFFDCFCE7), borderColor: const Color(0xFF86EFAC), iconBgColor: const Color(0xFFF0FDF4),
          ),
          _buildStandardStepCard(
            number: '3', action: 'NILAI KONDISI JALUR SEBELUM MELANJUTKAN',
            desc: 'Perhatikan apakah ada retakan tanah, batu jatuh, pohon tumbang, atau jalur tertutup material. Jika jalur terlihat tidak aman, cari rute alternatif atau tunggu arahan.',
            icon: Icons.fact_check_rounded,
            primaryColor: const Color(0xFF16A34A), lightBgColor: const Color(0xFFDCFCE7), borderColor: const Color(0xFF86EFAC), iconBgColor: const Color(0xFFF0FDF4),
          ),
          _buildStandardStepCard(
            number: '4', action: 'HINDARI AREA YANG BARU MENGALAMI RUNTUHAN',
            desc: 'Jangan mendekati lokasi yang baru saja terjadi guguran batu atau longsoran kecil, karena area tersebut mungkin masih labil dan dapat runtuh lagi.',
            icon: Icons.block_rounded,
            primaryColor: const Color(0xFF16A34A), lightBgColor: const Color(0xFFDCFCE7), borderColor: const Color(0xFF86EFAC), iconBgColor: const Color(0xFFF0FDF4),
          ),
          _buildStandardStepCard(
            number: '5', action: 'WASPADAI GEMPA SUSULAN',
            desc: 'Tetap siaga terhadap guncangan berikutnya. Jika gempa susulan terjadi, segera ulangi tindakan perlindungan dan kembali menjauh dari medan berbahaya.',
            icon: Icons.sensors_rounded,
            primaryColor: const Color(0xFF16A34A), lightBgColor: const Color(0xFFDCFCE7), borderColor: const Color(0xFF86EFAC), iconBgColor: const Color(0xFFF0FDF4),
          ),
          _buildStandardStepCard(
            number: '6', action: 'GUNAKAN KOMUNIKASI SEPERLUNYA',
            desc: 'Hubungi keluarga, teman, atau petugas secara singkat untuk memberi kabar kondisi Anda. Gunakan komunikasi secara bijak agar jaringan tetap tersedia untuk keadaan darurat.',
            icon: Icons.contact_phone_rounded,
            primaryColor: const Color(0xFF16A34A), lightBgColor: const Color(0xFFDCFCE7), borderColor: const Color(0xFF86EFAC), iconBgColor: const Color(0xFFF0FDF4),
          ),
          _buildStandardStepCard(
            number: '7', action: 'JANGAN MASUK KE BANGUNAN ATAU POS YANG MERAGUKAN',
            desc: 'Apabila terdapat pondok, warung, pos, atau bangunan kecil di sekitar, jangan langsung masuk jika bangunan terlihat retak, miring, atau terdengar bunyi struktur yang tidak wajar.',
            icon: Icons.domain_disabled_rounded,
            primaryColor: const Color(0xFF16A34A), lightBgColor: const Color(0xFFDCFCE7), borderColor: const Color(0xFF86EFAC), iconBgColor: const Color(0xFFF0FDF4),
          ),
          _buildStandardStepCard(
            number: '8', action: 'TUNGGU ARAHAN SEBELUM MELANJUTKAN PERJALANAN',
            desc: 'Jika berada di jalur pendakian atau kawasan wisata alam, tunggu arahan dari petugas, pemandu, atau pengelola sebelum melanjutkan perjalanan atau turun dari lokasi.',
            icon: Icons.announcement_rounded,
            primaryColor: const Color(0xFF16A34A), lightBgColor: const Color(0xFFDCFCE7), borderColor: const Color(0xFF86EFAC), iconBgColor: const Color(0xFFF0FDF4),
          ),
        ],
      );
    } else if (locationCategory == 'Dalam Ruangan') {
      return _buildPremiumSliverView(
        context: context,
        headerTitle: 'PANDUAN PASCA GEMPA',
        title: 'Tindakan Waspada Setelah Gempa\ndi Dalam Ruangan',
        gradientColors: const [Color(0xFFA3E635), Color(0xFF65A30D)], // Lime/Olive Green
        cards: [
          _buildStandardStepCard(
            number: '1', action: 'TUNGGU GUNCANGAN BERHENTI',
            desc: 'Jangan langsung berdiri atau berlari ketika getaran mulai melemah. Tunggu beberapa saat dan pastikan benda di sekitar tidak lagi bergerak atau berjatuhan.',
            icon: Icons.hourglass_bottom_rounded,
            primaryColor: const Color(0xFF65A30D), lightBgColor: const Color(0xFFECFCCB), borderColor: const Color(0xFFD9F99D), iconBgColor: const Color(0xFFECFCCB),
          ),
          _buildStandardStepCard(
            number: '2', action: 'PERIKSA KONDISI DIRI',
            desc: 'Periksa apakah terdapat luka, pendarahan, atau bagian tubuh yang terasa sakit. Lakukan pertolongan pertama sederhana apabila memungkinkan sebelum membantu orang lain.',
            icon: Icons.health_and_safety_rounded,
            primaryColor: const Color(0xFF65A30D), lightBgColor: const Color(0xFFECFCCB), borderColor: const Color(0xFFD9F99D), iconBgColor: const Color(0xFFECFCCB),
          ),
          _buildStandardStepCard(
            number: '3', action: 'GUNAKAN ALAS KAKI',
            desc: 'Kenakan sandal atau sepatu sebelum berjalan untuk menghindari pecahan kaca, serpihan bangunan, paku, dan benda tajam lainnya.',
            icon: Icons.do_not_step_rounded,
            primaryColor: const Color(0xFF65A30D), lightBgColor: const Color(0xFFECFCCB), borderColor: const Color(0xFFD9F99D), iconBgColor: const Color(0xFFECFCCB),
          ),
          _buildStandardStepCard(
            number: '4', action: 'PERIKSA TANDA KERUSAKAN',
            desc: 'Amati retakan pada dinding, plafon yang turun, pintu yang berubah posisi, kabel terkelupas, bau gas, atau suara struktur yang tidak biasa. Jangan menyentuh kabel atau instalasi yang rusak.',
            icon: Icons.visibility_rounded,
            primaryColor: const Color(0xFF65A30D), lightBgColor: const Color(0xFFECFCCB), borderColor: const Color(0xFFD9F99D), iconBgColor: const Color(0xFFECFCCB),
          ),
          _buildStandardStepCard(
            number: '5', action: 'EVAKUASI JIKA KONDISI TIDAK AMAN',
            desc: 'Keluar secara tertib apabila terdapat kerusakan, bau gas, kebakaran, perintah petugas, atau bangunan terasa tidak stabil. Gunakan tangga dan hindari lift.',
            icon: Icons.exit_to_app_rounded,
            primaryColor: const Color(0xFF65A30D), lightBgColor: const Color(0xFFECFCCB), borderColor: const Color(0xFFD9F99D), iconBgColor: const Color(0xFFECFCCB),
          ),
          _buildStandardStepCard(
            number: '6', action: 'BERSIAP MENGHADAPI GEMPA SUSULAN',
            desc: 'Setelah berada di tempat aman, tetap waspada terhadap guncangan berikutnya. Apabila gempa susulan terjadi, kembali merunduk, melindungi kepala, dan menjauhi bangunan.',
            icon: Icons.warning_amber_rounded,
            primaryColor: const Color(0xFF65A30D), lightBgColor: const Color(0xFFECFCCB), borderColor: const Color(0xFFD9F99D), iconBgColor: const Color(0xFFECFCCB),
          ),
          _buildStandardStepCard(
            number: '7', action: 'TUNGGU PEMERIKSAAN SEBELUM KEMBALI',
            desc: 'Jangan langsung masuk kembali apabila bangunan mengalami kerusakan. Tunggu pemeriksaan dari pengelola bangunan, petugas, atau pihak yang memahami kondisi struktur.',
            icon: Icons.domain_disabled_rounded,
            primaryColor: const Color(0xFF65A30D), lightBgColor: const Color(0xFFECFCCB), borderColor: const Color(0xFFD9F99D), iconBgColor: const Color(0xFFECFCCB),
          ),
          _buildStandardStepCard(
            number: '8', action: 'PANTAU INFORMASI RESMI',
            desc: 'Ikuti informasi dari BMKG, BNPB, BPBD, pengelola gedung, atau pemerintah daerah. Jangan menyebarkan kabar mengenai gempa susulan atau kerusakan sebelum memastikan kebenarannya.',
            icon: Icons.campaign_rounded,
            primaryColor: const Color(0xFF65A30D), lightBgColor: const Color(0xFFECFCCB), borderColor: const Color(0xFFD9F99D), iconBgColor: const Color(0xFFECFCCB),
          ),
        ],
      );
    } else {
      // Luar Ruangan
      return _buildPremiumSliverView(
        context: context,
        headerTitle: 'PANDUAN PASCA GEMPA',
        title: 'Tindakan Waspada Setelah Gempa\ndi Luar Ruangan',
        gradientColors: const [Color(0xFF94A3B8), Color(0xFF334155)], // Slate/Blue-Gray
        cards: [
          _buildStandardStepCard(
            number: '1', action: 'TETAP DI AREA TERBUKA SEMENTARA',
            desc: 'Setelah guncangan berhenti, tetap berada di area terbuka selama beberapa saat. Jangan langsung kembali mendekati bangunan karena gempa susulan dapat terjadi.',
            icon: Icons.park_rounded,
            primaryColor: const Color(0xFF334155), lightBgColor: const Color(0xFFF8FAFC), borderColor: const Color(0xFFF1F5F9), iconBgColor: const Color(0xFFF8FAFC),
          ),
          _buildStandardStepCard(
            number: '2', action: 'PERIKSA KONDISI DIRI',
            desc: 'Pastikan tubuh tidak mengalami luka, pusing, atau kesulitan bergerak. Lakukan pertolongan pertama sederhana sebelum melanjutkan perjalanan.',
            icon: Icons.health_and_safety_rounded,
            primaryColor: const Color(0xFF334155), lightBgColor: const Color(0xFFF8FAFC), borderColor: const Color(0xFFF1F5F9), iconBgColor: const Color(0xFFF8FAFC),
          ),
          _buildStandardStepCard(
            number: '3', action: 'NILAI KEAMANAN JALUR',
            desc: 'Sebelum berpindah, perhatikan kondisi jalan, trotoar, jembatan, pagar, dan bangunan di sepanjang jalur. Pilih jalur lain apabila terlihat retak atau tertutup material.',
            icon: Icons.visibility_rounded,
            primaryColor: const Color(0xFF334155), lightBgColor: const Color(0xFFF8FAFC), borderColor: const Color(0xFFF1F5F9), iconBgColor: const Color(0xFFF8FAFC),
          ),
          _buildStandardStepCard(
            number: '4', action: 'JAUHI INSTALASI YANG RUSAK',
            desc: 'Hindari kabel listrik terputus, tiang miring, pipa bocor, genangan di sekitar kabel, dan fasilitas umum yang mengalami kerusakan.',
            icon: Icons.bolt_rounded,
            primaryColor: const Color(0xFF334155), lightBgColor: const Color(0xFFF8FAFC), borderColor: const Color(0xFFF1F5F9), iconBgColor: const Color(0xFFF8FAFC),
          ),
          _buildStandardStepCard(
            number: '5', action: 'JANGAN MENDEKATI KERUSAKAN',
            desc: 'Jangan berkumpul untuk melihat bangunan retak, pohon tumbang, atau kendaraan yang tertimpa benda. Tindakan tersebut dapat menghambat petugas dan menimbulkan risiko tambahan.',
            icon: Icons.block_rounded,
            primaryColor: const Color(0xFF334155), lightBgColor: const Color(0xFFF8FAFC), borderColor: const Color(0xFFF1F5F9), iconBgColor: const Color(0xFFF8FAFC),
          ),
          _buildStandardStepCard(
            number: '6', action: 'BANTU TANPA MEMBAHAYAKAN DIRI',
            desc: 'Bantu menenangkan orang yang panik, mengarahkan kelompok rentan ke area terbuka, atau menghubungi petugas. Jangan memasuki bangunan rusak untuk melakukan pertolongan tanpa perlengkapan.',
            icon: Icons.volunteer_activism_rounded,
            primaryColor: const Color(0xFF334155), lightBgColor: const Color(0xFFF8FAFC), borderColor: const Color(0xFFF1F5F9), iconBgColor: const Color(0xFFF8FAFC),
          ),
          _buildStandardStepCard(
            number: '7', action: 'LAPORKAN SUMBER BAHAYA',
            desc: 'Sampaikan kepada petugas apabila menemukan kabel terputus, kebocoran, kebakaran, jalan retak, atau bangunan yang terlihat tidak stabil.',
            icon: Icons.report_problem_rounded,
            primaryColor: const Color(0xFF334155), lightBgColor: const Color(0xFFF8FAFC), borderColor: const Color(0xFFF1F5F9), iconBgColor: const Color(0xFFF8FAFC),
          ),
          _buildStandardStepCard(
            number: '8', action: 'GUNAKAN KOMUNIKASI SEPERLUNYA',
            desc: 'Kirim pesan singkat kepada keluarga untuk memberi tahu kondisi dan lokasi Anda. Hindari panggilan panjang agar jaringan tetap tersedia bagi kebutuhan darurat.',
            icon: Icons.contact_phone_rounded,
            primaryColor: const Color(0xFF334155), lightBgColor: const Color(0xFFF8FAFC), borderColor: const Color(0xFFF1F5F9), iconBgColor: const Color(0xFFF8FAFC),
          ),
          _buildStandardStepCard(
            number: '9', action: 'PANTAU GEMPA SUSULAN',
            desc: 'Tetap bersiap apabila terjadi guncangan berikutnya. Saat gempa susulan terasa, pertahankan posisi di area terbuka dan kembali lindungi kepala.',
            icon: Icons.sensors_rounded,
            primaryColor: const Color(0xFF334155), lightBgColor: const Color(0xFFF8FAFC), borderColor: const Color(0xFFF1F5F9), iconBgColor: const Color(0xFFF8FAFC),
          ),
          _buildStandardStepCard(
            number: '10', action: 'LANJUTKAN AKTIVITAS SETETELAH AMAN',
            desc: 'Jangan langsung kembali ke tempat semula sebelum kondisi jalur dan bangunan dinyatakan aman oleh petugas, pengelola kawasan, atau pihak berwenang.',
            icon: Icons.sentiment_satisfied_alt_rounded,
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
    required List<Color> gradientColors, // Keeping signature, but we will override with Waspada theme
    required List<Widget> cards,
  }) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light background matching edukasi_waspada
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 180.0,
            backgroundColor: const Color(0xFFD97706), // Kuning-amber pekat premium
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
                          Color(0xFFD97706), // Amber pekat mendalam (kiri)
                          Color(0xFFEAB308), // Kuning murni hangat (tengah)
                          Color(0xFFF1C40F), // Kuning Sunflower pekat (kanan)
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
                            const Color(0xFFF1C40F).withValues(alpha: 0.45),
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
                              color: const Color(0xFFFFCB47).withValues(alpha: 0.40),
                              width: 1.0,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome_rounded, color: Color(0xFFFFCB47), size: 12),
                              SizedBox(width: 6),
                              Text(
                                'Panduan Keselamatan',
                                style: TextStyle(
                                  color: Color(0xFFFFCB47),
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
                                    color: const Color(0xFFFFC107), // Flat yellow circle
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFFC107).withValues(alpha: 0.35),
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
                                      : const Color(0xFFFFC107).withValues(alpha: 0.40),
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
    Color primaryColor = const Color(0xFFF57C00),
    Color lightBgColor = const Color(0xFFFFF8E1),
    Color borderColor = const Color(0xFFFFCC80),
    Color iconBgColor = const Color(0xFFFFF3E0),
  }) {
    // Force override with Edukasi Waspada's Bright Yellow Theme
    primaryColor = const Color(0xFFFFC107); // Bright Yellow
    borderColor = const Color(0xFFFFD54F); // Lighter yellow
    iconBgColor = const Color(0xFFFFF8E1); // Very light yellow
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFC107).withValues(alpha: 0.12),
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
                child: Icon(icon, size: 95, color: const Color(0xFFFFC107)),
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
                  color: Color(0xFFFFC107),
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
                      // Icon in rounded yellow container
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC107).withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                            color: const Color(0xFFFFC107).withValues(alpha: 0.30),
                            width: 1,
                          ),
                        ),
                        child: Icon(icon, size: 18, color: const Color(0xFFFFC107)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              action,
                              style: const TextStyle(
                                color: Color(0xFFB45309), // Deeper amber for title
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
                                color: const Color(0xFFFFC107).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.bolt_rounded,
                                      size: 10,
                                      color: const Color(0xFFFFC107)),
                                  const SizedBox(width: 3),
                                  const Text(
                                    'Langkah Penting',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFB45309),
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
                          const Color(0xFFFFC107).withValues(alpha: 0.60),
                          const Color(0xFFFFC107).withValues(alpha: 0.0),
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
} // <--- CLOSE PanduanEvakuasiWaspadaPage class here

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
