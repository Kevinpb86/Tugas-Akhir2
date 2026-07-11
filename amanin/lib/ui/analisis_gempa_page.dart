import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../main.dart';
import '../services/analisis_gempa_service.dart';
import '../models/analisis_gempa_model.dart';
import '../login.dart';
import '../akun.dart';

class AnalisisGempaPage extends StatefulWidget {
  const AnalisisGempaPage({super.key});

  @override
  State<AnalisisGempaPage> createState() => _AnalisisGempaPageState();
}

class _AnalisisGempaPageState extends State<AnalisisGempaPage> {
  EarthquakeNetwork? network;
  bool isLoading = true;
  EarthquakeNode? selectedNode;
  bool isFullScreen = false;
  bool showStatistics = false;

  final String _currentCityName = 'Memuat lokasi...';

  // Statistik perhitungan
  int get totalEvents => network?.nodes.length ?? 0;
  int get mainshockCount => network?.nodes.where((n) => n.prediction == null).length ?? 0;
  int get aftershockCount => network?.nodes.where((n) => n.prediction == "Aftershock").length ?? 0;
  int get connectionsCount => network?.edges.length ?? 0;

  EarthquakeNode? findNode(int id) {
    try {
      return network!.nodes.firstWhere(
            (node) => node.id == id,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    loadNetwork();
  }

  Future<void> loadNetwork() async {
    try {
      final data = await NetworkService.fetchNetwork();
      setState(() {
        network = data;
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Marker> _buildMarkers() {
    if (network == null) return [];

    return network!.nodes.map((node) {
      final bool isAftershock = node.prediction == "Aftershock";
      final bool isMainshock = node.prediction == null;

      double size = 36;
      if (node.magnitude != null) {
        if (node.magnitude! >= 5.0) size = 48;
        else if (node.magnitude! >= 3.0) size = 40;
      }

      Color markerColor;
      if (isAftershock) {
        markerColor = Colors.red;
      } else if (isMainshock) {
        markerColor = Colors.orange;
      } else {
        markerColor = Colors.grey;
      }

      return Marker(
        point: LatLng(
          node.latitude,
          node.longitude,
        ),
        width: size,
        height: size,
        child: GestureDetector(
          onTap: () {
            setState(() {
              selectedNode = node;
            });
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Event #${node.id} selected"),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.location_on,
                color: markerColor,
                size: size,
              ),
              if (node.magnitude != null && node.magnitude! >= 5.0)
                Container(
                  width: size + 10,
                  height: size + 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }).toList();
  }

  // LEGEND DI ATAS KANAN
  Widget _buildLegend() {
    return Positioned(
      top: isFullScreen ? 80 : 10,
      right: 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '📊 Legenda',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 8),
                _legendItem(const Color(0xFFFF9800), 'Mainshock (≥5.0)'),
                _legendItem(const Color(0xFFFF6B00), 'Mainshock (<5.0)'),
                _legendItem(const Color(0xFFF44336), 'Aftershock'),
                const SizedBox(height: 4),
                _legendItem(Colors.transparent, '⭕ Magnitude ≥ 5.0', isCircle: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String text, {bool isCircle = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isCircle)
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red.withOpacity(0.3), width: 2),
              ),
            )
          else
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    final node = selectedNode!;
    final magnitude = node.magnitude?.toStringAsFixed(1) ?? "-";
    final depth = node.depth != null ? "${node.depth!.toStringAsFixed(0)} km" : "-";
    final probability = node.probability != null
        ? "${(node.probability! * 100).toStringAsFixed(2)}%"
        : "-";
    final isAftershock = node.prediction == "Aftershock";
    final riskLevel = _getRiskLevel(node.magnitude, node.depth);

    return Positioned(
      bottom: 20,
      left: 16,
      right: 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 24,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isAftershock ? Colors.red.shade50 : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.sensors,
                              color: isAftershock ? Colors.red : Colors.orange,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Event #${node.id}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                node.wilayah ?? "Lokasi tidak diketahui",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => selectedNode = null),
                      ),
                    ],
                  ),
                ),

                // Body
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Risk Level Indicator
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: riskLevel.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: riskLevel.color.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(riskLevel.icon, color: riskLevel.color, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                riskLevel.label,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: riskLevel.color,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isAftershock ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                node.prediction ?? "Mainshock",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isAftershock ? Colors.red : Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Info Grid
                      Row(
                        children: [
                          Expanded(
                            child: _infoItem(
                              Icons.analytics,
                              "Magnitudo",
                              "$magnitude Mw",
                              Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _infoItem(
                              Icons.unfold_more,
                              "Kedalaman",
                              depth,
                              Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _infoItem(
                              Icons.timeline,
                              "Probabilitas",
                              probability,
                              Colors.purple,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _infoItem(
                              Icons.access_time,
                              "Waktu (UTC)",
                              node.eventTime.toIso8601String().substring(0, 16),
                              Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Actions
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Aksi berbagi
                              },
                              icon: const Icon(Icons.share, size: 18),
                              label: const Text('Bagikan'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade100,
                                foregroundColor: Colors.grey.shade800,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Aksi laporan
                              },
                              icon: const Icon(Icons.warning, size: 18),
                              label: const Text('Laporkan'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade50,
                                foregroundColor: Colors.red,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
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
          ),
        ),
      ),
    );
  }

  RiskLevel _getRiskLevel(double? magnitude, double? depth) {
    if (magnitude == null) return RiskLevel.low;

    if (magnitude >= 6.0) return RiskLevel.extreme;
    if (magnitude >= 5.0) return RiskLevel.high;
    if (magnitude >= 4.0) return RiskLevel.medium;
    return RiskLevel.low;
  }

  Widget _infoItem(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BCD4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.waves,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Amanin',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'BETA',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7FA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ValueListenableBuilder<String>(
                  valueListenable: userCityNameNotifier,
                  builder: (context, cityName, _) {
                    final displayCity = cityName.isNotEmpty ? cityName : _currentCityName;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Color(0xFF00BCD4),
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          displayCity,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF00BCD4),
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            // Statistik Toggle
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.bar_chart,
                  color: showStatistics ? const Color(0xFF00BCD4) : Colors.grey.shade600,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    showStatistics = !showStatistics;
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none,
                      color: Color(0xFF1A1A1A),
                      size: 22,
                    ),
                    onPressed: () {},
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF5252),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ValueListenableBuilder<bool>(
              valueListenable: isLoggedInNotifier,
              builder: (context, isLoggedIn, _) {
                if (isLoggedIn) {
                  return Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
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
                      borderRadius: BorderRadius.circular(10),
                      child: const Center(
                        child: Icon(
                          Icons.person_outline,
                          color: Color(0xFF1A1A1A),
                          size: 22,
                        ),
                      ),
                    ),
                  );
                }
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00BCD4), Color(0xFF26C6DA)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00BCD4).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Masuk',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
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

  Widget _buildSimpleStatBox(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: Colors.black45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Memuat data gempa...',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    double screenHeight = MediaQuery.of(context).size.height;
    double collapsedHeight = screenHeight * 0.45;
    double bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      body: Stack(
        children: [
          // Peta
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            margin: EdgeInsets.only(
              top: isFullScreen ? 0 : MediaQuery.of(context).padding.top + 90,
            ),
            height: isFullScreen ? screenHeight : collapsedHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isFullScreen ? 0 : 20),
              child: Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: const LatLng(-2.5, 118.0),
                      initialZoom: 4.5,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.amanin.app',
                      ),
                      MarkerLayer(markers: _buildMarkers()),
                    ],
                  ),
                  // Legend di Atas Kanan
                  _buildLegend(),

                  // Tombol Fullscreen/Exit di Kanan Bawah
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Column(
                      children: [
                        // Tombol Exit Fullscreen (hanya muncul saat fullscreen)
                        if (isFullScreen)
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: FloatingActionButton.small(
                              heroTag: "btn_exit_fs",
                              backgroundColor: Colors.white.withOpacity(0.95),
                              onPressed: () {
                                setState(() {
                                  isFullScreen = false;
                                });
                              },
                              child: const Icon(
                                Icons.fullscreen_exit,
                                color: Color(0xFF00BCD4),
                                size: 20,
                              ),
                            ),
                          ),

                        // Tombol Fullscreen (muncul saat tidak fullscreen)
                        if (!isFullScreen)
                          FloatingActionButton.small(
                            heroTag: "btn_enter_fs",
                            backgroundColor: Colors.white.withOpacity(0.95),
                            onPressed: () {
                              setState(() {
                                isFullScreen = true;
                              });
                            },
                            child: const Icon(
                              Icons.fullscreen,
                              color: Color(0xFF00BCD4),
                              size: 20,
                            ),
                          ),

                        // Tombol Zoom In
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          child: FloatingActionButton.small(
                            heroTag: "btn_zoom_in",
                            backgroundColor: Colors.white.withOpacity(0.95),
                            onPressed: () {
                              // Fungsi zoom in
                            },
                            child: const Icon(
                              Icons.add,
                              color: Color(0xFF00BCD4),
                              size: 20,
                            ),
                          ),
                        ),

                        // Tombol Zoom Out
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          child: FloatingActionButton.small(
                            heroTag: "btn_zoom_out",
                            backgroundColor: Colors.white.withOpacity(0.95),
                            onPressed: () {
                              // Fungsi zoom out
                            },
                            child: const Icon(
                              Icons.remove,
                              color: Color(0xFF00BCD4),
                              size: 20,
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

          // Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(isFullScreen ? 0.92 : 1.0),
                gradient: isFullScreen ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.white.withOpacity(0)],
                ) : null,
              ),
              child: _buildHeader(context),
            ),
          ),

          // Main Content (when not fullscreen)
          if (!isFullScreen)
            Positioned(
              top: collapsedHeight + MediaQuery.of(context).padding.top + 100,
              left: 16,
              right: 16,
              bottom: 20,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistics Section
                    if (showStatistics)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '📊 Statistik Kejadian',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            GridView.count(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                _buildSimpleStatBox(
                                  'Total Event',
                                  '$totalEvents',
                                  const Color(0xFF00BCD4),
                                  Icons.sensors,
                                ),
                                _buildSimpleStatBox(
                                  'Mainshock',
                                  '$mainshockCount',
                                  Colors.orange,
                                  Icons.sensors,
                                ),
                                _buildSimpleStatBox(
                                  'Aftershock',
                                  '$aftershockCount',
                                  Colors.red,
                                  Icons.waves,
                                ),
                                _buildSimpleStatBox(
                                  'Keterkaitan',
                                  '$connectionsCount',
                                  Colors.purple,
                                  Icons.link,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 12),

                    // Info Panel
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 20,
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
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF00BCD4), Color(0xFF26C6DA)],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.network_check,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Text(
                                  'Analisis Jaringan Seismik',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Sistem menganalisis keterkaitan antar kejadian gempa menggunakan algoritma graph untuk mengidentifikasi pola seismik dan mengklasifikasikan gempa utama (mainshock) dan gempa susulan (aftershock).',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.amber.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.amber.shade700, size: 18),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    'Klik marker di peta untuk melihat detail kejadian',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  isFullScreen = true;
                                });
                              },
                              icon: const Icon(Icons.fullscreen_rounded, size: 18),
                              label: const Text(
                                'Lihat Peta Fullscreen',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00BCD4),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
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

          // Info Card - dengan padding bottom untuk menghindari navigation bar
          if (selectedNode != null)
            Positioned(
              bottom: 20 + bottomPadding, // Tambahkan padding bottom
              left: 16,
              right: 16,
              child: _buildInfoCard(),
            ),
        ],
      ),
    );
  }
}

// Risk Level Helper Class
class RiskLevel {
  final String label;
  final Color color;
  final IconData icon;

  const RiskLevel._(this.label, this.color, this.icon);

  static const extreme = RiskLevel._('⚠️ Bahaya Ekstrem', Colors.red, Icons.warning);
  static const high = RiskLevel._('⚠️ Bahaya Tinggi', Colors.orange, Icons.error);
  static const medium = RiskLevel._('⚠️ Bahaya Sedang', Colors.amber, Icons.info);
  static const low = RiskLevel._('✅ Bahaya Rendah', Colors.green, Icons.check_circle);
}