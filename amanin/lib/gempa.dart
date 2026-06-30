import 'package:flutter/material.dart';
import 'dart:async';
import 'riwayat_gempa.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'utils/map_utils.dart';
import 'utils/earthquake_map.dart';
import 'fullscreen_map.dart';
import 'akun.dart';
import 'main.dart';
import 'login.dart';
import 'asuransi.dart';
import 'services/bmkg_service.dart';
import 'services/usgs_service.dart';
import 'services/anomali_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class GempaPage extends StatefulWidget {
  const GempaPage({super.key});

  @override
  State<GempaPage> createState() => _GempaPageState();
}

class _GempaPageState extends State<GempaPage> {
  String _currentCityName = 'Memuat lokasi...';
  Position? _userPosition;
  GempaModel? _latestQuake;
  List<GempaModel> _recentQuakes = [];
  bool _isLoadingQuake = true;
  bool _isLoadingRecentQuakes = true;
  Timer? _refreshTimer;
  DateTime? _lastUpdated;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _refreshData();
    // Set up auto-refresh timer every 60 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      _refreshData(isAuto: true);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    String cityName = 'Jakarta Pusat';
    Position? position;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      // Try to get last known position first (instant, skipped on web)
      if (!kIsWeb) {
        position = await Geolocator.getLastKnownPosition();
      }
      
