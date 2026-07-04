import 'package:flutter/material.dart';
import 'services/bmkg_service.dart';
import 'services/usgs_service.dart';
import 'services/anomali_service.dart';
import 'package:geolocator/geolocator.dart';
import 'gempa_detail.dart';
import 'fullscreen_map.dart';

class RiwayatGempaPage extends StatefulWidget {
  final List<GempaModel> quakes;
  final Position? userPosition;

  const RiwayatGempaPage({
    super.key,
    required this.quakes,
    this.userPosition,
  });

  @override
  State<RiwayatGempaPage> createState() => _RiwayatGempaPageState();
}

class _RiwayatGempaPageState extends State<RiwayatGempaPage> {
  int _selectedFilterIndex = 0; // 0: Terkini, 1: M >= 5, 2: Jarak Jauh, 3: Jarak Dekat, 4: Anomali
  List<GempaModel> _filteredQuakes = [];
  bool _isLoading = false;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _filteredQuakes = widget.quakes;
    _currentPosition = widget.userPosition;
    // Request position if not passed
    if (_currentPosition == null) {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    } catch (e) {
      print("Location fetch error: $e");
    }
  }

  Future<void> _fetchAndFilterData() async {
    setState(() => _isLoading = true);
    try {
      List<GempaModel> quakes;
      // 0: Terkini, 1: M >= 5, 2: Jarak Jauh, 3: Jarak Dekat, 4: Anomali
      if (_selectedFilterIndex == 0) {
        quakes = await UsgsService.fetchIndonesiaEarthquakes();
      } else if (_selectedFilterIndex == 1) {
        quakes = await BmkgService.fetchEarthquakeList();
      } else if (_selectedFilterIndex == 4) {
        final anomalies = await AnomaliService.fetchAnomaliTerkini();
        quakes = anomalies.map((a) => GempaModel(
          tanggal: a.tanggal,
          jam: a.jam,
          dateTime: a.dateTime,
          coordinates: a.coordinates,
          lintang: a.lintang,
          bujur: a.bujur,
          magnitude: a.magnitude,
          kedalaman: a.kedalaman,
          wilayah: a.wilayah,
          potensi: a.potensi,
          dirasakan: a.dirasakan,
          shakemap: a.shakemap,
          isAnomali: true,
        )).toList();
      } else {
        // Jarak Jauh / Dekat
        quakes = await UsgsService.fetchIndonesiaEarthquakes();
        if (_currentPosition != null) {
          quakes.sort((a, b) {
            double latA = double.tryParse(a.lintang) ?? 0;
            double lonA = double.tryParse(a.bujur) ?? 0;
            double latB = double.tryParse(b.lintang) ?? 0;
            double lonB = double.tryParse(b.bujur) ?? 0;

            double distA = Geolocator.distanceBetween(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              latA,
              lonA,
            );
            double distB = Geolocator.distanceBetween(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              latB,
              lonB,
            );

            if (_selectedFilterIndex == 2) {
              // Jarak Jauh: Descending
              return distB.compareTo(distA);
            } else {
              // Jarak Dekat: Ascending
              return distA.compareTo(distB);
            }
          });
        }
      }

      if (mounted) {
        setState(() {
          _filteredQuakes = quakes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
      }
    }
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildChip(0, 'Terkini'),
          _buildChip(1, 'M ≥ 5'),
          _buildChip(2, 'Jarak Jauh'),
          _buildChip(3, 'Jarak Dekat'),
          _buildChip(4, 'Anomali'),
        ],
      ),
    );
  }

  Widget _buildChip(int index, String label) {
    final bool isActive = _selectedFilterIndex == index;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (_selectedFilterIndex != index) {
            setState(() {
              _selectedFilterIndex = index;
            });
            _fetchAndFilterData();
          }
        },
        child: Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFE3F2FD) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? const Color(0xFF2196F3) : const Color(0xFFEEEEEE),
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF2196F3).withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFF2196F3) : const Color(0xFF757575),
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text(
          'Riwayat Gempa',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: _buildFilterChips(),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredQuakes.isEmpty
                    ? const Center(child: Text("Tidak ada data riwayat gempa."))
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _filteredQuakes.length,
                        itemBuilder: (context, index) {
                          final quake = _filteredQuakes[index];
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
                                                  color: const Color(0xFFFFF3E0),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Text(
                                                  'Dirasakan',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFFFF9800),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right, color: Color(0xFFE0E0E0)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
