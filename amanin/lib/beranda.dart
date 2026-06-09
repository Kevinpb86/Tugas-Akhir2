import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'gempa_detail.dart';
import 'utils/earthquake_map.dart';
import 'utils/map_utils.dart';
import 'fullscreen_map.dart';
import 'cuaca.dart';
import 'akun.dart';
import 'fitur.dart';
import 'login.dart';
import 'utils/localization.dart';
import 'main.dart'; // For isLoggedInNotifier
import 'toko.dart';
import 'asuransi.dart';
import 'services/bmkg_service.dart';
import 'services/news_service.dart';
import 'isi_berita.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

class BerandaPage extends StatefulWidget {
  final VoidCallback? onNavigateToCuaca;
  const BerandaPage({super.key, this.onNavigateToCuaca});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  // Earthquake location: 81 Km Barat Daya Kuta Selatan
  LatLng _earthquakeLocation = const LatLng(-8.8, 115.0);
  GempaModel? _latestQuake;
  bool _isLoadingQuake = true;

  CuacaModel? _latestCuaca;
  bool _isLoadingCuaca = true;

  List<NewsModel> _newsList = [];
  bool _isLoadingNews = true;

  String _currentCityName = 'Jakarta Pusat';

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _fetchEarthquakeData();
    _fetchWeatherData();
    _fetchNewsData();
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
        desiredAccuracy: LocationAccuracy.medium,
      );

      String cityName = 'Jakarta Pusat';
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          cityName =
              place.subAdministrativeArea ?? place.locality ?? 'Jakarta Pusat';
          cityName = cityName
              .replaceAll('Kabupaten ', '')
              .replaceAll('Kota ', '');
        }
      } catch (e) {
        // Fallback for Web using OpenStreetMap Nominatim API
        try {
          final url = Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}',
          );
          final response = await http.get(
            url,
            headers: {'User-Agent': 'AmaninApp/1.0'},
          );
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            if (data['address'] != null) {
              cityName =
                  data['address']['city'] ??
                  data['address']['town'] ??
                  data['address']['county'] ??
                  data['address']['state'] ??
                  'Jakarta Pusat';
              cityName = cityName
                  .replaceAll('Kabupaten ', '')
                  .replaceAll('Kota ', '');
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
      }
    } catch (e) {
      print("Location permission error: $e");
    }
  }

  Future<void> _fetchEarthquakeData() async {
    try {
      final quake = await BmkgService.fetchLatestEarthquake();
      if (mounted) {
        setState(() {
          _latestQuake = quake;
          if (_latestQuake!.coordinates.isNotEmpty) {
            final coords = _latestQuake!.coordinates.split(',');
            if (coords.length == 2) {
              _earthquakeLocation = LatLng(
                double.parse(coords[0]),
                double.parse(coords[1]),
              );
            }
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
        '31.71.01.1001',
      ); // Jakarta Pusat, Gambir
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
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeader(),
                const SizedBox(height: 24),

                // Earthquake Status Section
                _buildEarthquakeStatus(),
                const SizedBox(height: 16),

                // Merged Earthquake Card
                _buildEarthquakeCard(),
                const SizedBox(height: 16),

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
                const SizedBox(height: 140), // padding for floating bottom nav
              ],
            ),
          ),
        ),
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
    return Row(
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF092C4C,
            ).withValues(alpha: 0.06), // Subtle BMKG blue shadow
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
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
                            builder: (context) =>
                                FullscreenMapPage(gempa: _latestQuake!),
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
                    'Wilayah Dirasakan (MMI)',
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
                            builder: (context) =>
                                GempaDetailPage(gempa: _latestQuake),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Cuaca Lokal',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Color(0xFF757575),
                ),
                const SizedBox(width: 4),
                Text(
                  _isLoadingCuaca ? '...' : (_latestCuaca?.kota ?? 'Cilacap'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ],
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
                    Color(0xFFE1F5FE), // Sangat muda
                    Color(0xFFB3E5FC), // Agak biru
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Weather Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2196F3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'SAAT INI',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _isLoadingCuaca
                                  ? '...'
                                  : (_latestCuaca?.cuaca.isNotEmpty == true
                                        ? _latestCuaca!.cuaca
                                        : 'Berawan'),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Terasa seperti ${_isLoadingCuaca ? "..." : (_latestCuaca != null ? _latestCuaca!.suhu + 2 : 34)}°C', // Simple feel logic
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF757575),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isLoadingCuaca
                                  ? '--'
                                  : (_latestCuaca?.suhu.toString() ?? '32'),
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w300,
                                color: Color(0xFF1A1A1A),
                                height: 1,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  '°',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w300,
                                    color: Color(0xFF1A1A1A),
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: _isLoadingCuaca
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : (_latestCuaca != null &&
                                                _latestCuaca!.image.isNotEmpty
                                            ? Center(
                                                child: Image.network(
                                                  _latestCuaca!.image,
                                                  width: 24,
                                                  height: 24,
                                                  // Handle network image failure gracefully
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) => const Icon(
                                                        Icons.cloud,
                                                        color: Colors.white,
                                                        size: 24,
                                                      ),
                                                ),
                                              )
                                            : const Icon(
                                                Icons.cloud,
                                                color: Colors.white,
                                                size: 24,
                                              )),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Bottom Details
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildWeatherDetail(
                          Icons.water_drop,
                          _isLoadingCuaca
                              ? '--%'
                              : '${_latestCuaca?.kelembapan ?? 94}%',
                          'Air',
                          const Color(0xFF2196F3),
                        ),
                        _buildWeatherDetail(
                          Icons.air,
                          _isLoadingCuaca
                              ? '--'
                              : (_latestCuaca?.kecAngin.toString() ?? '3.6'),
                          'km/h',
                          const Color(0xFF4CAF50),
                        ),
                        _buildWeatherDetail(
                          Icons.wb_sunny,
                          // UV index API nya gaada ya, kita hide kalo gaada data / kasi default Sedang
                          'UV 6',
                          'Sedang',
                          const Color(0xFFFF9800),
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

  Widget _buildWeatherDetail(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF757575)),
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
