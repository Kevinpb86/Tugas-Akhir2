import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'services/bmkg_service.dart';
import 'utils/earthquake_map.dart';
import 'gempa_detail.dart';

class FullscreenMapPage extends StatefulWidget {
  final GempaModel gempa;
  final bool isAnomali;

  const FullscreenMapPage({
    super.key,
    required this.gempa,
    this.isAnomali = false,
  });

  @override
  State<FullscreenMapPage> createState() => _FullscreenMapPageState();
}

class _FullscreenMapPageState extends State<FullscreenMapPage> {
  String _distanceText = 'Menghitung jarak...';
  LatLng? _userLatLng;

  bool _showNotification = false;
  double _progressValue = 1.0;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();
    _calculateDistance();

    if (widget.isAnomali) {
      // Tunggu sebentar sebelum memunculkan notifikasi agar transisi smooth
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _showNotification = true;
          });
          _startNotificationTimers();
        }
      });
    }
  }

  void _startNotificationTimers() {
    _progressValue = 1.0;
    const duration = const Duration(seconds: 2);
    const tick = const Duration(milliseconds: 16);
    final int totalTicks = duration.inMilliseconds ~/ tick.inMilliseconds;
    int currentTick = 0;

    _progressTimer = Timer.periodic(tick, (timer) {
      if (mounted) {
        setState(() {
          currentTick++;
          _progressValue = 1.0 - (currentTick / totalTicks);
          if (currentTick >= totalTicks) {
            _showNotification = false;
            timer.cancel();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }

  Future<void> _calculateDistance() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _distanceText = 'GPS tidak aktif';
        });
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _distanceText = 'Izin lokasi ditolak';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _distanceText = 'Izin lokasi ditolak permanen';
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      print(
        "[FullscreenMap] GPS coordinates: lat=${position.latitude}, lon=${position.longitude}, accuracy=${position.accuracy}m",
      );

      if (mounted) {
        setState(() {
          _userLatLng = LatLng(position.latitude, position.longitude);
        });
      }

      // Parse earthquake coordinates
      final coords = widget.gempa.coordinates.split(',');
      if (coords.length < 2) return;

      final eqLat = double.tryParse(coords[0]) ?? 0.0;
      final eqLon = double.tryParse(coords[1]) ?? 0.0;

      // Calculate distance in meters
      double distanceInMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        eqLat,
        eqLon,
      );

      int distanceInKm = (distanceInMeters / 1000).round();

      // Reverse geocoding for city name
      String cityName = 'lokasi Anda';
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          print(
            "[FullscreenMap] Geocoding result: subLocality=${place.subLocality}, locality=${place.locality}, subAdmin=${place.subAdministrativeArea}",
          );
          cityName =
              place.locality ??
              place.subLocality ??
              place.subAdministrativeArea ??
              'lokasi Anda';
          // Clean up "Kabupaten" or "Kota" prefix if needed
          cityName = cityName
              .replaceAll('Kabupaten ', '')
              .replaceAll('Kota ', '')
              .replaceAll(' City', '')
              .replaceAll('Kecamatan ', '')
              .replaceAll('Kelurahan ', '')
              .replaceAll('Desa ', '');
        }
      } catch (e) {
        print(
          "[FullscreenMap] Geocoding package error: $e, falling back to Nominatim",
        );
        // Fallback for Web using OpenStreetMap Nominatim API
        try {
          final url = Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=16&addressdetails=1',
          );
          final response = await http.get(
            url,
            headers: {'User-Agent': 'AmaninApp/1.0'},
          );
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            print("[FullscreenMap] Nominatim full address: ${data['address']}");
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
                  'lokasi Anda';
              cityName = cityName
                  .replaceAll('Kabupaten ', '')
                  .replaceAll('Kota ', '')
                  .replaceAll('Kecamatan ', '')
                  .replaceAll('Kelurahan ', '')
                  .replaceAll('Desa ', '');
              print("[FullscreenMap] Final city name: $cityName");
            }
          }
        } catch (fallbackError) {
          print("Nominatim fallback error: $fallbackError");
        }
      }

      if (mounted) {
        setState(() {
          _distanceText = '$distanceInKm KM dari $cityName';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _distanceText = 'Gagal menghitung jarak';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Parse coordinates to display Lat/Lon
    final coords = widget.gempa.coordinates.split(',');
    final lat = coords.isNotEmpty ? coords[0] : '-';
    final lon = coords.length > 1 ? coords[1] : '-';

    return Scaffold(
      backgroundColor: const Color(0xFFE2E8F0),
      body: Stack(
        children: [
          // 1. Map Layer
          Positioned.fill(
            child: EarthquakeMap(
              coordinates: widget.gempa.coordinates,
              initialZoom: 7.0,
              userLocation: _userLatLng,
            ),
          ),

          // 2. Top Right Bagikan Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  final gempa = widget.gempa;
                  final String shareText =
                      'Info Gempa dirasakan Mag:${gempa.magnitude}, ${gempa.tanggal} ${gempa.jam.replaceAll(' WIB', '')} WIB, Lok:${gempa.lintang}, ${gempa.bujur} (${gempa.wilayah}), Kedlmn:${gempa.kedalaman} ::AMANIN\nInformasi selengkapnya lihat di\nhttps://amanin.app/';
                  Share.share(shareText);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.ios_share,
                        size: 16,
                        color: Color(0xFF1A1A1A),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Bagikan',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. Top Left Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
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
                  child: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
                ),
              ),
            ),
          ),

          // 4. Bottom Sheets
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Sheet 1: Real-time Stats
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Handle line
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Gempabumi Real-time',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                Icons.show_chart,
                                Colors.red,
                                widget.gempa.magnitude,
                                'Magnitude',
                              ),
                              _buildStatItem(
                                Icons.waves,
                                Colors.green,
                                widget.gempa.kedalaman,
                                'Kedalaman',
                              ),
                              _buildStatItem(
                                Icons.location_on_outlined,
                                Colors.orange,
                                'Lat $lat\nLon $lon',
                                '',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Sheet 2: Details & Button
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(
                            Icons.access_time,
                            'Waktu :',
                            '${widget.gempa.tanggal}, ${widget.gempa.jam} WIB',
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            Icons.my_location,
                            'Lokasi Gempa',
                            widget.gempa.wilayah,
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow(Icons.route, 'Jarak', _distanceText),

                          const SizedBox(height: 24),

                          // Orange Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _showFeltReportBottomSheet(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFFFF9800,
                                ), // Orange
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Saya juga merasakannya',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
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

          // 5. In-App Popup Notification (Top)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            top: _showNotification
                ? MediaQuery.of(context).padding.top + 16
                : -150,
            left: 20,
            right: 20,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (details.primaryDelta! < -5) {
                    // Swipe up detected
                    setState(() {
                      _showNotification = false;
                    });
                    _progressTimer?.cancel();
                  }
                },
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.red.shade600,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Status Waspada',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.red.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Pola kekuatan dan kedalaman gempa ini tidak biasa',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: const Color(0xFF424242),
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Progress Bar Timer
                        LinearProgressIndicator(
                          value: _progressValue,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.red.shade400,
                          ),
                          minHeight: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    Color iconColor,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 4),
            Text(
              value.split('\n').first,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
        if (value.contains('\n')) ...[
          Text(
            value.split('\n')[1],
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
            ),
            textAlign: TextAlign.center,
          ),
        ],
        if (label.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: const Color(0xFFFFB300),
          size: 20,
        ), // Yellow/Orange icon
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF757575),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ),
      ],
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
                      Text(
                        'Laporkan Getaran Gempa',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kontribusi Anda sangat membantu kami memetakan tingkat keparahan dampak gempa bumi.',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
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
                            setState(() {
                              widget.gempa.dirasakan = 'Dirasakan';
                            });
                            _showSuccessSnackbar(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF9800),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Kirim Laporan',
                            style: GoogleFonts.poppins(
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
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: selected ? color : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: const Color(0xFF64748B),
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
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Laporan Terkirim! Kontribusi Anda membantu pemetaan skala getaran gempa.',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
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
}
