import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';
import 'main.dart';
import 'login.dart';
import 'services/api_config.dart';
import 'services/ml_service.dart';
import 'services/bmkg_service.dart';
import 'services/usgs_service.dart';
import 'edukasi_aman.dart';
import 'edukasi_waspada.dart';
import 'edukasi_bahaya.dart';

class KlasifikasiSeismikPage extends StatefulWidget {
  const KlasifikasiSeismikPage({super.key});

  @override
  State<KlasifikasiSeismikPage> createState() => _KlasifikasiSeismikPageState();
}

class _KlasifikasiSeismikPageState extends State<KlasifikasiSeismikPage> {
  final _formKey = GlobalKey<FormState>();
  final _magnitudoController = TextEditingController();
  final _kedalamanController = TextEditingController();
  final _lokasiController = TextEditingController();

  String? _hasilKlasifikasi;
  Color _warnaKlasifikasi = Colors.grey;
  String _deskripsiKlasifikasi = '';
  double? _hasilLatitude;
  double? _hasilLongitude;
  bool _isLoading = false;
  String _selectedSource = 'bmkg';

  // State baru untuk Otomatis vs Manual
  String _classificationMode = 'otomatis'; // 'otomatis' atau 'manual'
  GempaModel? _latestQuake;
  bool _isLoadingLatestQuake = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchLatestQuake();
  }

  @override
  void dispose() {
    _magnitudoController.dispose();
    _kedalamanController.dispose();
    _lokasiController.dispose();
    super.dispose();
  }

  Future<void> _fetchLatestQuake() async {
    if (!mounted) return;
    setState(() {
      _isLoadingLatestQuake = true;
      _latestQuake = null;
      _hasilKlasifikasi = null;
      _errorMessage = null;
    });

    try {
      GempaModel quake;
      if (_selectedSource == 'bmkg') {
        quake = await BmkgService.fetchLatestEarthquake();
      } else {
        final list = await UsgsService.fetchIndonesiaEarthquakes();
        if (list.isEmpty) {
          throw Exception('Tidak ada data gempa Indonesia dari USGS terbaru.');
        }
        quake = list.first;
      }

      if (!mounted) return;
      setState(() {
        _latestQuake = quake;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Gagal memuat data gempa. Periksa koneksi internet dan coba lagi.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLatestQuake = false;
        });
      }
    }
  }

  Future<void> _hitungKlasifikasi() async {
    double magnitudo;
    double kedalaman;
    String lokasi;
    double? latitude;
    double? longitude;

    if (_classificationMode == 'otomatis') {
      if (_latestQuake == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data gempa terbaru belum dimuat.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      try {
        magnitudo = double.parse(_latestQuake!.magnitude);
        String depthStr = _latestQuake!.kedalaman
            .replaceAll(' km', '')
            .replaceAll('km', '')
            .trim();
        kedalaman = double.parse(depthStr);
        lokasi = _latestQuake!.wilayah;

        // Ekstrak koordinat latitude dan longitude dari format "lat,lon"
        if (_latestQuake!.coordinates.contains(',')) {
          final parts = _latestQuake!.coordinates.split(',');
          if (parts.length == 2) {
            latitude = double.tryParse(parts[0].trim());
            longitude = double.tryParse(parts[1].trim());
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengekstrak data gempa: $e'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else {
      if (!_formKey.currentState!.validate()) return;
      FocusScope.of(context).unfocus();
      magnitudo = double.parse(
        _magnitudoController.text.replaceAll(',', '.'),
      );
      kedalaman = double.parse(
        _kedalamanController.text.replaceAll(',', '.'),
      );
      lokasi = _lokasiController.text.trim();
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Panggil Model Machine Learning via Backend API dengan menyertakan koordinat agar tidak geocoding gagal di backend
      final hasil = await MlService.predictRisk(
        magnitude: magnitudo,
        depth: kedalaman,
        locationName: lokasi,
        latitude: latitude,
        longitude: longitude,
        source: _selectedSource,
      );

      setState(() {
        _hasilKlasifikasi = hasil.riskLevel;
        _hasilLatitude = hasil.latitude;
        _hasilLongitude = hasil.longitude;

        if (hasil.riskLevel == 'Tinggi' || hasil.predictionCode == 2) {
          _warnaKlasifikasi = const Color(0xFFEF5350); // Red
          _deskripsiKlasifikasi =
              'Kerentanan seismik tinggi. Sangat berpotensi menimbulkan kerusakan struktural bangunan dan membahayakan keselamatan.';
        } else if (hasil.riskLevel == 'Sedang' || hasil.predictionCode == 1) {
          _warnaKlasifikasi = const Color(0xFFFFA726); // Orange
          _deskripsiKlasifikasi =
              'Kerentanan seismik sedang. Berpotensi menimbulkan kerusakan ringan hingga sedang pada bangunan.';
        } else {
          _warnaKlasifikasi = const Color(0xFF66BB6A); // Green
          _deskripsiKlasifikasi =
              'Kerentanan seismik rendah. Guncangan umumnya tidak menimbulkan kerusakan yang signifikan.';
        }
      });
    } catch (e) {
      if (!mounted) return;
      String errorMsg = e.toString().replaceAll('Exception: ', '').trim();
      // Deteksi jika server backend tidak aktif, timeout, atau proxy bermasalah
      if (errorMsg.contains('connection') ||
          errorMsg.contains('refused') ||
          errorMsg.contains('SocketException') ||
          errorMsg.contains('10061') ||
          errorMsg.contains('HttpException') ||
          errorMsg.contains('Connection refused') ||
          errorMsg.contains('timeout') ||
          errorMsg.contains('504') ||
          errorMsg.contains('502') ||
          errorMsg.contains('503') ||
          errorMsg.contains('Gateway') ||
          errorMsg.contains('html') ||
          errorMsg.contains('offline') ||
          errorMsg.contains('sibuk') ||
          errorMsg.contains('Batas waktu') ||
          errorMsg.contains('koneksi')) {
        errorMsg =
            'Gagal terhubung ke server kecerdasan buatan (SVM). Pastikan backend Anda sudah aktif di port 8000.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildLatestQuakeCard() {
    if (_isLoadingLatestQuake) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(
                  color: Color(0xFF1E88E5),
                  strokeWidth: 3,
                ),
                SizedBox(height: 16),
                Text(
                  'Mengambil data gempa terkini...',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_latestQuake == null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                const Text(
                  'Gagal memuat data gempa bumi terkini.',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _fetchLatestQuake,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final quake = _latestQuake!;
    final String sourceLabel = _selectedSource == 'bmkg' ? 'BMKG' : 'USGS';

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Data Gempa Terkini',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 18, color: Color(0xFF1E88E5)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: _fetchLatestQuake,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF90CAF9).withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          sourceLabel,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1565C0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24, color: Color(0xFFEEEEEE)),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Magnitude',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF888888),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${quake.magnitude} SR',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFEF5350),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: const Color(0xFFEEEEEE),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kedalaman',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF888888),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          quake.kedalaman,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFFFA726),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, size: 18, color: Color(0xFF66BB6A)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Wilayah / Lokasi',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF888888),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          quake.wilayah,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.access_time, size: 18, color: Color(0xFF78909C)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Waktu Kejadian',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF888888),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${quake.tanggal}, ${quake.jam}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF555555),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _hitungKlasifikasi,
                  icon: const Icon(Icons.psychology, color: Colors.white),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  label: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Klasifikasikan Otomatis (SVM)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMitigasiSection() {
    if (_hasilKlasifikasi == null) return const SizedBox.shrink();

    String sebelum = '';
    String saat = '';
    String setelah = '';

    if (_hasilKlasifikasi == 'Tinggi') {
      sebelum = 'Identifikasi jalur evakuasi utama, lakukan simulasi berkala, dan ketahui titik kumpul terdekat di lingkungan Anda.';
      saat = 'Segera evakuasi diri ke luar ruangan apabila struktur bangunan mulai retak. Jauhi jendela kaca dan instalasi listrik.';
      setelah = 'Evakuasi ke titik kumpul terbuka. Periksa kebocoran gas/korsleting listrik, dan segera hubungi tim medis jika ada korban.';
    } else if (_hasilKlasifikasi == 'Sedang') {
      sebelum = 'Pastikan struktur bangunan diperkuat, siapkan tas siaga bencana (surat penting, air, makanan), catat nomor darurat.';
      saat = 'Lindungi kepala dari jatuhan reruntuhan menggunakan helm atau bantal. Jika tidak sempat keluar, cari meja kokoh.';
      setelah = 'Waspadai gempa susulan. Jauhi dinding retak, tiang listrik, dan kaca yang rentan pecah.';
    } else {
      // Rendah
      sebelum = 'Kenali tempat aman di rumah, atur furnitur berat di bawah, dan ketahui letak kotak P3K.';
      saat = 'Jangan panik. Tetap tenang, matikan kompor, dan cari perlindungan di bawah meja kokoh jika getaran terasa.';
      setelah = 'Periksa jika ada barang jatuh atau luka kecil secara tenang, dan tetap update info resmi dari BMKG.';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            Icon(Icons.shield_outlined, color: _warnaKlasifikasi, size: 24),
            const SizedBox(width: 8),
            Text(
              'Rekomendasi Tindakan Mitigasi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _warnaKlasifikasi,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildMitigasiCard(
          title: 'SEBELUM GEMPA (Siaga Bencana)',
          content: sebelum,
          icon: Icons.health_and_safety_outlined,
          color: _warnaKlasifikasi,
        ),
        const SizedBox(height: 12),
        _buildMitigasiCard(
          title: 'SAAT TERJADI GEMPA (Aksi Penyelamatan)',
          content: saat,
          icon: Icons.run_circle_outlined,
          color: _warnaKlasifikasi,
        ),
        const SizedBox(height: 12),
        _buildMitigasiCard(
          title: 'SETELAH GEMPA (Evakuasi & Keamanan)',
          content: setelah,
          icon: Icons.assistant_direction_outlined,
          color: _warnaKlasifikasi,
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () {
              final String lokasi = _classificationMode == 'otomatis' && _latestQuake != null
                  ? _latestQuake!.wilayah
                  : _lokasiController.text.trim();
              
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    if (_hasilKlasifikasi == 'Tinggi') {
                      return EdukasiBahayaPage(
                        cityName: lokasi,
                        locationCategory: 'Dalam Ruangan',
                      );
                    } else if (_hasilKlasifikasi == 'Sedang') {
                      return EdukasiWaspadaPage(
                        cityName: lokasi,
                        locationCategory: 'Dalam Ruangan',
                      );
                    } else {
                      return EdukasiAmanPage(
                        cityName: lokasi,
                        locationCategory: 'Dalam Ruangan',
                      );
                    }
                  },
                ),
              );
            },
            icon: const Icon(Icons.menu_book_rounded, color: Colors.white),
            style: ElevatedButton.styleFrom(
              backgroundColor: _warnaKlasifikasi,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            label: const Text(
              'Detail Panduan Keselamatan Lengkap',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMitigasiCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: color,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      content,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF424242),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadDataset(String filename) async {
    final String urlString = '${ApiConfig.baseUrl}/download-dataset?filename=$filename';
    final Uri url = Uri.parse(urlString);
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak dapat mengunduh file $filename. Silakan coba beberapa saat lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan saat mengunduh: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildDatasetSection() {
    return ValueListenableBuilder<bool>(
      valueListenable: isLoggedInNotifier,
      builder: (context, isLoggedIn, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F7FA),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.folder_zip_rounded,
                          color: Color(0xFF00ACC1),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Dataset Training SVM',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Unduh data riwayat gempa bumi pendukung BMKG & USGS.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF757575),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (!isLoggedIn) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.lock_outline_rounded, color: Colors.amber, size: 20),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Fitur Khusus Anggota',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF7F5F00),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Anda perlu masuk atau mendaftar terlebih dahulu untuk mengunduh dataset pelatihan SVM.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF7F5F00),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LoginPage()),
                                );
                              },
                              icon: const Icon(Icons.login_rounded, size: 16, color: Colors.white),
                              label: const Text(
                                'Masuk ke Akun',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E88E5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    _buildExpandableDatasetGroup(
                      title: 'Dataset BMKG (Lokal)',
                      icon: Icons.location_on_rounded,
                      color: const Color(0xFF1E88E5),
                      files: [
                        {'name': '2008-2012.csv', 'size': '1.9 MB'},
                        {'name': '2013-2017.csv', 'size': '2.5 MB'},
                        {'name': '2018-2022.csv', 'size': '4.8 MB'},
                        {'name': '2023-2025.csv', 'size': '3.4 MB'},
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildExpandableDatasetGroup(
                      title: 'Dataset USGS (Global)',
                      icon: Icons.public_rounded,
                      color: const Color(0xFF7E57C2),
                      files: [
                        {'name': '1990-1994.csv', 'size': '658 KB'},
                        {'name': '1995-1999.csv', 'size': '1.1 MB'},
                        {'name': '2000-2004.csv', 'size': '1.1 MB'},
                        {'name': '2005-2009.csv', 'size': '2.2 MB'},
                        {'name': '2010-2014.csv', 'size': '1.4 MB'},
                        {'name': '2015-2019.csv', 'size': '1.8 MB'},
                        {'name': '2020-2026.csv', 'size': '2.3 MB'},
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpandableDatasetGroup({
    required String title,
    required IconData icon,
    required Color color,
    required List<Map<String, String>> files,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: files.map((file) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
              ),
              color: Colors.white,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                dense: true,
                leading: const Icon(Icons.insert_drive_file_outlined, color: Colors.grey, size: 20),
                title: Text(
                  file['name']!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                subtitle: Text(
                  file['size']!,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.download_rounded, color: Color(0xFF1E88E5), size: 20),
                  onPressed: () => _downloadDataset(file['name']!),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan tampilan error jika dalam mode otomatis dan data gagal dimuat
    if (_classificationMode == 'otomatis' && _errorMessage != null && _latestQuake == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text('Klasifikasi Kerentanan Seismik'),
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.signal_wifi_off_rounded, size: 72, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF424242),
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _errorMessage = null;
                      _isLoadingLatestQuake = true;
                    });
                    _fetchLatestQuake();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BCD4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: const Text(
                    'Muat Ulang',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Klasifikasi Kerentanan Seismik'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Color(0xFF1A1A1A),
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // SVM Header Card
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF90CAF9).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.memory,
                          color: Color(0xFF1976D2),
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Support Vector Machine (SVM)',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1565C0),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Model memproses data magnitudo, kedalaman, dan episenter secara otomatis menganalisis pola spatial gempabumi.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF1E88E5),
                                  height: 1.4,
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
              const SizedBox(height: 20),

              // Mode Selector
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (_classificationMode != 'otomatis') {
                            setState(() {
                              _classificationMode = 'otomatis';
                              _hasilKlasifikasi = null;
                            });
                            _fetchLatestQuake();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _classificationMode == 'otomatis'
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: _classificationMode == 'otomatis'
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  size: 16,
                                  color: _classificationMode == 'otomatis'
                                      ? const Color(0xFF1E88E5)
                                      : const Color(0xFF616161),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Otomatis',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: _classificationMode == 'otomatis'
                                        ? const Color(0xFF1E88E5)
                                        : const Color(0xFF616161),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (_classificationMode != 'manual') {
                            setState(() {
                              _classificationMode = 'manual';
                              _hasilKlasifikasi = null;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _classificationMode == 'manual'
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: _classificationMode == 'manual'
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.edit_note,
                                  size: 18,
                                  color: _classificationMode == 'manual'
                                      ? const Color(0xFF1E88E5)
                                      : const Color(0xFF616161),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Input Manual',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: _classificationMode == 'manual'
                                        ? const Color(0xFF1E88E5)
                                        : const Color(0xFF616161),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Source Selector (Always visible or inside specific sections, let's keep it clean)
              AnimatedCrossFade(
                firstChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedSource,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: 'Sumber Data Gempa',
                              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              prefixIcon: const Icon(
                                Icons.source,
                                color: Color(0xFF7E57C2),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'bmkg',
                                child: Text(
                                  'BMKG (Lokal)',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'usgs',
                                child: Text(
                                  'USGS (Global)',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedSource = value;
                                });
                                _fetchLatestQuake();
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildLatestQuakeCard(),
                  ],
                ),
                secondChild: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Parameter Gempa',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedSource,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: 'Sumber Data Model',
                                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                prefixIcon: const Icon(
                                  Icons.source,
                                  color: Color(0xFF7E57C2),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'bmkg',
                                  child: Text(
                                    'BMKG (Lokal - 98.7%)',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'usgs',
                                  child: Text(
                                    'USGS (Global - 97.4%)',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedSource = value;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _magnitudoController,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              decoration: InputDecoration(
                                labelText: 'Magnitudo',
                                labelStyle: const TextStyle(fontWeight: FontWeight.w500),
                                hintText: 'Contoh: 5.6',
                                prefixIcon: const Icon(
                                  Icons.waves,
                                  color: Color(0xFF42A5F5),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Harap masukkan magnitudo';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _kedalamanController,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              decoration: InputDecoration(
                                labelText: 'Kedalaman (km)',
                                labelStyle: const TextStyle(fontWeight: FontWeight.w500),
                                hintText: 'Contoh: 30',
                                prefixIcon: const Icon(
                                  Icons.arrow_downward,
                                  color: Color(0xFFEF5350),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Harap masukkan kedalaman';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _lokasiController,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              decoration: InputDecoration(
                                labelText: 'Nama Daerah / Lokasi',
                                labelStyle: const TextStyle(fontWeight: FontWeight.w500),
                                hintText: 'Contoh: Lembang, Bandung, Cianjur',
                                prefixIcon: const Icon(
                                  Icons.location_on,
                                  color: Color(0xFF66BB6A),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Harap masukkan nama daerah atau lokasi';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _hitungKlasifikasi,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E88E5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Text(
                                        'Klasifikasikan (SVM)',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                crossFadeState: _classificationMode == 'otomatis'
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 350),
                firstCurve: Curves.easeInOut,
                secondCurve: Curves.easeInOut,
                sizeCurve: Curves.easeInOut,
              ),
              const SizedBox(height: 20),

              // Hasil Klasifikasi & Panduan Mitigasi Bencana
              if (_hasilKlasifikasi != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: _warnaKlasifikasi.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _warnaKlasifikasi.withValues(alpha: 0.45), width: 2.0),
                        boxShadow: [
                          BoxShadow(
                            color: _warnaKlasifikasi.withValues(alpha: 0.15),
                            blurRadius: 25,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _warnaKlasifikasi.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.analytics_rounded, color: _warnaKlasifikasi, size: 56),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Hasil Prediksi Kerentanan Seismik',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                              color: Color(0xFF666666),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _hasilKlasifikasi!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                              color: _warnaKlasifikasi,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_hasilLatitude != null && _hasilLongitude != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                'Episentrum: ${_hasilLatitude!.toStringAsFixed(4)} LU/LS, ${_hasilLongitude!.toStringAsFixed(4)} BT/BB',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF444444),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          Text(
                            _deskripsiKlasifikasi,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF333333),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildMitigasiSection(),
              ],
              const SizedBox(height: 20),
              _buildDatasetSection(),
            ],
          ),
        ),
      ),
    );
  }
}