      // If null, get current position with a timeout (e.g. 3 seconds)
      position ??= await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      ).timeout(const Duration(seconds: 3));

      print(
        "[Gempa] GPS coordinates: lat=${position.latitude}, lon=${position.longitude}, accuracy=${position.accuracy}m",
      );

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(const Duration(seconds: 2));
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          print(
            "[Gempa] Geocoding result: subLocality=${place.subLocality}, locality=${place.locality}, subAdmin=${place.subAdministrativeArea}, admin=${place.administrativeArea}",
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
        }
      } catch (e) {
        print("[Gempa] Geocoding package error: $e, falling back to Nominatim");
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
            print("[Gempa] Nominatim full address: ${data['address']}");
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
              print("[Gempa] Final city name: $cityName");
            }
          }
        } catch (fallbackError) {
          print("Nominatim fallback error: $fallbackError");
        }
      }
    } catch (e) {
      print("Location permission error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _currentCityName = cityName;
          if (position != null) {
            _userPosition = position;
          }
        });
      }
    }
  }

  Future<void> _refreshData({bool isAuto = false}) async {
    await Future.wait([
      _fetchEarthquakeData(),
      _fetchRecentEarthquakeData(isAuto: isAuto),
    ]);
    if (mounted) {
      setState(() {
        _lastUpdated = DateTime.now();
      });
    }
  }

  Future<void> _fetchEarthquakeData() async {
    try {
      final quake = await BmkgService.fetchLatestEarthquake();
      if (mounted) {
        setState(() {
          _latestQuake = quake;
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

  Future<void> _fetchRecentEarthquakeData({bool isAuto = false}) async {
    if (!isAuto && mounted) setState(() => _isLoadingRecentQuakes = true);
    try {
      List<GempaModel> quakes = await UsgsService.fetchIndonesiaEarthquakes();
      if (mounted) {
        setState(() {
          _recentQuakes = quakes;
          _isLoadingRecentQuakes = false;
        });
        _checkAnomaliesForRecentQuakes();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRecentQuakes = false;
        });
        print("Error fetching recent earthquakes: $e");
      }
    }
  }
  Future<void> _checkAnomaliesForRecentQuakes() async {
    try {
      final anomalyList = await AnomaliService.fetchAnomaliTerkini();
      if (!mounted) return;

      setState(() {
        for (var quake in _recentQuakes) {
          final match = anomalyList
              .where((a) => a.tanggal == quake.tanggal && a.jam == quake.jam)
              .firstOrNull;

          if (match != null) {
            quake.isAnomali = match.isAnomali;
          }
        }
      });
    } catch (e) {
      print("Error fetching anomaly list for recent quakes: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            await _refreshData();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildMainEarthquakeCard(),
                const SizedBox(height: 24),
                _buildHistoryHeader(),
                const SizedBox(height: 16),
                _buildRecentEarthquakes(context),
                const SizedBox(height: 24),
                _buildInsuranceSection(context),
                const SizedBox(height: 100), // padding for floating bottom nav
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Amanin',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () {
                setState(() {
                  _currentCityName = 'Memuat lokasi...';
                });
                _requestLocationPermission();
              },
              child: Container(
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
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.sync_rounded,
                      color: Color(0xFF00BCD4),
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
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
                    right: 12,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF44336),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ValueListenableBuilder<bool>(
              valueListenable: isLoggedInNotifier,
              builder: (context, isLoggedIn, _) {
                return isLoggedIn
                    ? InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AkunPage(),
                            ),
                          );
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFEEEEEE),
                              width: 1,
                            ),
                          ),
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



  Widget _buildMainEarthquakeCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Map Placeholder Area
          // Map Area
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: Stack(
                children: [
                  _latestQuake?.coordinates.isNotEmpty == true
                      ? EarthquakeMap(
                          coordinates: _latestQuake!.coordinates,
                          initialZoom: 7.0,
                          interactive: false,
                        )
                      : Container(
                          color: const Color(0xFFF1F5F9),
                          child: const Center(
                            child: Icon(
                              Icons.map,
                              size: 80,
                              color: Color(0xFFCBD5E1),
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
                    bottom: 16,
                    right: 16,
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
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.open_in_full_rounded,
                            size: 16,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Gempabumi Dirasakan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'MAJOR ALERT',
                        style: TextStyle(
                          color: Color(0xFFF44336),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Builder(
                  builder: (context) {
                    final double magVal = double.tryParse(_latestQuake?.magnitude ?? '') ?? 0.0;
                    Color magTextColor;
                    if (magVal < 4.0) {
                      magTextColor = const Color(0xFF2E7D32); // Green (Rendah)
                    } else if (magVal <= 6.0) {
                      magTextColor = const Color(0xFFF57F17); // Orange (Sedang)
                    } else {
                      magTextColor = const Color(0xFFD32F2F); // Red (Tinggi)
                    }

                    final double depthVal = double.tryParse(_latestQuake?.kedalaman.replaceAll(RegExp(r'[^0-9.]'), '') ?? '') ?? 0.0;
                    Color depthTextColor;
                    if (depthVal <= 60.0) {
                      depthTextColor = const Color(0xFFD32F2F); // Red (Dangkal - Tinggi)
                    } else if (depthVal <= 300.0) {
                      depthTextColor = const Color(0xFFF57F17); // Orange (Menengah - Sedang)
                    } else {
                      depthTextColor = const Color(0xFF2E7D32); // Green (Dalam - Rendah)
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: _buildInfoBox(
                            _isLoadingQuake
                                ? '...'
                                : (_latestQuake?.magnitude ?? '≈ 5.7'),
                            'Magnitudo',
                            magTextColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoBox(
                            _isLoadingQuake
                                ? '...'
                                : (_latestQuake?.kedalaman ?? '10 Km'),
                            'Kedalaman',
                            depthTextColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoBox(
                            _isLoadingQuake
                                ? '...'
                                : (_latestQuake?.lintang ?? '1.54 LU'),
                            'Lokasi',
                            const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                _buildDetailRow(
                  Icons.access_time,
                  _isLoadingQuake
                      ? 'Memuat data...'
                      : '${_latestQuake?.tanggal ?? ''}, ${_latestQuake?.jam ?? ''}',
                  'Waktu Gempa',
                  const Color(0xFFFF9800),
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  Icons.track_changes,
                  _isLoadingQuake
                      ? 'Memuat data...'
                      : (_latestQuake?.dirasakan ?? '-'),
                  'Dampak Guncangan',
                  const Color(0xFFFF5722),
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  Icons.location_on,
                  _isLoadingQuake
                      ? 'Memuat data...'
                      : (_latestQuake?.wilayah ?? '...'),
                  null,
                  const Color(0xFFFF9800),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => _showFeltReportBottomSheet(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9800),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Saya juga merasakannya',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.back_hand, color: Colors.white, size: 16),
                      ],
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

  void _showFeltReportBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext context) {
        int selectedIntensity = 1; // Default to Sedang
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    12,
                    24,
                    MediaQuery.of(context).viewInsets.bottom + 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Laporkan Getaran Gempa',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Kontribusi Anda sangat membantu kami memetakan tingkat keparahan dampak gempa bumi.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildIntensityOption(
                        index: 0,
                        title: 'Getaran Ringan',
                        description: 'Getaran dirasakan beberapa orang di dalam rumah. Gelas/kaca berderik lembut.',
                        icon: Icons.info_outline_rounded,
                        color: const Color(0xFF4CAF50),
                        selected: selectedIntensity == 0,
                        onTap: () => setModalState(() => selectedIntensity = 0),
                      ),
                      const SizedBox(height: 12),
                      _buildIntensityOption(
                        index: 1,
                        title: 'Getaran Sedang',
                        description: 'Dirasakan hampir semua orang. Benda kecil bergoyang, pintu berderit.',
                        icon: Icons.warning_amber_rounded,
                        color: const Color(0xFFFF9800),
                        selected: selectedIntensity == 1,
                        onTap: () => setModalState(() => selectedIntensity = 1),
                      ),
                      const SizedBox(height: 12),
                      _buildIntensityOption(
                        index: 2,
                        title: 'Getaran Kuat',
                        description: 'Sulit berdiri tegap. Barang berat bergeser, potensi kerusakan kecil pada bangunan.',
                        icon: Icons.flash_on_rounded,
                        color: const Color(0xFFF44336),
                        selected: selectedIntensity == 2,
                        onTap: () => setModalState(() => selectedIntensity = 2),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            if (_latestQuake != null) {
                              setState(() {
                                _latestQuake!.dirasakan = 'Dirasakan';
                              });
                            }
                            _showSuccessSnackbar(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF9800),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Kirim Laporan',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildIntensityOption({
    required int index,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? color : const Color(0xFFE2E8F0),
            width: selected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: selected ? color.withValues(alpha: 0.1) : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: selected ? color : const Color(0xFF64748B), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: selected ? color : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                      height: 1.3,
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

  void _showSuccessSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Laporan Terkirim! Kontribusi Anda membantu pemetaan skala getaran gempa.',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF16A34A), // Green
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildInfoBox(String value, String label, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
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
                  height: 1.4,
                ),
              ),
              if (subtext != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtext,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Riwayat Gempa',
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
                  MaterialPageRoute(
                    builder: (context) =>
                        RiwayatGempaPage(
                          quakes: _recentQuakes,
                          userPosition: _userPosition,
                        ),
                  ),
                );
              },
              child: const Text(
                'Lihat Semua',
                style: TextStyle(
                  color: Color(0xFF2196F3),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        if (_lastUpdated != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(
              children: [
                const Icon(Icons.sync, size: 10, color: Color(0xFF9E9E9E)),
                const SizedBox(width: 4),
                Text(
                  'Terakhir diperbarui: ${_lastUpdated!.hour.toString().padLeft(2, '0')}:${_lastUpdated!.minute.toString().padLeft(2, '0')}:${_lastUpdated!.second.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildRecentEarthquakes(BuildContext context) {
    if (_isLoadingRecentQuakes) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_recentQuakes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text("Tidak ada data riwayat gempa."),
        ),
      );
    }

    return Column(
      children: _recentQuakes.take(5).map((quake) {
        final magValue = double.tryParse(quake.magnitude) ?? 0.0;
        // All magnitude cards set to yellow as requested
        Color magColor = const Color(0xFFFFC107);

        return _buildHistoryItem(
          context: context,
          quake: quake,
          magColor: magColor,
        );
      }).toList(),
    );
  }

  Widget _buildHistoryItem({
    required BuildContext context,
    required GempaModel quake,
    required Color magColor,
  }) {
    final String date = quake.tanggal.split(' ').take(2).join(' ');
    final String time = quake.jam.replaceAll(' WIB', '');

    // Determine color coding based on magnitude: low (green), medium (orange/yellow), high (red)
    final double magVal = double.tryParse(quake.magnitude) ?? 0.0;
    Color magLevelColor;
    if (magVal < 4.0) {
      magLevelColor = const Color(0xFF4CAF50); // Rendah (Green)
    } else if (magVal < 6.0) {
      magLevelColor = const Color(0xFFFF9800); // Sedang (Orange/Yellow)
    } else {
      magLevelColor = const Color(0xFFF44336); // Tinggi (Red)
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: quake.isAnomali
            ? Border.all(color: Colors.red.shade300, width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
          if (quake.isAnomali)
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.1),
              blurRadius: 8,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FullscreenMapPage(gempa: quake),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Magnitude Badge
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: magLevelColor,
                      width: 2.0,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        quake.magnitude,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: magLevelColor,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        'MAG',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: magLevelColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quake.wilayah,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                          height: 1.3,
                        ),
                      ),
                      if (quake.isAnomali) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFFFCDD2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.warning_amber_rounded,
                                size: 12,
                                color: Color(0xFFD32F2F),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Anomali Terdeteksi',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD32F2F),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 12,
                            color: Color(0xFF9E9E9E),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$date, $time',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF757575),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.show_chart,
                            size: 12,
                            color: Color(0xFF9E9E9E),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            quake.kedalaman,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF757575),
                            ),
                          ),
                        ],
                      ),
                      if (quake.dirasakan.isNotEmpty &&
                          quake.dirasakan != '-') ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Dirasakan (MMI): ${quake.dirasakan}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInsuranceSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF757575),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
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
                backgroundColor: const Color(0xFF03A9F4),
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
}
