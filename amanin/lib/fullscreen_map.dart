import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'services/bmkg_service.dart';
import 'utils/earthquake_map.dart';

class FullscreenMapPage extends StatefulWidget {
  final GempaModel gempa;

  const FullscreenMapPage({super.key, required this.gempa});

  @override
  State<FullscreenMapPage> createState() => _FullscreenMapPageState();
}

class _FullscreenMapPageState extends State<FullscreenMapPage> {
  String _distanceText = 'Menghitung jarak...';

  @override
  void initState() {
    super.initState();
    _calculateDistance();
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
        desiredAccuracy: LocationAccuracy.medium,
      );

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
          cityName = place.subAdministrativeArea ?? place.locality ?? 'lokasi Anda';
          // Clean up "Kabupaten" or "Kota" prefix if needed
          cityName = cityName.replaceAll('Kabupaten ', '').replaceAll('Kota ', '');
        }
      } catch (e) {
        // Fallback for Web using OpenStreetMap Nominatim API
        try {
          final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}');
          final response = await http.get(url, headers: {'User-Agent': 'AmaninApp/1.0'});
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            if (data['address'] != null) {
              cityName = data['address']['city'] ?? data['address']['town'] ?? data['address']['county'] ?? data['address']['state'] ?? 'lokasi Anda';
              cityName = cityName.replaceAll('Kabupaten ', '').replaceAll('Kota ', '');
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
            ),
          ),
          
          // 2. Top Right Bagikan Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: GestureDetector(
              onTap: () {
                final gempa = widget.gempa;
                final String shareText = 'Info Gempa dirasakan Mag:${gempa.magnitude}, ${gempa.tanggal} ${gempa.jam.replaceAll(' WIB', '')} WIB, Lok:${gempa.lintang}, ${gempa.bujur} (${gempa.wilayah}), Kedlmn:${gempa.kedalaman} ::AMANIN\nInformasi selengkapnya lihat di\nhttps://amanin.app/';
                Share.share(shareText);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    )
                  ]
                ),
                child: Row(
                  children: [
                    const Icon(Icons.ios_share, size: 16, color: Color(0xFF1A1A1A)),
                    const SizedBox(width: 8),
                    Text(
                      'Bagikan',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                      )
                    )
                  ],
                )
              ),
            ),
          ),

          // 3. Top Left Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
                  ]
                ),
                child: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 4))
                        ]
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
                              _buildStatItem(Icons.show_chart, Colors.red, widget.gempa.magnitude, 'Magnitude'),
                              _buildStatItem(Icons.waves, Colors.green, widget.gempa.kedalaman, 'Kedalaman'),
                              _buildStatItem(Icons.location_on_outlined, Colors.orange, 'Lat $lat\nLon $lon', ''),
                            ],
                          )
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
                          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 4))
                        ]
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(Icons.access_time, 'Waktu :', '${widget.gempa.tanggal}, ${widget.gempa.jam} WIB'),
                          const SizedBox(height: 16),
                          _buildDetailRow(Icons.my_location, 'Lokasi Gempa', widget.gempa.wilayah),
                          const SizedBox(height: 16),
                          _buildDetailRow(Icons.route, 'Jarak', _distanceText),
                          
                          const SizedBox(height: 24),
                          
                          // Orange Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF9800), // Orange
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
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
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, Color iconColor, String value, String label) {
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
        ]
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFFFFB300), size: 20), // Yellow/Orange icon
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
        )
      ],
    );
  }
}
