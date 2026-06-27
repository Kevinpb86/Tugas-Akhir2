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
        title: 'Siaga Gempa\ndi Pesisir Pantai',
        gradientColors: const [Color(0xFF2DD4BF), Color(0xFF0D9488)], // Ocean Teal
        cards: [
          _buildStandardStepCard(
            number: '1', action: 'KENALI JALUR EVAKUASI PANTAI',
            desc: 'Ketahui jalur evakuasi terdekat dari area pantai menuju tempat yang lebih aman agar tidak kebingungan saat terjadi gempa berpotensi bahaya lanjutan.',
            icon: Icons.directions_run_rounded,
            primaryColor: const Color(0xFF0D9488), lightBgColor: const Color(0xFFCCFBF1), borderColor: const Color(0xFF99F6E4), iconBgColor: const Color(0xFFF0FDFA),
          ),
          _buildStandardStepCard(
            number: '2', action: 'KETAHUI LOKASI TITIK KUMPUL',
            desc: 'Kenali lokasi tempat yang lebih tinggi, titik kumpul, atau bangunan evakuasi yang berada jauh dari garis pantai sebagai bentuk kesiapan awal.',
            icon: Icons.location_on_rounded,
            primaryColor: const Color(0xFF0D9488), lightBgColor: const Color(0xFFCCFBF1), borderColor: const Color(0xFF99F6E4), iconBgColor: const Color(0xFFF0FDFA),
          ),
          _buildStandardStepCard(
            number: '3', action: 'PAHAMI TANDA ALAMI TSUNAMI',
            desc: 'Waspadai guncangan gempa kuat, berlangsung lama, air laut tiba-tiba surut, atau suara gemuruh agar tidak menunggu lama saat tanda bahaya muncul.',
            icon: Icons.waves_rounded,
            primaryColor: const Color(0xFF0D9488), lightBgColor: const Color(0xFFCCFBF1), borderColor: const Color(0xFF99F6E4), iconBgColor: const Color(0xFFF0FDFA),
          ),
          _buildStandardStepCard(
            number: '4', action: 'PERHATIKAN RAMBU EVAKUASI',
            desc: 'Jika berada di pesisir, perhatikan rambu jalur evakuasi, papan peringatan, dan arah menuju titik aman untuk bergerak lebih cepat dan terarah.',
            icon: Icons.signpost_rounded,
            primaryColor: const Color(0xFF0D9488), lightBgColor: const Color(0xFFCCFBF1), borderColor: const Color(0xFF99F6E4), iconBgColor: const Color(0xFFF0FDFA),
          ),
          _buildStandardStepCard(
            number: '5', action: 'SIMPAN INFO DAN KONTAK',
            desc: 'Simpan nomor keluarga, BPBD, petugas, dan layanan darurat. Ikuti informasi resmi dari BMKG, BNPB, atau pemerintah daerah setempat.',
            icon: Icons.contact_phone_rounded,
            primaryColor: const Color(0xFF0D9488), lightBgColor: const Color(0xFFCCFBF1), borderColor: const Color(0xFF99F6E4), iconBgColor: const Color(0xFFF0FDFA),
          ),
          _buildStandardStepCard(
            number: '6', action: 'SIAPKAN PERLENGKAPAN DASAR',
            desc: 'Bawa ponsel, power bank, air minum, obat pribadi, dan identitas agar siap berpindah ke tempat aman dalam waktu singkat bila diperlukan.',
            icon: Icons.backpack_rounded,
            primaryColor: const Color(0xFF0D9488), lightBgColor: const Color(0xFFCCFBF1), borderColor: const Color(0xFF99F6E4), iconBgColor: const Color(0xFFF0FDFA),
          ),
          _buildStandardStepCard(
            number: '7', action: 'PERHATIKAN AKSES KELUAR',
            desc: 'Ketahui posisi jalur keluar terdekat saat di pantai. Anda tidak harus langsung meninggalkan area, tetapi tetap perhatikan akses keluar jika kondisi berubah.',
            icon: Icons.explore_rounded,
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
        cards: [          _buildStandardStepCard(
            number: '1', action: 'KENALI KONDISI LERENG',
            desc: 'Pengguna perlu memperhatikan apakah lokasi berada dekat lereng curam, tebing, jurang, atau tanah yang terlihat mudah bergeser. Tujuannya mengenali potensi bahaya sejak awal.',
            icon: Icons.landscape_rounded,
            primaryColor: const Color(0xFF0284C7), lightBgColor: const Color(0xFFE0F2FE), borderColor: const Color(0xFFBAE6FD), iconBgColor: const Color(0xFFF0F9FF),
          ),
          _buildStandardStepCard(
            number: '2', action: 'PERHATIKAN JALUR AMAN',
            desc: 'Sebelum melanjutkan aktivitas, ketahui jalur keluar atau evakuasi terdekat. Jalur aman sebaiknya tidak melewati tebing curam, pinggir jurang, atau jalan sempit.',
            icon: Icons.directions_walk_rounded,
            primaryColor: const Color(0xFF0284C7), lightBgColor: const Color(0xFFE0F2FE), borderColor: const Color(0xFFBAE6FD), iconBgColor: const Color(0xFFF0F9FF),
          ),
          _buildStandardStepCard(
            number: '3', action: 'PILIH AREA ISTIRAHAT AMAN',
            desc: 'Pilih lokasi yang lebih datar dan tidak berada tepat di bawah tebing, batu besar, atau pohon yang rapuh untuk mengurangi risiko jika terjadi guncangan.',
            icon: Icons.nature_people_rounded,
            primaryColor: const Color(0xFF0284C7), lightBgColor: const Color(0xFFE0F2FE), borderColor: const Color(0xFFBAE6FD), iconBgColor: const Color(0xFFF0F9FF),
          ),
          _buildStandardStepCard(
            number: '4', action: 'AMATI TANDA TANAH LABIL',
            desc: 'Perhatikan retakan kecil pada tanah, batuan lepas, pohon miring, tanah basah berlebihan, atau bekas longsoran kecil. Jika menemukan, menjauhlah perlahan.',
            icon: Icons.search_rounded,
            primaryColor: const Color(0xFF0284C7), lightBgColor: const Color(0xFFE0F2FE), borderColor: const Color(0xFFBAE6FD), iconBgColor: const Color(0xFFF0F9FF),
          ),
          _buildStandardStepCard(
            number: '5', action: 'BAWA PERLENGKAPAN DASAR',
            desc: 'Bawa perlengkapan sederhana seperti air minum, makanan ringan, obat pribadi, jaket, senter, peluit, dan power bank untuk bersiap menghadapi kondisi darurat.',
            icon: Icons.backpack_rounded,
            primaryColor: const Color(0xFF0284C7), lightBgColor: const Color(0xFFE0F2FE), borderColor: const Color(0xFFBAE6FD), iconBgColor: const Color(0xFFF0F9FF),
          ),
          _buildStandardStepCard(
            number: '6', action: 'SIMPAN KONTAK DARURAT',
            desc: 'Simpan nomor keluarga, BPBD, pengelola kawasan, atau layanan darurat setempat agar mudah meminta bantuan saat kondisi membahayakan.',
            icon: Icons.contact_phone_rounded,
            primaryColor: const Color(0xFF0284C7), lightBgColor: const Color(0xFFE0F2FE), borderColor: const Color(0xFFBAE6FD), iconBgColor: const Color(0xFFF0F9FF),
          ),
          _buildStandardStepCard(
            number: '7', action: 'PANTAU INFORMASI RESMI',
            desc: 'Sebelum bepergian, pantau informasi resmi dari BMKG, BNPB, atau BPBD. Hindari mengambil keputusan berdasarkan kabar yang belum jelas.',
            icon: Icons.campaign_rounded,
            primaryColor: const Color(0xFF0284C7), lightBgColor: const Color(0xFFE0F2FE), borderColor: const Color(0xFFBAE6FD), iconBgColor: const Color(0xFFF0F9FF),
          ),],
      );
    } else if (locationCategory == 'Dalam Ruangan') {
      return _buildPremiumSliverView(
        context: context,
        headerTitle: 'PANDUAN SIAGA BENCANA',
        title: 'Siaga Gempa\ndi Dalam Ruangan',
        gradientColors: const [Color(0xFFC084FC), Color(0xFF9333EA)], // Amethyst Violet
        cards: [
          _buildStandardStepCard(
            number: '1', action: 'KENALI TITIK AMAN',
            desc: 'Ketahui bagian ruangan untuk berlindung seperti bawah meja kuat atau area jauh dari kaca. Kenali terlebih dahulu agar tidak kebingungan saat guncangan.',
            icon: Icons.safety_check_rounded,
            primaryColor: const Color(0xFF9333EA), lightBgColor: const Color(0xFFF3E8FF), borderColor: const Color(0xFFE9D5FF), iconBgColor: const Color(0xFFFAF5FF),
          ),
          _buildStandardStepCard(
            number: '2', action: 'PERHATIKAN JALUR KELUAR',
            desc: 'Ketahui posisi pintu keluar, tangga, dan jalur evakuasi terdekat agar dapat keluar terarah setelah guncangan tanpa mencari jalur dalam panik.',
            icon: Icons.exit_to_app_rounded,
            primaryColor: const Color(0xFF9333EA), lightBgColor: const Color(0xFFF3E8FF), borderColor: const Color(0xFFE9D5FF), iconBgColor: const Color(0xFFFAF5FF),
          ),
          _buildStandardStepCard(
            number: '3', action: 'RAPIKAN BENDA MUDAH JATUH',
            desc: 'Vas, pajangan, atau buku sebaiknya tidak diletakkan di tepi meja atau rak tinggi untuk mengurangi risiko jatuh saat guncangan.',
            icon: Icons.broken_image_rounded,
            primaryColor: const Color(0xFF9333EA), lightBgColor: const Color(0xFFF3E8FF), borderColor: const Color(0xFFE9D5FF), iconBgColor: const Color(0xFFFAF5FF),
          ),
          _buildStandardStepCard(
            number: '4', action: 'JAUHKAN TEMPAT DUDUK',
            desc: 'Jangan terlalu sering berada dekat jendela kaca, lemari tinggi, rak besar, atau benda gantung yang berisiko pecah atau bergeser.',
            icon: Icons.weekend_rounded,
            primaryColor: const Color(0xFF9333EA), lightBgColor: const Color(0xFFF3E8FF), borderColor: const Color(0xFFE9D5FF), iconBgColor: const Color(0xFFFAF5FF),
          ),
          _buildStandardStepCard(
            number: '5', action: 'KETAHUI BENDA PELINDUNG',
            desc: 'Kenali benda di sekitar untuk melindungi kepala seperti tas, bantal, jaket, atau buku tebal jika tidak sempat berpindah.',
            icon: Icons.shield_rounded,
            primaryColor: const Color(0xFF9333EA), lightBgColor: const Color(0xFFF3E8FF), borderColor: const Color(0xFFE9D5FF), iconBgColor: const Color(0xFFFAF5FF),
          ),
          _buildStandardStepCard(
            number: '6', action: 'SIMPAN BARANG PENTING',
            desc: 'Letakkan ponsel, identitas, obat, dan senter di tempat yang mudah dijangkau sebagai kesiapan dasar jika harus keluar ruangan.',
            icon: Icons.backpack_rounded,
            primaryColor: const Color(0xFF9333EA), lightBgColor: const Color(0xFFF3E8FF), borderColor: const Color(0xFFE9D5FF), iconBgColor: const Color(0xFFFAF5FF),
          ),
          _buildStandardStepCard(
            number: '7', action: 'IKUTI INFORMASI RESMI',
            desc: 'Biasakan memantau informasi resmi dari BMKG, BNPB, atau BPBD untuk memahami kondisi gempa dan hindari kabar tidak jelas.',
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
        title: 'Siaga Gempa\ndi Luar Ruangan',
        gradientColors: const [Color(0xFFD6D3D1), Color(0xFF78716C)], // Sand/Brown
        cards: [
          _buildStandardStepCard(
            number: '1', action: 'KENALI AREA TERBUKA',
            desc: 'Ketahui lokasi area terbuka terdekat seperti lapangan atau taman. Area terbuka menjadi pilihan aman jika terjadi gempa saat di luar ruangan.',
            icon: Icons.park_rounded,
            primaryColor: const Color(0xFF78716C), lightBgColor: const Color(0xFFF5F5F4), borderColor: const Color(0xFFE7E5E4), iconBgColor: const Color(0xFFFAFAF9),
          ),
          _buildStandardStepCard(
            number: '2', action: 'PERHATIKAN BENDA TINGGI',
            desc: 'Kenali benda tinggi di sekitar seperti tiang listrik, pohon, lampu, atau papan reklame agar dapat menjaga jarak bila terjadi guncangan.',
            icon: Icons.visibility_rounded,
            primaryColor: const Color(0xFF78716C), lightBgColor: const Color(0xFFF5F5F4), borderColor: const Color(0xFFE7E5E4), iconBgColor: const Color(0xFFFAFAF9),
          ),
          _buildStandardStepCard(
            number: '3', action: 'KETAHUI JALUR AMAN',
            desc: 'Perhatikan jalur menuju area aman. Hindari jalur yang melewati bangunan rapuh, jembatan, jalan sempit, atau tempat yang rawan benda jatuh.',
            icon: Icons.directions_walk_rounded,
            primaryColor: const Color(0xFF78716C), lightBgColor: const Color(0xFFF5F5F4), borderColor: const Color(0xFFE7E5E4), iconBgColor: const Color(0xFFFAFAF9),
          ),
          _buildStandardStepCard(
            number: '4', action: 'HINDARI BANGUNAN TINGGI',
            desc: 'Jangan terlalu lama berada di dekat dinding gedung, kaca, pagar beton, atau etalase karena berisiko tinggi bila ada getaran.',
            icon: Icons.domain_disabled_rounded,
            primaryColor: const Color(0xFF78716C), lightBgColor: const Color(0xFFF5F5F4), borderColor: const Color(0xFFE7E5E4), iconBgColor: const Color(0xFFFAFAF9),
          ),
          _buildStandardStepCard(
            number: '5', action: 'SIMPAN INFO PENTING',
            desc: 'Simpan nomor keluarga dan layanan darurat. Pastikan ponsel memiliki daya cukup untuk mencari info atau menghubungi orang terdekat.',
            icon: Icons.contact_phone_rounded,
            primaryColor: const Color(0xFF78716C), lightBgColor: const Color(0xFFF5F5F4), borderColor: const Color(0xFFE7E5E4), iconBgColor: const Color(0xFFFAFAF9),
          ),
          _buildStandardStepCard(
            number: '6', action: 'PAHAMI INFO RESMI',
            desc: 'Ketahui sumber informasi resmi seperti BMKG, BNPB, atau BPBD agar tidak mudah percaya kabar burung jika terjadi gempa.',
            icon: Icons.campaign_rounded,
            primaryColor: const Color(0xFF78716C), lightBgColor: const Color(0xFFF5F5F4), borderColor: const Color(0xFFE7E5E4), iconBgColor: const Color(0xFFFAFAF9),
          ),
          _buildStandardStepCard(
            number: '7', action: 'PERHATIKAN LINGKUNGAN',
            desc: 'Bila berada di area publik, jalan raya, kampus, atau pusat keramaian, perhatikan kondisi sekitar agar siap menentukan arah bergerak.',
            icon: Icons.explore_rounded,
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
            desc: 'Berusaha tetap tenang dan perhatikan sekitar. Jika dekat warung, pohon besar, atau tiang listrik, jaga jarak agar tidak terkena benda yang jatuh.',
            icon: Icons.shield_rounded,
            primaryColor: const Color(0xFFDC2626), lightBgColor: const Color(0xFFFEF2F2), borderColor: const Color(0xFFFECACA), iconBgColor: const Color(0xFFFEF2F2),
          ),
          _buildStandardStepCard(
            number: '2', action: 'JANGAN DEKATI BIBIR PANTAI',
            desc: 'Tidak disarankan mendekati air laut saat guncangan terasa. Berada terlalu dekat dengan bibir pantai meningkatkan risiko jika gempa semakin berbahaya.',
            icon: Icons.block_rounded,
            primaryColor: const Color(0xFFDC2626), lightBgColor: const Color(0xFFFEF2F2), borderColor: const Color(0xFFFECACA), iconBgColor: const Color(0xFFFEF2F2),
          ),
          _buildStandardStepCard(
            number: '3', action: 'AMATI KEKUATAN GUNCANGAN',
            desc: 'Perhatikan apakah guncangan kuat atau cukup lama. Jika membuat Anda sulit berdiri, bersiaplah menjauh dari pantai menuju tempat tinggi.',
            icon: Icons.hearing_rounded,
            primaryColor: const Color(0xFFDC2626), lightBgColor: const Color(0xFFFEF2F2), borderColor: const Color(0xFFFECACA), iconBgColor: const Color(0xFFFEF2F2),
          ),
          _buildStandardStepCard(
            number: '4', action: 'BERGERAK KE AREA AMAN',
            desc: 'Jika terasa tidak aman, bergerak secara tertib dan tidak panik menuju jalur yang menjauh dari pantai sambil memperhatikan kondisi sekitar.',
            icon: Icons.directions_walk_rounded,
            primaryColor: const Color(0xFFDC2626), lightBgColor: const Color(0xFFFEF2F2), borderColor: const Color(0xFFFECACA), iconBgColor: const Color(0xFFFEF2F2),
          ),
          _buildStandardStepCard(
            number: '5', action: 'HINDARI JALAN SEMPIT',
            desc: 'Hindari jalur yang terlalu sempit, dekat bangunan rapuh, atau area padat yang dapat menghambat perpindahan ke tempat aman.',
            icon: Icons.domain_disabled_rounded,
            primaryColor: const Color(0xFFDC2626), lightBgColor: const Color(0xFFFEF2F2), borderColor: const Color(0xFFFECACA), iconBgColor: const Color(0xFFFEF2F2),
          ),
          _buildStandardStepCard(
            number: '6', action: 'PERHATIKAN ARAHAN PETUGAS',
            desc: 'Jika ada petugas, pengelola kawasan, atau aparat setempat, ikuti arahan mereka terkait harus tetap di lokasi atau segera bergerak.',
            icon: Icons.person_pin_circle_rounded,
            primaryColor: const Color(0xFFDC2626), lightBgColor: const Color(0xFFFEF2F2), borderColor: const Color(0xFFFECACA), iconBgColor: const Color(0xFFFEF2F2),
          ),
          _buildStandardStepCard(
            number: '7', action: 'JANGAN MENUNGGU DI TEPI LAUT',
            desc: 'Tidak perlu menunggu di tepi pantai untuk melihat perubahan air. Jika guncangan tidak biasa, lebih baik langsung menuju jalur evakuasi.',
            icon: Icons.hourglass_empty_rounded,
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
        cards: [          _buildStandardStepCard(
            number: '1', action: 'TETAP TENANG',
            desc: 'Saat guncangan terjadi, berusaha tetap tenang dan tidak berlari tanpa arah. Bergerak panik meningkatkan risiko terpeleset, jatuh, atau mendekati area bahaya.',
            icon: Icons.self_improvement_rounded,
            primaryColor: const Color(0xFF0284C7), lightBgColor: const Color(0xFFE0F2FE), borderColor: const Color(0xFFBAE6FD), iconBgColor: const Color(0xFFF0F9FF),
          ),
          _buildStandardStepCard(
            number: '2', action: 'JAGA POSISI DARI TEBING',
            desc: 'Jika terlalu dekat dengan tebing, lereng curam, atau jurang, menjauhlah dengan hati-hati. Menjaga jarak aman lebih disarankan daripada bergerak panik.',
            icon: Icons.social_distance_rounded,
            primaryColor: const Color(0xFF0284C7), lightBgColor: const Color(0xFFE0F2FE), borderColor: const Color(0xFFBAE6FD), iconBgColor: const Color(0xFFF0F9FF),
          ),
          _buildStandardStepCard(
            number: '3', action: 'HINDARI POHON BESAR',
            desc: 'Sebaiknya tidak berlindung di bawah pohon besar, batu besar, atau bagian tebing yang terlihat tidak stabil karena dapat jatuh atau bergeser.',
            icon: Icons.park_rounded,
            primaryColor: const Color(0xFF0284C7), lightBgColor: const Color(0xFFE0F2FE), borderColor: const Color(0xFFBAE6FD), iconBgColor: const Color(0xFFF0F9FF),
          ),
          _buildStandardStepCard(
            number: '4', action: 'CARI AREA DATAR',
            desc: 'Jika memungkinkan, berpindah ke area yang lebih datar dan terbuka. Area ini lebih aman dibandingkan tempat sempit, miring, atau dekat jurang.',
            icon: Icons.explore_rounded,
            primaryColor: const Color(0xFF0284C7), lightBgColor: const Color(0xFFE0F2FE), borderColor: const Color(0xFFBAE6FD), iconBgColor: const Color(0xFFF0F9FF),
          ),
          _buildStandardStepCard(
            number: '5', action: 'LINDUNGI KEPALA',
            desc: 'Jika ada ranting atau material kecil yang jatuh, lindungi kepala menggunakan tas, jaket, atau tangan untuk mengurangi risiko cedera.',
            icon: Icons.shield_rounded,
            primaryColor: const Color(0xFF0284C7), lightBgColor: const Color(0xFFE0F2FE), borderColor: const Color(0xFFBAE6FD), iconBgColor: const Color(0xFFF0F9FF),
          ),
          _buildStandardStepCard(
            number: '6', action: 'JAGA JARAK DARI RETAKAN',
            desc: 'Jika terlihat retakan tanah, jalan ambles, atau permukaan bergeser, menjauhlah secara perlahan. Jangan berdiri di atas permukaan tidak stabil.',
            icon: Icons.warning_amber_rounded,
            primaryColor: const Color(0xFF0284C7), lightBgColor: const Color(0xFFE0F2FE), borderColor: const Color(0xFFBAE6FD), iconBgColor: const Color(0xFFF0F9FF),
          ),
          _buildStandardStepCard(
            number: '7', action: 'PERHATIKAN SUARA ALAM',
            desc: 'Tingkatkan kewaspadaan jika terdengar suara batu bergeser atau pohon roboh, dan segera menjauh dari arah sumber suara tersebut.',
            icon: Icons.hearing_rounded,
            primaryColor: const Color(0xFF0284C7), lightBgColor: const Color(0xFFE0F2FE), borderColor: const Color(0xFFBAE6FD), iconBgColor: const Color(0xFFF0F9FF),
          ),],
      );
    } else if (locationCategory == 'Dalam Ruangan') {
      return _buildPremiumSliverView(
        context: context,
        headerTitle: 'PANDUAN SAAT GEMPA',
        title: 'Saat Gempa\ndi Dalam Ruangan',
        gradientColors: const [Color(0xFFFBBF24), Color(0xFFD97706)], // Amber/Yellow
        cards: [
          _buildStandardStepCard(
            number: '1', action: 'TETAP TENANG & BERHENTI',
            desc: 'Hentikan aktivitas dan berusaha tetap tenang. Jangan berlari keluar tanpa melihat sekitar karena benda jatuh atau panik dapat membahayakan.',
            icon: Icons.self_improvement_rounded,
            primaryColor: const Color(0xFFD97706), lightBgColor: const Color(0xFFFFFBEB), borderColor: const Color(0xFFFDE68A), iconBgColor: const Color(0xFFFFFBEB),
          ),
          _buildStandardStepCard(
            number: '2', action: 'BERLINDUNG DI TEMPAT AMAN',
            desc: 'Jika memungkinkan, berlindung di bawah meja kuat atau area jauh dari kaca, lemari, dan benda gantung untuk menghindari jatuhan benda.',
            icon: Icons.desk_rounded,
            primaryColor: const Color(0xFFD97706), lightBgColor: const Color(0xFFFFFBEB), borderColor: const Color(0xFFFDE68A), iconBgColor: const Color(0xFFFFFBEB),
          ),
          _buildStandardStepCard(
            number: '3', action: 'LINDUNGI KEPALA',
            desc: 'Jika tak ada meja, lindungi kepala dan leher dengan tas, bantal, jaket, atau tangan sebagai langkah dasar mengurangi cedera ringan.',
            icon: Icons.shield_rounded,
            primaryColor: const Color(0xFFD97706), lightBgColor: const Color(0xFFFFFBEB), borderColor: const Color(0xFFFDE68A), iconBgColor: const Color(0xFFFFFBEB),
          ),
          _buildStandardStepCard(
            number: '4', action: 'JAUHI KACA & RAK',
            desc: 'Jaga jarak dari jendela kaca, lemari, rak tinggi, televisi, lampu gantung, atau benda lain yang berisiko pecah dan jatuh.',
            icon: Icons.grid_view_rounded,
            primaryColor: const Color(0xFFD97706), lightBgColor: const Color(0xFFFFFBEB), borderColor: const Color(0xFFFDE68A), iconBgColor: const Color(0xFFFFFBEB),
          ),
          _buildStandardStepCard(
            number: '5', action: 'JANGAN GUNAKAN LIFT',
            desc: 'Di gedung bertingkat, lift tidak disarankan. Tetap berlindung sampai guncangan berhenti lalu gunakan tangga jika perlu evakuasi.',
            icon: Icons.elevator_rounded,
            primaryColor: const Color(0xFFD97706), lightBgColor: const Color(0xFFFFFBEB), borderColor: const Color(0xFFFDE68A), iconBgColor: const Color(0xFFFFFBEB),
          ),
          _buildStandardStepCard(
            number: '6', action: 'JANGAN DEKATI PINTU',
            desc: 'Tidak perlu memaksakan menuju pintu saat guncangan berlangsung jika posisinya dekat kaca atau lemari. Lebih aman di posisi perlindungan.',
            icon: Icons.door_front_door_rounded,
            primaryColor: const Color(0xFFD97706), lightBgColor: const Color(0xFFFFFBEB), borderColor: const Color(0xFFFDE68A), iconBgColor: const Color(0xFFFFFBEB),
          ),
          _buildStandardStepCard(
            number: '7', action: 'TUNGGU GUNCANGAN BERHENTI',
            desc: 'Tetap berada di posisi aman sampai guncangan mereda. Baru setelah itu tentukan apakah perlu keluar atau tetap menunggu.',
            icon: Icons.hourglass_bottom_rounded,
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
        gradientColors: const [Color(0xFFFB7185), Color(0xFFE65100)], // Rose/Pink
        cards: [
          _buildStandardStepCard(
            number: '1', action: 'TETAP TENANG & PERHATIKAN',
            desc: 'Berusaha tetap tenang dan lihat kondisi sekitar. Jangan langsung berlari tanpa arah agar tidak tersandung atau mendekati area berbahaya.',
            icon: Icons.self_improvement_rounded,
            primaryColor: const Color(0xFFE65100), lightBgColor: const Color(0xFFFFF8E1), borderColor: const Color(0xFFFECDD3), iconBgColor: const Color(0xFFFFF8E1),
          ),
          _buildStandardStepCard(
            number: '2', action: 'MENUJU AREA TERBUKA',
            desc: 'Bergerak perlahan menuju area terbuka jika memungkinkan. Berpindahlah dengan tenang dan terarah, bukan panik atau terburu-buru.',
            icon: Icons.directions_walk_rounded,
            primaryColor: const Color(0xFFE65100), lightBgColor: const Color(0xFFFFF8E1), borderColor: const Color(0xFFFECDD3), iconBgColor: const Color(0xFFFFF8E1),
          ),
          _buildStandardStepCard(
            number: '3', action: 'JAGA JARAK DARI BANGUNAN',
            desc: 'Menjauh dari gedung, tembok tinggi, pagar beton, atau bangunan rapuh untuk mengurangi risiko terkena material jika terjadi kerusakan.',
            icon: Icons.domain_disabled_rounded,
            primaryColor: const Color(0xFFE65100), lightBgColor: const Color(0xFFFFF8E1), borderColor: const Color(0xFFFECDD3), iconBgColor: const Color(0xFFFFF8E1),
          ),
          _buildStandardStepCard(
            number: '4', action: 'HINDARI TIANG DAN POHON',
            desc: 'Jangan berdiri di bawah tiang listrik, kabel, pohon besar, lampu, atau reklame karena berisiko bergeser, roboh, atau jatuh.',
            icon: Icons.warning_amber_rounded,
            primaryColor: const Color(0xFFE65100), lightBgColor: const Color(0xFFFFF8E1), borderColor: const Color(0xFFFECDD3), iconBgColor: const Color(0xFFFFF8E1),
          ),
          _buildStandardStepCard(
            number: '5', action: 'LINDUNGI KEPALA',
            desc: 'Jika ada risiko jatuh benda, lindungi kepala menggunakan tas, jaket, tangan, atau benda lain untuk mengurangi risiko cedera ringan.',
            icon: Icons.shield_rounded,
            primaryColor: const Color(0xFFE65100), lightBgColor: const Color(0xFFFFF8E1), borderColor: const Color(0xFFFECDD3), iconBgColor: const Color(0xFFFFF8E1),
          ),
          _buildStandardStepCard(
            number: '6', action: 'JANGAN DEKATI KACA',
            desc: 'Jaga jarak dari kaca dan etalase jika berada di dekat pertokoan atau gedung karena kaca rentan pecah akibat getaran.',
            icon: Icons.broken_image_rounded,
            primaryColor: const Color(0xFFE65100), lightBgColor: const Color(0xFFFFF8E1), borderColor: const Color(0xFFFECDD3), iconBgColor: const Color(0xFFFFF8E1),
          ),
          _buildStandardStepCard(
            number: '7', action: 'TUNGGU GUNCANGAN MEREDA',
            desc: 'Tetap berada di area aman sampai guncangan berhenti. Nilai kondisi sekitar sebelum melanjutkan aktivitas atau berpindah tempat.',
            icon: Icons.hourglass_bottom_rounded,
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
        title: 'Pasca Gempa\ndi Pesisir Pantai',
        gradientColors: const [Color(0xFF818CF8), Color(0xFF4F46E5)], // Deep Indigo
        cards: [
          _buildStandardStepCard(
            number: '1', action: 'PERHATIKAN KONDISI LAUT',
            desc: 'Setelah guncangan berhenti, perhatikan apakah air laut surut mendadak atau ada suara gemuruh. Jika ya, segera menjauh dari pantai.',
            icon: Icons.visibility_rounded,
            primaryColor: const Color(0xFF4F46E5), lightBgColor: const Color(0xFFEEF2FF), borderColor: const Color(0xFFE0E7FF), iconBgColor: const Color(0xFFEEF2FF),
          ),
          _buildStandardStepCard(
            number: '2', action: 'JANGAN KEMBALI KE PANTAI',
            desc: 'Sebaiknya tidak langsung kembali ke tepi pantai setelah gempa berhenti, karena bahaya lanjutan (seperti tsunami lokal) dapat terjadi.',
            icon: Icons.block_rounded,
            primaryColor: const Color(0xFF4F46E5), lightBgColor: const Color(0xFFEEF2FF), borderColor: const Color(0xFFE0E7FF), iconBgColor: const Color(0xFFEEF2FF),
          ),
          _buildStandardStepCard(
            number: '3', action: 'MENUJU TITIK AMAN',
            desc: 'Jika ada arahan petugas atau muncul tanda alami tsunami, segera menuju tempat lebih tinggi atau titik evakuasi terdekat dengan tertib.',
            icon: Icons.directions_run_rounded,
            primaryColor: const Color(0xFF4F46E5), lightBgColor: const Color(0xFFEEF2FF), borderColor: const Color(0xFFE0E7FF), iconBgColor: const Color(0xFFEEF2FF),
          ),
          _buildStandardStepCard(
            number: '4', action: 'PERIKSA KONDISI DIRI',
            desc: 'Pastikan diri Anda tidak terluka. Jika ada orang lain yang membutuhkan bantuan, bantu sesuai kemampuan tanpa membahayakan diri.',
            icon: Icons.health_and_safety_rounded,
            primaryColor: const Color(0xFF4F46E5), lightBgColor: const Color(0xFFEEF2FF), borderColor: const Color(0xFFE0E7FF), iconBgColor: const Color(0xFFEEF2FF),
          ),
          _buildStandardStepCard(
            number: '5', action: 'GUNAKAN KOMUNIKASI SEPERLUNYA',
            desc: 'Beri kabar ke orang terdekat dengan singkat bahwa Anda aman, agar jaringan tidak penuh dan bisa dipakai untuk darurat.',
            icon: Icons.contact_phone_rounded,
            primaryColor: const Color(0xFF4F46E5), lightBgColor: const Color(0xFFEEF2FF), borderColor: const Color(0xFFE0E7FF), iconBgColor: const Color(0xFFEEF2FF),
          ),
          _buildStandardStepCard(
            number: '6', action: 'PANTAU INFO RESMI',
            desc: 'Ikuti informasi dari BMKG, BNPB, atau BPBD. Jangan menyebarkan informasi tak jelas terkait tsunami atau gempa susulan.',
            icon: Icons.campaign_rounded,
            primaryColor: const Color(0xFF4F46E5), lightBgColor: const Color(0xFFEEF2FF), borderColor: const Color(0xFFE0E7FF), iconBgColor: const Color(0xFFEEF2FF),
          ),
          _buildStandardStepCard(
            number: '7', action: 'EVALUASI JALUR AMAN',
            desc: 'Setelah dinyatakan aman, evaluasi kembali jalur evakuasi dan titik kumpul yang diketahui untuk meningkatkan kesiapsiagaan kelak.',
            icon: Icons.fact_check_rounded,
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
        cards: [          _buildStandardStepCard(
            number: '1', action: 'TETAP DI TEMPAT AMAN',
            desc: 'Setelah guncangan berhenti, tidak disarankan langsung kembali ke area dekat tebing atau lereng curam. Tetaplah di tempat yang lebih aman.',
            icon: Icons.place_rounded,
            primaryColor: const Color(0xFF16A34A), lightBgColor: const Color(0xFFDCFCE7), borderColor: const Color(0xFF86EFAC), iconBgColor: const Color(0xFFF0FDF4),
          ),
          _buildStandardStepCard(
            number: '2', action: 'PERIKSA KONDISI JALUR',
            desc: 'Sebelum melanjutkan perjalanan, periksa apakah terdapat retakan tanah, batu berserakan, pohon tumbang, atau jalan yang tertutup material.',
            icon: Icons.fact_check_rounded,
            primaryColor: const Color(0xFF16A34A), lightBgColor: const Color(0xFFDCFCE7), borderColor: const Color(0xFF86EFAC), iconBgColor: const Color(0xFFF0FDF4),
          ),
          _buildStandardStepCard(
            number: '3', action: 'HINDARI AREA RUNTUHAN',
            desc: 'Jangan mendekati area yang baru saja mengalami batu jatuh atau tanah longsor kecil, karena ini menandakan lokasi masih belum stabil.',
            icon: Icons.block_rounded,
            primaryColor: const Color(0xFF16A34A), lightBgColor: const Color(0xFFDCFCE7), borderColor: const Color(0xFF86EFAC), iconBgColor: const Color(0xFFF0FDF4),
          ),
          _buildStandardStepCard(
            number: '4', action: 'PERIKSA KONDISI DIRI',
            desc: 'Pastikan diri tidak mengalami luka dan periksa orang di sekitar. Lakukan pertolongan sederhana dan hubungi petugas apabila diperlukan.',
            icon: Icons.health_and_safety_rounded,
            primaryColor: const Color(0xFF16A34A), lightBgColor: const Color(0xFFDCFCE7), borderColor: const Color(0xFF86EFAC), iconBgColor: const Color(0xFFF0FDF4),
          ),
          _buildStandardStepCard(
            number: '5', action: 'JANGAN MASUK BANGUNAN',
            desc: 'Jangan masuk ke pos pendakian, warung, atau bangunan yang terlihat retak/rusak. Tunggu sampai kondisi benar-benar dinyatakan aman.',
            icon: Icons.domain_disabled_rounded,
            primaryColor: const Color(0xFF16A34A), lightBgColor: const Color(0xFFDCFCE7), borderColor: const Color(0xFF86EFAC), iconBgColor: const Color(0xFFF0FDF4),
          ),
          _buildStandardStepCard(
            number: '6', action: 'GUNAKAN KOMUNIKASI BIJAK',
            desc: 'Gunakan komunikasi seperlunya untuk memberi kabar keluarga atau petugas, agar jaringan tetap tersedia untuk kondisi darurat.',
            icon: Icons.phone_android_rounded,
            primaryColor: const Color(0xFF16A34A), lightBgColor: const Color(0xFFDCFCE7), borderColor: const Color(0xFF86EFAC), iconBgColor: const Color(0xFFF0FDF4),
          ),
          _buildStandardStepCard(
            number: '7', action: 'IKUTI ARAHAN PETUGAS',
            desc: 'Pantau informasi dari BMKG, BNPB, atau petugas kawasan sebagai acuan untuk melanjutkan perjalanan atau tetap di titik aman.',
            icon: Icons.announcement_rounded,
            primaryColor: const Color(0xFF16A34A), lightBgColor: const Color(0xFFDCFCE7), borderColor: const Color(0xFF86EFAC), iconBgColor: const Color(0xFFF0FDF4),
          ),],
      );
    } else if (locationCategory == 'Dalam Ruangan') {
      return _buildPremiumSliverView(
        context: context,
        headerTitle: 'PANDUAN PASCA GEMPA',
        title: 'Pasca Gempa\ndi Dalam Ruangan',
        gradientColors: const [Color(0xFFA3E635), Color(0xFF65A30D)], // Lime/Olive Green
        cards: [
          _buildStandardStepCard(
            number: '1', action: 'PERIKSA KONDISI DIRI',
            desc: 'Periksa apakah ada luka. Jika mengalami cedera ringan, lakukan pertolongan sederhana sebelum berpindah ke tempat lain.',
            icon: Icons.health_and_safety_rounded,
            primaryColor: const Color(0xFF65A30D), lightBgColor: const Color(0xFFECFCCB), borderColor: const Color(0xFFD9F99D), iconBgColor: const Color(0xFFECFCCB),
          ),
          _buildStandardStepCard(
            number: '2', action: 'PERHATIKAN RUANGAN',
            desc: 'Lihat apakah ada kaca pecah, perabot bergeser, atau kabel terkelupas. Jangan berjalan cepat sebelum memastikan area cukup aman.',
            icon: Icons.visibility_rounded,
            primaryColor: const Color(0xFF65A30D), lightBgColor: const Color(0xFFECFCCB), borderColor: const Color(0xFFD9F99D), iconBgColor: const Color(0xFFECFCCB),
          ),
          _buildStandardStepCard(
            number: '3', action: 'KELUAR DENGAN TERTIB',
            desc: 'Tinggalkan ruangan dengan tertib jika terasa tak aman atau ada arahan. Hindari berlari atau berdesakan agar tidak panik tambahan.',
            icon: Icons.directions_walk_rounded,
            primaryColor: const Color(0xFF65A30D), lightBgColor: const Color(0xFFECFCCB), borderColor: const Color(0xFFD9F99D), iconBgColor: const Color(0xFFECFCCB),
          ),
          _buildStandardStepCard(
            number: '4', action: 'GUNAKAN TANGGA',
            desc: 'Jika perlu keluar dari gedung bertingkat, gunakan tangga dan hindari lift yang berisiko mengalami gangguan pasca guncangan.',
            icon: Icons.stairs_rounded,
            primaryColor: const Color(0xFF65A30D), lightBgColor: const Color(0xFFECFCCB), borderColor: const Color(0xFFD9F99D), iconBgColor: const Color(0xFFECFCCB),
          ),
          _buildStandardStepCard(
            number: '5', action: 'JAUHI BANGUNAN RUSAK',
            desc: 'Menjauh dari dinding retak, kaca pecah, plafon rusak, atau struktur tidak stabil. Kerusakan kecil pun tetap perlu diwaspadai.',
            icon: Icons.domain_disabled_rounded,
            primaryColor: const Color(0xFF65A30D), lightBgColor: const Color(0xFFECFCCB), borderColor: const Color(0xFFD9F99D), iconBgColor: const Color(0xFFECFCCB),
          ),
          _buildStandardStepCard(
            number: '6', action: 'HUBUNGI KELUARGA',
            desc: 'Beri kabar keluarga bahwa Anda aman. Gunakan komunikasi seperlunya agar jaringan tetap bisa digunakan oleh yang lebih darurat.',
            icon: Icons.contact_phone_rounded,
            primaryColor: const Color(0xFF65A30D), lightBgColor: const Color(0xFFECFCCB), borderColor: const Color(0xFFD9F99D), iconBgColor: const Color(0xFFECFCCB),
          ),
          _buildStandardStepCard(
            number: '7', action: 'PANTAU INFO RESMI',
            desc: 'Ikuti informasi resmi dari BMKG atau pemerintah daerah. Jangan sebar luaskan info tak jelas agar tidak memicu kepanikan.',
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
        title: 'Pasca Gempa\ndi Luar Ruangan',
        gradientColors: const [Color(0xFF94A3B8), Color(0xFF334155)], // Slate/Blue-Gray
        cards: [
          _buildStandardStepCard(
            number: '1', action: 'PERIKSA KONDISI DIRI',
            desc: 'Setelah guncangan berhenti, periksa apakah diri Anda terluka. Lakukan pertolongan sederhana jika ada luka ringan sebelum berpindah.',
            icon: Icons.health_and_safety_rounded,
            primaryColor: const Color(0xFF334155), lightBgColor: const Color(0xFFF8FAFC), borderColor: const Color(0xFFF1F5F9), iconBgColor: const Color(0xFFF8FAFC),
          ),
          _buildStandardStepCard(
            number: '2', action: 'AMATI KONDISI SEKITAR',
            desc: 'Perhatikan jika ada kabel jatuh, kaca pecah, pohon tumbang, atau benda berisiko jatuh. Jangan berjalan cepat sebelum memastikan jalur aman.',
            icon: Icons.visibility_rounded,
            primaryColor: const Color(0xFF334155), lightBgColor: const Color(0xFFF8FAFC), borderColor: const Color(0xFFF1F5F9), iconBgColor: const Color(0xFFF8FAFC),
          ),
          _buildStandardStepCard(
            number: '3', action: 'JAUHI BANGUNAN RUSAK',
            desc: 'Tetap menjaga jarak dari bangunan, tembok, atau papan reklame yang retak atau miring, karena kerusakan kecil tetap dapat membahayakan.',
            icon: Icons.domain_disabled_rounded,
            primaryColor: const Color(0xFF334155), lightBgColor: const Color(0xFFF8FAFC), borderColor: const Color(0xFFF1F5F9), iconBgColor: const Color(0xFFF8FAFC),
          ),
          _buildStandardStepCard(
            number: '4', action: 'BANTU ORANG SEKITAR',
            desc: 'Bantu menenangkan orang yang panik, menunjukkan area aman, atau menghubungi petugas tanpa membahayakan diri sendiri.',
            icon: Icons.volunteer_activism_rounded,
            primaryColor: const Color(0xFF334155), lightBgColor: const Color(0xFFF8FAFC), borderColor: const Color(0xFFF1F5F9), iconBgColor: const Color(0xFFF8FAFC),
          ),
          _buildStandardStepCard(
            number: '5', action: 'JANGAN MASUK GEDUNG',
            desc: 'Tidak disarankan langsung masuk gedung sebelum memastikan aman. Jika terpaksa, pastikan tidak ada retakan atau kaca pecah.',
            icon: Icons.do_not_step_rounded,
            primaryColor: const Color(0xFF334155), lightBgColor: const Color(0xFFF8FAFC), borderColor: const Color(0xFFF1F5F9), iconBgColor: const Color(0xFFF8FAFC),
          ),
          _buildStandardStepCard(
            number: '6', action: 'GUNAKAN KOMUNIKASI SEPERLUNYA',
            desc: 'Beri kabar keluarga secara singkat bahwa Anda aman. Gunakan komunikasi seperlunya agar jaringan tetap dapat diakses untuk darurat.',
            icon: Icons.contact_phone_rounded,
            primaryColor: const Color(0xFF334155), lightBgColor: const Color(0xFFF8FAFC), borderColor: const Color(0xFFF1F5F9), iconBgColor: const Color(0xFFF8FAFC),
          ),
          _buildStandardStepCard(
            number: '7', action: 'PANTAU INFORMASI RESMI',
            desc: 'Ikuti arahan dari BMKG, BNPB, atau pemerintah. Hindari menyebarkan informasi tak jelas yang dapat memicu kepanikan orang lain.',
            icon: Icons.campaign_rounded,
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
    required List<Color> gradientColors,
    required List<Widget> cards,
  }) {
    return Container(
      color: const Color(0xFFF1F5F9), // Modern Slate-100 background
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
                  'Zona Bahaya: $cityName',
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
                    child: Icon(Icons.landscape_rounded, size: 240, color: Colors.white.withValues(alpha: 0.15)),
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
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 16),
                              SizedBox(width: 8),
                              Text(
                                'Panduan Keselamatan',
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
                            letterSpacing: 0.5,
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
              offset: const Offset(0, -32),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 56, 24, 40),
                child: Column(
                  children: cards,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.06), // Sangat soft
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Watermark Icon raksasa di background (sangat transparan)
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                icon,
                size: 130,
                color: iconBgColor.withValues(alpha: 0.7),
              ),
            ),
            // Garis aksen vertikal di kiri
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 6,
                color: primaryColor,
              ),
            ),
            // Konten utama
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Badge Nomor
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: lightBgColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                number,
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Judul Aksi
                          Expanded(
                            child: Text(
                              action,
                              style: TextStyle(
                                color: primaryColor, // Menggunakan primaryColor untuk judul aksi
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Deskripsi (dibuat menjorok sejajar dengan teks judul)
                      Padding(
                        padding: const EdgeInsets.only(left: 56.0),
                        child: Text(
                          desc,
                          style: const TextStyle(
                            color: Color(0xFF475569),
                            fontSize: 14,
                            height: 1.6,
                          ),
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
}
