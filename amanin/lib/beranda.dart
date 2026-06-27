import 'package:flutter/material.dart';
import 'panduan_fitur.dart';
import 'deteksi_lingkungan.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'gempa_detail.dart';
import 'utils/earthquake_map.dart';
import 'utils/map_utils.dart';
import 'fullscreen_map.dart';
import 'cuaca.dart';
import 'edukasi_bahaya.dart';
import 'edukasi_waspada.dart';
import 'edukasi_aman.dart';
import 'panduan_evakuasi_bahaya.dart';
import 'panduan_evakuasi_waspada.dart';
import 'panduan_evakuasi_aman.dart';
import 'akun.dart';
import 'fitur.dart';
import 'login.dart';
import 'utils/localization.dart';
import 'main.dart'; // For isLoggedInNotifier
import 'toko.dart';
import 'asuransi.dart';
import 'services/bmkg_service.dart';
import 'services/anomali_service.dart';
import 'services/news_service.dart';
import 'isi_berita.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'dart:math' as math;

class BerandaPage extends StatefulWidget {
  final VoidCallback? onNavigateToCuaca;
  final GlobalKey? bottomNavKey;
  const BerandaPage({super.key, this.onNavigateToCuaca, this.bottomNavKey});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  LatLng _earthquakeLocation = const LatLng(-8.8, 115.0);
  GempaModel? _latestQuake;
  bool _isLoadingQuake = true;
  bool _isLatestQuakeAnomali = false;

  CuacaModel? _latestCuaca;
  bool _isLoadingCuaca = true;

  List<NewsModel> _newsList = [];
  bool _isLoadingNews = true;

  String _currentCityName = 'Memuat lokasi...';

  bool _isIndoor = true;
  String _environmentType = 'Pesisir Pantai';
  String _nearbyMountainName = '';

  bool _showHelpTour = false;
  int _helpTourStep = 1;
  final GlobalKey _chipsKey = GlobalKey();
  final GlobalKey _mapCardKey = GlobalKey();
  final GlobalKey _survivalKitKey = GlobalKey();
  final GlobalKey _weatherKey = GlobalKey();
  final GlobalKey _earlyWarningKey = GlobalKey();
  final GlobalKey _newsKey = GlobalKey();
  final GlobalKey _insuranceKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Memanggil dialog persetujuan setelah frame pertama selesai dirender
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showLocationPermissionDialog();
    });
    _fetchEarthquakeData();
    _fetchWeatherData();
    _fetchNewsData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Fungsi untuk memunculkan popup konfirmasi lokasi setiap kali aplikasi dibuka/restart
  Future<void> _showLocationPermissionDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false, // User wajib memilih salah satu tombol
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 320),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFFE0F7FA), Colors.white],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00BCD4).withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Radar circular Location Icon (styled like Gempabumi warning dialog)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const LocationWaveWidget(isLeft: true),
                    const SizedBox(width: 10),
                    // Outer soft cyan ring
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE0F7FA),
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF00BCD4), Color(0xFF1E88E5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const LocationWaveWidget(isLeft: false),
                  ],
                ),
                const SizedBox(height: 16),
                // Title
                const Text(
                  'Akses Lokasi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A), // Slate 900
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                // Description
                const Text(
                  'Amanin memerlukan akses lokasi perangkat Anda untuk menampilkan informasi cuaca dan gempa bumi terdekat secara akurat.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF475569), // Slate 600
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),
                // Action Buttons
                Row(
                  children: [
                    // Tolak Button
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          foregroundColor: const Color(0xFF64748B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          setState(() {
                            _currentCityName =
                                'Lokasi ditolak (Default Bojongsoang)';
                          });
                          userCityNameNotifier.value = 'Bojongsoang';
                        },
                        child: const Text(
                          'Tolak',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Izinkan Button (Gradient style)
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00BCD4), Color(0xFF1E88E5)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF1E88E5,
                              ).withValues(alpha: 0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () async {
                            Navigator.of(dialogContext).pop();

                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (c) => const Center(
                                child: CircularProgressIndicator(color: Colors.white),
                              ),
                            );

                            await _requestLocationPermission();

                            if (!mounted) return;
                            Navigator.of(context).pop();

                            // Tampilkan popup peringatan gempa setelah izin lokasi dan status lingkungan didapatkan
                            _showEarthquakeAmanDialog();
                          },
                          child: const Text(
                            'Izinkan',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Popup peringatan gempa bumi setelah lokasi diizinkan
  void _showEarthquakeWarningDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 340),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Gempabumi (lingkaran merah dengan ikon bangunan + gelombang getaran)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const VibrationWaveWidget(isLeft: true),
                    const SizedBox(width: 10),
                    // Outer light pink circle
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFDE8E8),
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE53935),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.domain_disabled_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const VibrationWaveWidget(isLeft: false),
                  ],
                ),
                const SizedBox(height: 16),

                // Judul "Gempabumi"
                const Text(
                  'Gempabumi',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),

                // Badge "Kelas Bahaya Tinggi"
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE8E8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        color: Color(0xFFE53935),
                        size: 14,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Kelas Bahaya Tinggi',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE53935),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Deskripsi
                const Text(
                  'Wilayahmu memiliki potensi bahaya gempa bumi yang perlu diwaspadai.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4B5563),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),

                // Info Box (Pink background)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE8E8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.info_outline_rounded,
                          color: Color(0xFFE53935),
                          size: 16,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Rekomendasi edukasi disesuaikan dengan kondisi bahaya gempa di wilayahmu.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF1F2937),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Status Lingkungan
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isIndoor ? Icons.home_rounded : Icons.wb_sunny_rounded,
                        color: _isIndoor ? const Color(0xFFE65100) : const Color(0xFF1B5E20),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isIndoor ? 'Dalam Ruangan' : 'Luar Ruangan',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _isIndoor ? const Color(0xFFE65100) : const Color(0xFF1B5E20),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        _environmentType == 'Pegunungan'
                            ? Icons.terrain_rounded
                            : _environmentType == 'Pantai'
                            ? Icons.beach_access_rounded
                            : Icons.location_city_rounded,
                        color: const Color(0xFF4B5563),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _environmentType == 'Pegunungan'
                              ? (_nearbyMountainName.isNotEmpty ? 'Dekat $_nearbyMountainName' : 'Pegunungan')
                              : _environmentType == 'Pantai'
                              ? 'Pesisir Pantai'
                              : 'Perkotaan',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4B5563),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Status Box
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.monitor_heart,
                        color: Color(0xFFE53935),
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Status:',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                      Spacer(),
                      Text(
                        'Bahaya',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE53935),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Tombol "Lihat Edukasi" (Solid Blue)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            String locCat = 'Dalam Ruangan';
                            if (_environmentType.contains('Pantai') || _environmentType.contains('Pesisir')) {
                              locCat = 'Pesisir Pantai';
                            } else if (_environmentType.contains('Gunung') || _environmentType.contains('Pegunungan')) {
                              locCat = 'Pegunungan';
                            } else {
                              locCat = _isIndoor ? 'Dalam Ruangan' : 'Luar Ruangan';
                            }
                            return EdukasiBahayaPage(
                              cityName: _currentCityName,
                              locationCategory: locCat,
                            );
                          },
                        ),
                      );
                    },
                    icon: const Icon(Icons.menu_book_rounded, size: 18),
                    label: const Text(
                      'Lihat Edukasi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Tombol "Tutup" (Outline Blue)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1E88E5),
                      side: const BorderSide(
                        color: Color(0xFF1E88E5),
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Tutup',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEarthquakeWaspadaDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 340),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Gempabumi (lingkaran merah dengan ikon bangunan + gelombang getaran)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const VibrationWaveWidget(isLeft: true),
                    const SizedBox(width: 10),
                    // Outer light pink circle
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF8E1),
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFBC02D),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.domain_disabled_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const VibrationWaveWidget(isLeft: false),
                  ],
                ),
                const SizedBox(height: 16),

                // Judul "Gempabumi"
                const Text(
                  'Gempabumi',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),

                // Badge "Kelas Bahaya Sedang"
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        color: Color(0xFFFBC02D),
                        size: 14,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Kelas Bahaya Sedang',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFBC02D),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Deskripsi
                const Text(
                  'Wilayahmu memiliki potensi bahaya gempa bumi yang perlu diwaspadai.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4B5563),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),

                // Info Box (Pink background)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.info_outline_rounded,
                          color: Color(0xFFFBC02D),
                          size: 16,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Rekomendasi edukasi disesuaikan dengan kondisi bahaya gempa di wilayahmu.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF1F2937),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Status Lingkungan
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isIndoor ? Icons.home_rounded : Icons.wb_sunny_rounded,
                        color: _isIndoor ? const Color(0xFFE65100) : const Color(0xFF1B5E20),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isIndoor ? 'Dalam Ruangan' : 'Luar Ruangan',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _isIndoor ? const Color(0xFFE65100) : const Color(0xFF1B5E20),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        _environmentType == 'Pegunungan'
                            ? Icons.terrain_rounded
                            : _environmentType == 'Pantai'
                            ? Icons.beach_access_rounded
                            : Icons.location_city_rounded,
                        color: const Color(0xFF4B5563),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _environmentType == 'Pegunungan'
                              ? (_nearbyMountainName.isNotEmpty ? 'Dekat $_nearbyMountainName' : 'Pegunungan')
                              : _environmentType == 'Pantai'
                              ? 'Pesisir Pantai'
                              : 'Perkotaan',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4B5563),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Status Box
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.monitor_heart,
                        color: Color(0xFFFBC02D),
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Status:',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                      Spacer(),
                      Text(
                        'Waspada',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFBC02D),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Tombol "Lihat Edukasi" (Solid Blue)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            String locCat = 'Dalam Ruangan';
                            if (_environmentType.contains('Pantai') || _environmentType.contains('Pesisir')) {
                              locCat = 'Pesisir Pantai';
                            } else if (_environmentType.contains('Gunung') || _environmentType.contains('Pegunungan')) {
                              locCat = 'Pegunungan';
                            } else {
                              locCat = _isIndoor ? 'Dalam Ruangan' : 'Luar Ruangan';
                            }
                            return EdukasiWaspadaPage(
                              cityName: _currentCityName,
                              locationCategory: locCat,
                            );
                          },
                        ),
                      );
                    },
                    icon: const Icon(Icons.menu_book_rounded, size: 18),
                    label: const Text(
                      'Lihat Edukasi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Tombol "Tutup" (Outline Blue)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1E88E5),
                      side: const BorderSide(
                        color: Color(0xFF1E88E5),
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Tutup',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _requestLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      ).timeout(const Duration(seconds: 3), onTimeout: () {
        return Position(
          latitude: -6.9559, // default Bojongsoang
          longitude: 107.6499,
          timestamp: DateTime.now(),
          accuracy: 10000.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );
      });

      print(
        "[Beranda] GPS coordinates: lat=${position.latitude}, lon=${position.longitude}, accuracy=${position.accuracy}m",
      );

      String cityName = 'Jakarta Pusat';
      String fullAddr = '';
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(const Duration(seconds: 2));
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          print(
            "[Beranda] Geocoding result: subLocality=${place.subLocality}, locality=${place.locality}, subAdmin=${place.subAdministrativeArea}, admin=${place.administrativeArea}",
          );
          cityName =
              place.locality ??
              place.subLocality ??
              place.subAdministrativeArea ??
              'Jakarta Pusat';
          cityName = cityName
              .replaceAll('Kabupaten ', '')
              .replaceAll('Kota ', '')
              .replaceAll(' City', '')
              .replaceAll('Kecamatan ', '')
              .replaceAll('Kelurahan ', '')
              .replaceAll('Desa ', '');
          fullAddr =
              '${place.name} ${place.street} ${place.subLocality} ${place.locality} ${place.subAdministrativeArea} ${place.administrativeArea}';
        }
      } catch (e) {
        print(
          "[Beranda] Geocoding package error: $e, falling back to Nominatim",
        );
        // Fallback for Web using OpenStreetMap Nominatim API
        try {
          final url = Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=16&addressdetails=1',
          );
          final response = await http.get(
            url,
            headers: {'User-Agent': 'AmaninApp/1.0'},
          ).timeout(const Duration(seconds: 3));
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            print("[Beranda] Nominatim full address: ${data['address']}");
            fullAddr = data['display_name'] ?? '';
            if (data['address'] != null) {
              final addr = data['address'];
              cityName =
                  addr['town'] ??
                  addr['subdistrict'] ??
                  addr['suburb'] ??
                  addr['city_district'] ??
                  addr['city'] ??
                  addr['county'] ??
                  addr['state'] ??
                  'Jakarta Pusat';
              cityName = cityName
                  .replaceAll('Kabupaten ', '')
                  .replaceAll('Kota ', '')
                  .replaceAll(' City', '')
                  .replaceAll('Kecamatan ', '')
                  .replaceAll('Kelurahan ', '')
                  .replaceAll('Desa ', '');
              print("[Beranda] Final city name: $cityName");
            }
          }
        } catch (fallbackError) {
          print("Nominatim fallback error: $fallbackError");
        }
      }

      if (mounted) {
        setState(() {
          _currentCityName = cityName;
        });
        userCityNameNotifier.value = cityName;
        _determineUserEnvironment(position, fullAddr);
      }
    } catch (e) {
      print("Location permission error: $e");
    }
  }

  void _determineUserEnvironment(Position position, String fullAddress) {
    final result = EnvironmentDetector.determineEnvironment(
      position.latitude,
      position.longitude,
      position.accuracy,
      fullAddress,
    );

    if (mounted) {
      setState(() {
        _isIndoor = true; // FORCE INDOOR FOR TESTING
        _environmentType = 'Perkotaan'; // FORCE PERKOTAAN FOR TESTING
        _nearbyMountainName = result.nearbyMountainName;
      });
    }
  }

  Future<void> _fetchEarthquakeData() async {
    try {
      final quake = await BmkgService.fetchLatestEarthquake();

      // Hitung parameter untuk Anomali
      double mag = double.tryParse(quake.magnitude) ?? 0.0;
      double depth =
          double.tryParse(quake.kedalaman.replaceAll(RegExp(r'[^0-9.]'), '')) ??
          0.0;
      double lat = 0.0;
      double lon = 0.0;

      if (quake.coordinates.isNotEmpty) {
        final coords = quake.coordinates.split(',');
        if (coords.length == 2) {
          lat = double.tryParse(coords[0]) ?? 0.0;
          lon = double.tryParse(coords[1]) ?? 0.0;
        }
      }

      // Jalankan pengecekan AI secara diam-diam
      final bool isAnomali = await AnomaliService.checkSingleAnomali(
        magnitude: mag,
        kedalaman: depth,
        lintang: lat,
        bujur: lon,
      );

      if (mounted) {
        setState(() {
          _latestQuake = quake;
          _isLatestQuakeAnomali = isAnomali;
          if (lat != 0.0 && lon != 0.0) {
            _earthquakeLocation = LatLng(lat, lon);
          }
          _isLoadingQuake = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingQuake = false;
        });
        print("Error fetching earthquake: $e");
      }
    }
  }

  Future<void> _fetchWeatherData() async {
    try {
      final cuaca = await BmkgService.fetchCurrentWeather(
        '32.04.08.2002',
      ); // Bojongsoang
      if (mounted) {
        setState(() {
          _latestCuaca = cuaca;
          _isLoadingCuaca = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCuaca = false;
        });
        print("Error fetching weather: $e");
      }
    }
  }

  Future<void> _fetchNewsData() async {
    try {
      final news = await NewsService.fetchNews();
      if (mounted) {
        setState(() {
          _newsList = news;
          _isLoadingNews = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingNews = false;
        });
        print("Error fetching news: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    _buildHeader(),
                    const SizedBox(height: 24),

                    // Compact Earthquake Warning Banner
                    _buildEarthquakeWarningBanner(),
                    const SizedBox(height: 16),

                    // Earthquake Status Section
                    _buildEarthquakeStatus(),
                    const SizedBox(height: 16),

                    // Merged Earthquake Card
                    _buildEarthquakeCard(),
                    const SizedBox(height: 20),

                    // Environment Status Card
                    _buildEnvironmentStatusCard(),
                    const SizedBox(height: 24),

                    // Survival Kit Card
                    _buildSurvivalKitSection(),
                    const SizedBox(height: 24),

                    // Weather Card
                    _buildWeatherCard(),
                    const SizedBox(height: 16),

                    // Early Warning Card
                    _buildEarlyWarningCard(),
                    const SizedBox(height: 24),

                    // News Section
                    _buildNewsSection(),
                    const SizedBox(height: 24),

                    // Asuransi Section
                    _buildInsuranceSection(),
                    const SizedBox(height: 24),

                    // Fitur Section (Di Bawah)
                    _buildFiturTambahanSection(),
                    const SizedBox(
                      height: 140,
                    ), // padding for floating bottom nav
                  ],
                ),
              ),
            ),
          ),
          if (_showHelpTour)
            AnimatedBuilder(
              animation: _scrollController,
              builder: (context, child) {
                final chipsRect = _getWidgetRect(_chipsKey);
                final mapCardRect = _getWidgetRect(_mapCardKey);
                final survivalKitRect = _getWidgetRect(_survivalKitKey);
                final weatherRect = _getWidgetRect(_weatherKey);
                final earlyWarningRect = _getWidgetRect(_earlyWarningKey);
                final newsRect = _getWidgetRect(_newsKey);
                final insuranceRect = _getWidgetRect(_insuranceKey);
                final bottomNavRect = widget.bottomNavKey != null
                    ? _getWidgetRect(widget.bottomNavKey!)
                    : null;

                return HelpTourOverlay(
                  step: _helpTourStep,
                  chipsRect: chipsRect,
                  mapCardRect: mapCardRect,
                  survivalKitRect: survivalKitRect,
                  weatherRect: weatherRect,
                  earlyWarningRect: earlyWarningRect,
                  newsRect: newsRect,
                  insuranceRect: insuranceRect,
                  bottomNavRect: bottomNavRect,
                  onNext: () {
                    if (_helpTourStep < 8) {
                      setState(() {
                        _helpTourStep++;
                      });
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_helpTourStep == 1) {
                          _scrollToKey(_chipsKey);
                        } else if (_helpTourStep == 2) {
                          _scrollToKey(_mapCardKey);
                        } else if (_helpTourStep == 3) {
                          _scrollToKey(_survivalKitKey);
                        } else if (_helpTourStep == 4) {
                          _scrollToKey(_weatherKey);
                        } else if (_helpTourStep == 5) {
                          _scrollToKey(_earlyWarningKey);
                        } else if (_helpTourStep == 6) {
                          _scrollToKey(_newsKey);
                        } else if (_helpTourStep == 7) {
                          _scrollToKey(_insuranceKey);
                        }
                      });
                    } else {
                      setState(() {
                        _showHelpTour = false;
                      });
                    }
                  },
                  onBack: () {
                    if (_helpTourStep > 1) {
                      setState(() {
                        _helpTourStep--;
                      });
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_helpTourStep == 1) {
                          _scrollToKey(_chipsKey);
                        } else if (_helpTourStep == 2) {
                          _scrollToKey(_mapCardKey);
                        } else if (_helpTourStep == 3) {
                          _scrollToKey(_survivalKitKey);
                        } else if (_helpTourStep == 4) {
                          _scrollToKey(_weatherKey);
                        } else if (_helpTourStep == 5) {
                          _scrollToKey(_earlyWarningKey);
                        } else if (_helpTourStep == 6) {
                          _scrollToKey(_newsKey);
                        } else if (_helpTourStep == 7) {
                          _scrollToKey(_insuranceKey);
                        }
                      });
                    }
                  },
                  onSkip: () {
                    setState(() {
                      _showHelpTour = false;
                    });
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget buildMenuGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildMenuItem(
          Icons.report_problem_outlined,
          Localization.of(context).get('home_menu_report'),
          const Color(0xFFFFEBEE),
          const Color(0xFFEF5350),
        ),
        _buildMenuItem(
          Icons.volunteer_activism_outlined,
          Localization.of(context).get('home_menu_donate'),
          const Color(0xFFE8F5E9),
          const Color(0xFF66BB6A),
        ),
        _buildMenuItem(
          Icons.check_circle_outline,
          Localization.of(context).get('home_menu_safe'),
          const Color(0xFFE3F2FD),
          const Color(0xFF42A5F5),
        ),
        _buildMenuItem(
          Icons.map_outlined,
          Localization.of(context).get('home_menu_map'),
          const Color(0xFFFFF3E0),
          const Color(0xFFFFCA28),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String label,
    Color bgColor,
    Color iconColor,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FiturPage()),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF424242),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiturTambahanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Fitur Lainnya',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FiturPage()),
                );
              },
              child: const Text(
                'Lihat Semua',
                style: TextStyle(
                  color: Color(0xFF00BCD4),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FiturPage()),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.dashboard_customize_outlined,
                    color: Color(0xFF2196F3),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Jelajahi Semua Fitur',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Lihat Peta Evakuasi, Panduan P3K, dan fitur darurat lainnya.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF757575),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xFF9E9E9E),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper method for News Section (needed to be moved/created if not existing in view, but assuming it exists or needs replacement)
  // Since the original view didn't show _buildNewsSection content in detail, I will target the known functions above first.
  // Wait, I need to check if _buildNewsSection is available in the file.
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Localization.of(context).get('home_header_title'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F7FA), // Light cyan
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Color(0xFF00BCD4),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _currentCityName,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF00BCD4),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                // Help Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () {
                      _startHelpTour();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: const Center(
                      child: Icon(
                        Icons.help_outline_rounded,
                        color: Color(0xFF1A1A1A),
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Notification Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      const Center(
                        child: Icon(
                          Icons.notifications_outlined,
                          color: Color(0xFF1A1A1A),
                          size: 24,
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF5252),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Profile Icon or Login Button
                ValueListenableBuilder<bool>(
                  valueListenable: isLoggedInNotifier,
                  builder: (context, isLoggedIn, _) {
                    return isLoggedIn
                        ? Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AkunPage(),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: const Center(
                                child: Icon(
                                  Icons.person_outline,
                                  color: Color(0xFF1A1A1A),
                                  size: 24,
                                ),
                              ),
                            ),
                          )
                        : InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00BCD4),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF00BCD4,
                                    ).withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  'Masuk',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEnvironmentStatusCard() {
    return EnvironmentStatusCard(
      isIndoor: _isIndoor,
      environmentType: _environmentType,
      nearbyMountainName: _nearbyMountainName,
      onIndoorToggle: () {
        setState(() {
          _isIndoor = !_isIndoor;
        });
      },
      chipsKey: _chipsKey,
    );
  }

  void _startHelpTour() {
    setState(() {
      _showHelpTour = true;
      _helpTourStep = 1;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToKey(_chipsKey);
    });
  }

  void _scrollToKey(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        alignment: 0.5,
        curve: Curves.easeInOut,
      );
    }
  }

  Rect? _getWidgetRect(GlobalKey key) {
    try {
      final RenderBox? renderBox =
          key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final offset = renderBox.localToGlobal(Offset.zero);
        return offset & renderBox.size;
      }
    } catch (e) {
      debugPrint("Error getting widget rect: $e");
    }
    return null;
  }

  // --- COMPACT EARTHQUAKE WARNING BANNER ---
  void _showEarthquakeAmanDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 340),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Gempabumi (lingkaran merah dengan ikon bangunan + gelombang getaran)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const VibrationWaveWidget(isLeft: true),
                    const SizedBox(width: 10),
                    // Outer light pink circle
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.domain_disabled_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const VibrationWaveWidget(isLeft: false),
                  ],
                ),
                const SizedBox(height: 16),

                // Judul "Gempabumi"
                const Text(
                  'Gempabumi',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),

                // Badge "Kelas Bahaya Rendah"
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        color: Color(0xFF4CAF50),
                        size: 14,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Kelas Bahaya Rendah',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Deskripsi
                const Text(
                  'Wilayahmu saat ini dalam kondisi aman dari potensi bahaya gempa bumi yang signifikan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4B5563),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),

                // Info Box (Pink background)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.info_outline_rounded,
                          color: Color(0xFF4CAF50),
                          size: 16,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Rekomendasi edukasi disesuaikan dengan kondisi bahaya gempa di wilayahmu.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF1F2937),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Status Lingkungan
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isIndoor ? Icons.home_rounded : Icons.wb_sunny_rounded,
                        color: _isIndoor ? const Color(0xFFE65100) : const Color(0xFF1B5E20),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isIndoor ? 'Dalam Ruangan' : 'Luar Ruangan',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _isIndoor ? const Color(0xFFE65100) : const Color(0xFF1B5E20),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        _environmentType == 'Pegunungan'
                            ? Icons.terrain_rounded
                            : _environmentType == 'Pantai'
                            ? Icons.beach_access_rounded
                            : Icons.location_city_rounded,
                        color: const Color(0xFF4B5563),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _environmentType == 'Pegunungan'
                              ? (_nearbyMountainName.isNotEmpty ? 'Dekat $_nearbyMountainName' : 'Pegunungan')
                              : _environmentType == 'Pantai'
                              ? 'Pesisir Pantai'
                              : 'Perkotaan',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4B5563),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Status Box
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.monitor_heart,
                        color: Color(0xFF4CAF50),
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Status:',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                      Spacer(),
                      Text(
                        'Aman',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Tombol "Lihat Edukasi" (Solid Blue)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            String locCat = 'Dalam Ruangan';
                            if (_environmentType.contains('Pantai') || _environmentType.contains('Pesisir')) {
                              locCat = 'Pesisir Pantai';
                            } else if (_environmentType.contains('Gunung') || _environmentType.contains('Pegunungan')) {
                              locCat = 'Pegunungan';
                            } else {
                              locCat = _isIndoor ? 'Dalam Ruangan' : 'Luar Ruangan';
                            }
                            return EdukasiAmanPage(
                              cityName: _currentCityName,
                              locationCategory: locCat,
                            );
                          },
                        ),
                      );
                    },
                    icon: const Icon(Icons.menu_book_rounded, size: 18),
                    label: const Text(
                      'Lihat Edukasi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Tombol "Tutup" (Outline Blue)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1E88E5),
                      side: const BorderSide(
                        color: Color(0xFF1E88E5),
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Tutup',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /*
  Future<void> _requestLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      ).timeout(const Duration(seconds: 3), onTimeout: () {
        return Position(
          latitude: -6.9559, // default Bojongsoang
          longitude: 107.6499,
          timestamp: DateTime.now(),
          accuracy: 10000.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );
      });

      print(
        "[Beranda] GPS coordinates: lat=${position.latitude}, lon=${position.longitude}, accuracy=${position.accuracy}m",
      );

      String cityName = 'Jakarta Pusat';
      String fullAddr = '';
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(const Duration(seconds: 2));
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          print(
            "[Beranda] Geocoding result: subLocality=${place.subLocality}, locality=${place.locality}, subAdmin=${place.subAdministrativeArea}, admin=${place.administrativeArea}",
          );
          cityName =
              place.locality ??
              place.subLocality ??
              place.subAdministrativeArea ??
              'Jakarta Pusat';
          cityName = cityName
              .replaceAll('Kabupaten ', '')
              .replaceAll('Kota ', '')
              .replaceAll(' City', '')
              .replaceAll('Kecamatan ', '')
              .replaceAll('Kelurahan ', '')
              .replaceAll('Desa ', '');
          fullAddr =
              '${place.name} ${place.street} ${place.subLocality} ${place.locality} ${place.subAdministrativeArea} ${place.administrativeArea}';
        }
      } catch (e) {
        print(
          "[Beranda] Geocoding package error: $e, falling back to Nominatim",
        );
        // Fallback for Web using OpenStreetMap Nominatim API
        try {
          final url = Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=16&addressdetails=1',
          );
          final response = await http.get(
            url,
            headers: {'User-Agent': 'AmaninApp/1.0'},
          ).timeout(const Duration(seconds: 3));
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            print("[Beranda] Nominatim full address: ${data['address']}");
            fullAddr = data['display_name'] ?? '';
            if (data['address'] != null) {
              final addr = data['address'];
              cityName =
                  addr['town'] ??
                  addr['subdistrict'] ??
                  addr['suburb'] ??
                  addr['city_district'] ??
                  addr['city'] ??
                  addr['county'] ??
                  addr['state'] ??
                  'Jakarta Pusat';
              cityName = cityName
                  .replaceAll('Kabupaten ', '')
                  .replaceAll('Kota ', '')
                  .replaceAll(' City', '')
                  .replaceAll('Kecamatan ', '')
                  .replaceAll('Kelurahan ', '')
                  .replaceAll('Desa ', '');
              print("[Beranda] Final city name: $cityName");
            }
          }
        } catch (fallbackError) {
          print("Nominatim fallback error: $fallbackError");
        }
      }

      if (mounted) {
        setState(() {
          _currentCityName = cityName;
        });
        userCityNameNotifier.value = cityName;
        _determineUserEnvironment(position, fullAddr);
      }
    } catch (e) {
      print("Location permission error: $e");
    }
  }

  void _determineUserEnvironment(Position position, String fullAddress) {
    final result = EnvironmentDetector.determineEnvironment(
      position.latitude,
      position.longitude,
      position.accuracy,
      fullAddress,
    );

    if (mounted) {
      setState(() {
        _isIndoor = false; // FORCE OUTDOOR FOR TESTING
        _environmentType = 'Pegunungan'; // FORCE GUNUNG FOR TESTING
        _nearbyMountainName = result.nearbyMountainName;
      });
    }
  }

  Future<void> _fetchEarthquakeData() async {
    try {
      final quake = await BmkgService.fetchLatestEarthquake();

      // Hitung parameter untuk Anomali
      double mag = double.tryParse(quake.magnitude) ?? 0.0;
      double depth =
          double.tryParse(quake.kedalaman.replaceAll(RegExp(r'[^0-9.]'), '')) ??
          0.0;
      double lat = 0.0;
      double lon = 0.0;

      if (quake.coordinates.isNotEmpty) {
        final coords = quake.coordinates.split(',');
        if (coords.length == 2) {
          lat = double.tryParse(coords[0]) ?? 0.0;
          lon = double.tryParse(coords[1]) ?? 0.0;
        }
      }

      // Jalankan pengecekan AI secara diam-diam
      final bool isAnomali = await AnomaliService.checkSingleAnomali(
        magnitude: mag,
        kedalaman: depth,
        lintang: lat,
        bujur: lon,
      );

      if (mounted) {
        setState(() {
          _latestQuake = quake;
          _isLatestQuakeAnomali = isAnomali;
          if (lat != 0.0 && lon != 0.0) {
            _earthquakeLocation = LatLng(lat, lon);
          }
          _isLoadingQuake = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingQuake = false;
        });
        print("Error fetching earthquake: $e");
      }
    }
  }

  Future<void> _fetchWeatherData() async {
    try {
      final cuaca = await BmkgService.fetchCurrentWeather(
        '32.04.08.2002',
      ); // Bojongsoang
      if (mounted) {
        setState(() {
          _latestCuaca = cuaca;
          _isLoadingCuaca = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCuaca = false;
        });
        print("Error fetching weather: $e");
      }
    }
  }

  Future<void> _fetchNewsData() async {
    try {
      final news = await NewsService.fetchNews();
      if (mounted) {
        setState(() {
          _newsList = news;
          _isLoadingNews = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingNews = false;
        });
        print("Error fetching news: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    _buildHeader(),
                    const SizedBox(height: 24),

                    // Compact Earthquake Warning Banner
                    _buildEarthquakeWarningBanner(),
                    const SizedBox(height: 16),

                    // Earthquake Status Section
                    _buildEarthquakeStatus(),
                    const SizedBox(height: 16),

                    // Merged Earthquake Card
                    _buildEarthquakeCard(),
                    const SizedBox(height: 20),

                    // Environment Status Card
                    _buildEnvironmentStatusCard(),
                    const SizedBox(height: 24),

                    // Survival Kit Card
                    _buildSurvivalKitSection(),
                    const SizedBox(height: 24),

                    // Weather Card
                    _buildWeatherCard(),
                    const SizedBox(height: 16),

                    // Early Warning Card
                    _buildEarlyWarningCard(),
                    const SizedBox(height: 24),

                    // News Section
                    _buildNewsSection(),
                    const SizedBox(height: 24),

                    // Asuransi Section
                    _buildInsuranceSection(),
                    const SizedBox(height: 24),

                    // Fitur Section (Di Bawah)
                    _buildFiturTambahanSection(),
                    const SizedBox(
                      height: 140,
                    ), // padding for floating bottom nav
                  ],
                ),
              ),
            ),
          ),
          if (_showHelpTour)
            AnimatedBuilder(
              animation: _scrollController,
              builder: (context, child) {
                final chipsRect = _getWidgetRect(_chipsKey);
                final mapCardRect = _getWidgetRect(_mapCardKey);
                final survivalKitRect = _getWidgetRect(_survivalKitKey);
                final weatherRect = _getWidgetRect(_weatherKey);
                final earlyWarningRect = _getWidgetRect(_earlyWarningKey);
                final newsRect = _getWidgetRect(_newsKey);
                final insuranceRect = _getWidgetRect(_insuranceKey);
                final bottomNavRect = widget.bottomNavKey != null
                    ? _getWidgetRect(widget.bottomNavKey!)
                    : null;

                return HelpTourOverlay(
                  step: _helpTourStep,
                  chipsRect: chipsRect,
                  mapCardRect: mapCardRect,
                  survivalKitRect: survivalKitRect,
                  weatherRect: weatherRect,
                  earlyWarningRect: earlyWarningRect,
                  newsRect: newsRect,
                  insuranceRect: insuranceRect,
                  bottomNavRect: bottomNavRect,
                  onNext: () {
                    if (_helpTourStep < 8) {
                      setState(() {
                        _helpTourStep++;
                      });
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_helpTourStep == 1) {
                          _scrollToKey(_chipsKey);
                        } else if (_helpTourStep == 2) {
                          _scrollToKey(_mapCardKey);
                        } else if (_helpTourStep == 3) {
                          _scrollToKey(_survivalKitKey);
                        } else if (_helpTourStep == 4) {
                          _scrollToKey(_weatherKey);
                        } else if (_helpTourStep == 5) {
                          _scrollToKey(_earlyWarningKey);
                        } else if (_helpTourStep == 6) {
                          _scrollToKey(_newsKey);
                        } else if (_helpTourStep == 7) {
                          _scrollToKey(_insuranceKey);
                        }
                      });
                    } else {
                      setState(() {
                        _showHelpTour = false;
                      });
                    }
                  },
                  onBack: () {
                    if (_helpTourStep > 1) {
                      setState(() {
                        _helpTourStep--;
                      });
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_helpTourStep == 1) {
                          _scrollToKey(_chipsKey);
                        } else if (_helpTourStep == 2) {
                          _scrollToKey(_mapCardKey);
                        } else if (_helpTourStep == 3) {
                          _scrollToKey(_survivalKitKey);
                        } else if (_helpTourStep == 4) {
                          _scrollToKey(_weatherKey);
                        } else if (_helpTourStep == 5) {
                          _scrollToKey(_earlyWarningKey);
                        } else if (_helpTourStep == 6) {
                          _scrollToKey(_newsKey);
                        } else if (_helpTourStep == 7) {
                          _scrollToKey(_insuranceKey);
                        }
                      });
                    }
                  },
                  onSkip: () {
                    setState(() {
                      _showHelpTour = false;
                    });
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget buildMenuGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildMenuItem(
          Icons.report_problem_outlined,
          Localization.of(context).get('home_menu_report'),
          const Color(0xFFFFEBEE),
          const Color(0xFFEF5350),
        ),
        _buildMenuItem(
          Icons.volunteer_activism_outlined,
          Localization.of(context).get('home_menu_donate'),
          const Color(0xFFE8F5E9),
          const Color(0xFF66BB6A),
        ),
        _buildMenuItem(
          Icons.check_circle_outline,
          Localization.of(context).get('home_menu_safe'),
          const Color(0xFFE3F2FD),
          const Color(0xFF42A5F5),
        ),
        _buildMenuItem(
          Icons.map_outlined,
          Localization.of(context).get('home_menu_map'),
          const Color(0xFFFFF3E0),
          const Color(0xFFFFCA28),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String label,
    Color bgColor,
    Color iconColor,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FiturPage()),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF424242),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiturTambahanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Fitur Lainnya',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FiturPage()),
                );
              },
              child: const Text(
                'Lihat Semua',
                style: TextStyle(
                  color: Color(0xFF00BCD4),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FiturPage()),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.dashboard_customize_outlined,
                    color: Color(0xFF2196F3),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Jelajahi Semua Fitur',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Lihat Peta Evakuasi, Panduan P3K, dan fitur darurat lainnya.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF757575),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xFF9E9E9E),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper method for News Section (needed to be moved/created if not existing in view, but assuming it exists or needs replacement)
  // Since the original view didn't show _buildNewsSection content in detail, I will target the known functions above first.
  // Wait, I need to check if _buildNewsSection is available in the file.
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Localization.of(context).get('home_header_title'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F7FA), // Light cyan
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Color(0xFF00BCD4),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _currentCityName,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF00BCD4),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                // Help Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () {
                      _startHelpTour();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: const Center(
                      child: Icon(
                        Icons.help_outline_rounded,
                        color: Color(0xFF1A1A1A),
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Notification Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      const Center(
                        child: Icon(
                          Icons.notifications_outlined,
                          color: Color(0xFF1A1A1A),
                          size: 24,
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF5252),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Profile Icon or Login Button
                ValueListenableBuilder<bool>(
                  valueListenable: isLoggedInNotifier,
                  builder: (context, isLoggedIn, _) {
                    return isLoggedIn
                        ? Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AkunPage(),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: const Center(
                                child: Icon(
                                  Icons.person_outline,
                                  color: Color(0xFF1A1A1A),
                                  size: 24,
                                ),
                              ),
                            ),
                          )
                        : InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00BCD4),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF00BCD4,
                                    ).withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  'Masuk',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEnvironmentStatusCard() {
    return EnvironmentStatusCard(
      isIndoor: _isIndoor,
      environmentType: _environmentType,
      nearbyMountainName: _nearbyMountainName,
      onIndoorToggle: () {
        setState(() {
          _isIndoor = !_isIndoor;
        });
      },
      chipsKey: _chipsKey,
    );
  }

  void _startHelpTour() {
    setState(() {
      _showHelpTour = true;
      _helpTourStep = 1;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToKey(_chipsKey);
    });
  }

  void _scrollToKey(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        alignment: 0.5,
        curve: Curves.easeInOut,
      );
    }
  }

  Rect? _getWidgetRect(GlobalKey key) {
    try {
      final RenderBox? renderBox =
          key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final offset = renderBox.localToGlobal(Offset.zero);
        return offset & renderBox.size;
      }
    } catch (e) {
      debugPrint("Error getting widget rect: $e");
    }
    return null;
  }
  */

  // --- COMPACT EARTHQUAKE WARNING BANNER ---
  Widget _buildEarthquakeWarningBanner() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                String locCat = 'Dalam Ruangan';
                if (_environmentType.contains('Pantai') || _environmentType.contains('Pesisir')) {
                  locCat = 'Pesisir Pantai';
                } else if (_environmentType.contains('Gunung') || _environmentType.contains('Pegunungan')) {
                  locCat = 'Pegunungan';
                } else {
                  locCat = _isIndoor ? 'Dalam Ruangan' : 'Luar Ruangan';
                }
                return EdukasiBahayaPage(
                  cityName: _currentCityName,
                  locationCategory: locCat,
                );
              },
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE53935), Color(0xFFFF7043)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE53935).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.domain_disabled_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Peringatan Gempa',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Bahaya Tinggi',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Ketuk untuk melihat edukasi mitigasi',
                      style: TextStyle(fontSize: 11, color: Color(0xFFFFCDD2)),
                    ),
                  ],
                ),
              ),
              // Arrow icon
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEarthquakeStatus() {
    final double magValue =
        double.tryParse(_latestQuake?.magnitude ?? '') ?? 0.0;
    final bool isSignificant = magValue >= 5.0;
    final Color alertColor = isSignificant
        ? const Color(0xFFD32F2F)
        : const Color(0xFF0088CC);
    final String alertLabel = isSignificant ? 'MAJOR ALERT' : 'INFO GEMPA';

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: alertColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          Localization.of(context).get('home_quake_status_danger'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: alertColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: alertColor.withOpacity(0.2), width: 1),
          ),
          child: Text(
            alertLabel,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: alertColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumDetailTile({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC), // Slate 50
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1,
        ), // Slate 100
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF94A3B8), // Slate 400
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B), // Slate 800
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarthquakeCard() {
    final double magValue =
        double.tryParse(_latestQuake?.magnitude ?? '') ?? 0.0;

    // Determine color coding based on magnitude following standard BMKG style
    Color magColor;
    Color magBgColor;
    IconData alertIcon;

    if (magValue >= 6.0) {
      magColor = const Color(0xFFD32F2F); // Red
      magBgColor = const Color(0xFFFFEBEE);
      alertIcon = Icons.warning_rounded;
    } else if (magValue >= 5.0) {
      magColor = const Color(0xFFE65100); // Orange
      magBgColor = const Color(0xFFFFF3E0);
      alertIcon = Icons.error_outline_rounded;
    } else {
      magColor = const Color(0xFF092C4C); // Deep BMKG Blue
      magBgColor = const Color(0xFFE0F2FE);
      alertIcon = Icons.info_outline_rounded;
    }

    final bool isTsunami =
        _latestQuake?.potensi.toLowerCase().contains('potensi tsunami') ??
        false;
    final Color potensiColor = isTsunami
        ? const Color(0xFFD32F2F)
        : const Color(0xFF2E7D32);
    final Color potensiBgColor = isTsunami
        ? const Color(0xFFFFEBEE)
        : const Color(0xFFE8F5E9);

    return Container(
      key: _mapCardKey,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: _isLatestQuakeAnomali
            ? Border.all(color: Colors.red.shade400, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF092C4C,
            ).withValues(alpha: 0.06), // Subtle BMKG blue shadow
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          if (_isLatestQuakeAnomali)
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.2),
              blurRadius: 15,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Column(
        children: [
          if (_isLatestQuakeAnomali)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFFFF5252),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Peringatan: Aktivitas Seismik Tidak Biasa!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          Stack(
            children: [
              ClipRRect(
                borderRadius: _isLatestQuakeAnomali
                    ? BorderRadius.zero
                    : const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: FlutterMap(
                    key: ValueKey(_earthquakeLocation),
                    options: MapOptions(
                      initialCenter: _earthquakeLocation,
                      initialZoom: 8.0,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.amanin',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _earthquakeLocation,
                            width: 60,
                            height: 60,
                            child: const PulsatingMarker(
                              color: Color(0xFFFF5252),
                              radius: 30.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.map_outlined,
                        color: Color(0xFF3949AB),
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Peta Guncangan',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3949AB),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: InkWell(
                  onTap: () {
                    if (_latestQuake != null) {
                      final gempa = _latestQuake!;
                      final String shareText =
                          'Info Gempa dirasakan Mag:${gempa.magnitude}, ${gempa.tanggal} ${gempa.jam.replaceAll(' WIB', '')} WIB, Lok:${gempa.lintang}, ${gempa.bujur} (${gempa.wilayah}), Kedlmn:${gempa.kedalaman} ::AMANIN\nInformasi selengkapnya lihat di\nhttps://amanin.app/';
                      Share.share(shareText);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.share_outlined,
                      color: Color(0xFF424242),
                      size: 18,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                right: 12,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      if (_latestQuake != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullscreenMapPage(
                              gempa: _latestQuake!,
                              isAnomali: _isLatestQuakeAnomali,
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.open_in_full_rounded,
                        size: 16,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoBox(
                        _isLoadingQuake
                            ? '...'
                            : (_latestQuake?.magnitude ?? '4.0'),
                        'Magnitudo',
                        const Color(0xFFF44336),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoBox(
                        _isLoadingQuake
                            ? '...'
                            : (_latestQuake?.kedalaman ?? '10 Km'),
                        'Kedalaman',
                        const Color(0xFF4CAF50),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoBox(
                        _isLoadingQuake
                            ? '...'
                            : (_latestQuake?.lintang ?? '1.54 LU'),
                        'Lokasi',
                        const Color(0xFF2196F3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildQuakeDetailRow(
                  Icons.access_time,
                  _isLoadingQuake
                      ? 'Memuat data...'
                      : '${_latestQuake?.tanggal ?? ''}, ${_latestQuake?.jam ?? ''}',
                  'Waktu Gempa',
                  const Color(0xFFFF9800),
                ),
                if (_latestQuake?.dirasakan.isNotEmpty == true &&
                    _latestQuake!.dirasakan != '-') ...[
                  const SizedBox(height: 16),
                  _buildQuakeDetailRow(
                    Icons.track_changes,
                    _latestQuake!.dirasakan,
                    'Dampak Guncangan',
                    const Color(0xFFFF5722),
                  ),
                ],
                const SizedBox(height: 16),
                _buildQuakeDetailRow(
                  Icons.location_on,
                  _isLoadingQuake
                      ? 'Memuat data...'
                      : (_latestQuake?.wilayah ?? '...'),
                  null,
                  const Color(0xFFFF9800),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_latestQuake != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullscreenMapPage(
                              gempa: _latestQuake!,
                              isAnomali: _isLatestQuakeAnomali,
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BCD4),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Lihat Detail',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String value, String label, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF757575)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuakeDetailRow(
    IconData icon,
    String text,
    String? subtext,
    Color iconColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              if (subtext != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtext,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSurvivalKitSection() {
    return Column(
      key: _survivalKitKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.shopping_bag, color: Color(0xFF0088CC), size: 24),
                SizedBox(width: 8),
                Text(
                  'Perlengkapan Siaga',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            const Text(
              'Diskon Spesial',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF00BCD4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            clipBehavior: Clip.none,
            child: Row(
              children: [
                _buildSurvivalItemCard(
                  title: 'Tas Siaga 72 Jam',
                  desc:
                      'Paket survival kit lengkap untuk 3 hari darurat. Tas anti-air & senter',
                  oldPrice: 'Rp 650.000',
                  newPrice: 'Rp 455.000',
                  discount: '30%',
                  icon: Icons.backpack,
                  iconColor: const Color(0xFF4CAF50),
                  bgColor: const Color(0xFFE8F5E9),
                ),
                _buildSurvivalItemCard(
                  title: 'Radio Engkol Surya',
                  desc:
                      'Radio dengan baterai cadangan, senter, dan pemutar engkol daya.',
                  oldPrice: 'Rp 300.000',
                  newPrice: 'Rp 210.000',
                  discount: '30%',
                  icon: Icons.radio,
                  iconColor: const Color(0xFF26A69A),
                  bgColor: const Color(0xFFE0F2F1),
                ),
                _buildSurvivalItemCard(
                  title: 'Kotak P3K Lengkap',
                  desc:
                      'Alat medis standar untuk luka ringan dan perban pendarahan.',
                  oldPrice: 'Rp 150.000',
                  newPrice: 'Rp 127.500',
                  discount: '15%',
                  icon: Icons.medical_services,
                  iconColor: const Color(0xFFEF5350),
                  bgColor: const Color(0xFFFFEAEA),
                ),
                _buildSurvivalItemCard(
                  title: 'Power Station Mini',
                  desc:
                      'Baterai portabel 20000mAh tahan lama untuk charge HP berulang.',
                  oldPrice: '',
                  newPrice: 'Rp 550.000',
                  discount: '',
                  icon: Icons.battery_charging_full,
                  iconColor: const Color(0xFF42A5F5),
                  bgColor: const Color(0xFFE3F2FD),
                ),
                _buildSurvivalItemCard(
                  title: 'Senter LED Darurat',
                  desc:
                      'Senter terang dengan fitur SOS dan daya tahan baterai super.',
                  oldPrice: 'Rp 120.000',
                  newPrice: 'Rp 85.000',
                  discount: '29%',
                  icon: Icons.flashlight_on,
                  iconColor: const Color(0xFFFFB300),
                  bgColor: const Color(0xFFFFF8E1),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSurvivalItemCard({
    required String title,
    required String desc,
    required String oldPrice,
    required String newPrice,
    required String discount,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      width: 320,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 40),
              ),
              if (discount.isNotEmpty)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5252),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      discount,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF757575),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (oldPrice.isNotEmpty)
                          Text(
                            oldPrice,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF9E9E9E),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        Text(
                          newPrice,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF5252),
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TokoAmaninPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BCD4),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Beli',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsuranceSection() {
    return Container(
      key: _insuranceKey,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFE3F2FD),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.security,
              color: Color(0xFF2196F3),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Asuransi Pro-Siaga',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Perlindungan aset dan kesehatan keluarga dari dampak bencana alam.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF757575)),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.check_circle,
                      color: Color(0xFF4CAF50),
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Klaim cepat 24 jam',
                      style: TextStyle(fontSize: 12, color: Color(0xFF424242)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Icon(
                      Icons.check_circle,
                      color: Color(0xFF4CAF50),
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Cover gempa & banjir',
                      style: TextStyle(fontSize: 12, color: Color(0xFF424242)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AsuransiWebPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BCD4),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Cek Asuransi Sekarang',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Disponsori • S&K berlaku',
            style: TextStyle(fontSize: 10, color: Color(0xFF9E9E9E)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9E9E9E),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherCard() {
    return Column(
      key: _weatherKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cuaca Lokal',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 12),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              if (widget.onNavigateToCuaca != null) {
                widget.onNavigateToCuaca!();
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CuacaPage()),
                );
              }
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF00BCD4), // Vivid Cyan (Matches button exactly)
                    Color(0xFF00838F), // Darker Cyan for premium gradient depth
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00BCD4).withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Weather Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'SAAT INI',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _isLoadingCuaca
                                  ? '...'
                                  : (_latestCuaca?.cuaca.isNotEmpty == true
                                        ? _latestCuaca!.cuaca
                                        : 'Berawan'),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.1,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Terasa seperti ${_isLoadingCuaca ? "..." : (_latestCuaca != null ? _latestCuaca!.suhu + 2 : 34)}°C',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.85),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ValueListenableBuilder<String>(
                              valueListenable: userCityNameNotifier,
                              builder: (context, cityName, _) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        size: 11,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        cityName,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  _isLoadingCuaca
                                      ? '--'
                                      : '${_latestCuaca?.suhu.toString() ?? '32'}°',
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white,
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: _isLoadingCuaca
                                      ? const Center(
                                          child: SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 1.5,
                                            ),
                                          ),
                                        )
                                      : (_latestQuake != null &&
                                                _latestCuaca != null &&
                                                _latestCuaca!.image.isNotEmpty
                                            ? Center(
                                                child: Image.network(
                                                  _latestCuaca!.image,
                                                  width: 24,
                                                  height: 24,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) => const Icon(
                                                        Icons.cloud_outlined,
                                                        color: Colors.white,
                                                        size: 20,
                                                      ),
                                                ),
                                              )
                                            : const Icon(
                                                Icons.cloud_outlined,
                                                color: Colors.white,
                                                size: 20,
                                              )),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                    const SizedBox(height: 14),
                    // Bottom Details
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildWeatherDetail(
                          Icons.water_drop_outlined,
                          _isLoadingCuaca
                              ? '--%'
                              : '${_latestCuaca?.kelembapan ?? 94}%',
                          'Air',
                        ),
                        _buildWeatherDetail(
                          Icons.air_rounded,
                          _isLoadingCuaca
                              ? '--'
                              : (_latestCuaca?.kecAngin.toString() ?? '3.6'),
                          'km/h',
                        ),
                        _buildWeatherDetail(
                          Icons.wb_sunny_outlined,
                          'UV 6',
                          'Sedang',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherDetail(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarlyWarningCard() {
    final String warningMsg = _isLoadingCuaca
        ? "Memeriksa peringatan cuaca..."
        : (_latestCuaca?.peringatanDini ??
              "Sedang tidak ada peringatan cuaca yang signifikan untuk saat ini.");

    final bool hasWarning = warningMsg.contains("Waspada");

    return Container(
      key: _earlyWarningKey,
      decoration: BoxDecoration(
        color: hasWarning ? const Color(0xFFFFF3E0) : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasWarning ? const Color(0xFFFFB74D) : const Color(0xFF81C784),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: hasWarning
                    ? const Color(0xFFFF9800)
                    : const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                hasWarning ? Icons.warning_rounded : Icons.check_circle_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasWarning ? 'Peringatan Dini' : 'Cuaca Aman',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: hasWarning
                          ? const Color(0xFF1A1A1A)
                          : const Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    warningMsg,
                    style: TextStyle(
                      fontSize: 12,
                      color: hasWarning
                          ? const Color(0xFF424242)
                          : const Color(0xFF388E3C),
                      height: 1.4,
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

  Widget _buildNewsSection() {
    return Column(
      key: _newsKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              Localization.of(context).get('home_news_title'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to all news
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                Localization.of(context).get('home_news_more'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00BCD4),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Horizontal Scrollable News Cards
        SizedBox(
          height: 280,
          child: _isLoadingNews
              ? const Center(child: CircularProgressIndicator())
              : _newsList.isEmpty
              ? const Center(child: Text('Tidak ada berita terbaru.'))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _newsList.length,
                  itemBuilder: (context, index) {
                    final news = _newsList[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: _buildNewsCard(news),
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _formatNewsTime(String utcString) {
    try {
      final date = DateTime.parse(utcString).toLocal();
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) {
        return '${diff.inMinutes} Menit lalu';
      } else if (diff.inHours < 24) {
        return '${diff.inHours} Jam lalu';
      } else {
        return '${diff.inDays} Hari lalu';
      }
    } catch (e) {
      return '';
    }
  }

  Widget _buildNewsCard(NewsModel news) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => IsiBeritaPage(news: news)),
          );
        },
        child: Container(
          width: 280,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image/Icon Section
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: Hero(
                        tag: news.link, // For hero animation
                        child: Image.network(
                          news.photoUrl.isNotEmpty
                              ? news.photoUrl
                              : 'https://via.placeholder.com/280x160?text=No+Image',
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                        ),
                      ),
                    ),
                    // Category Badge (Source Name based)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          news.sourceName.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        news.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatNewsTime(news.publishedDatetimeUtc),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VibrationWaveWidget extends StatelessWidget {
  final bool isLeft;
  const VibrationWaveWidget({required this.isLeft, super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(12, 40),
      painter: VibrationWavePainter(isLeft: isLeft),
    );
  }
}

class VibrationWavePainter extends CustomPainter {
  final bool isLeft;
  VibrationWavePainter({required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE53935)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    if (isLeft) {
      // Small arc: center at x = size.width + 8
      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(size.width + 8, size.height / 2),
          radius: 16,
        ),
        2.3, // start angle
        1.68, // sweep angle
        false,
        paint,
      );
      // Large arc
      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(size.width + 8, size.height / 2),
          radius: 24,
        ),
        2.3,
        1.68,
        false,
        paint,
      );
    } else {
      // Small arc: center at x = -8
      canvas.drawArc(
        Rect.fromCircle(center: Offset(-8, size.height / 2), radius: 16),
        -0.84,
        1.68,
        false,
        paint,
      );
      // Large arc
      canvas.drawArc(
        Rect.fromCircle(center: Offset(-8, size.height / 2), radius: 24),
        -0.84,
        1.68,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
