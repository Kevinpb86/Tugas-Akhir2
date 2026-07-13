import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';

import '../main.dart';
import '../services/analisis_gempa_service.dart';
import '../models/analisis_gempa_model.dart';
import '../login.dart';
import '../akun.dart';

extension ColorAlphaPercent on Color {
  Color withAlphaPercent(double opacity) =>
      withAlpha((a * opacity).round().clamp(0, 255));
}

class AnalisisGempaPage extends StatefulWidget {
  const AnalisisGempaPage({super.key});

  @override
  State<AnalisisGempaPage> createState() => _AnalisisGempaPageState();
}

class _AnalisisGempaPageState extends State<AnalisisGempaPage> {
  final MapController _mapController = MapController();
  final String _currentCityName = 'Memuat lokasi...';

  EarthquakeNetwork? network;
  bool isLoading = true;
  String? errorMessage;
  double _mapZoom = 4.5;
  LatLng _mapCenter = const LatLng(-2.5, 118.0);
  EarthquakeNode? selectedNode;
  bool isFullScreen = false;
  bool showStatistics = false;

  // Statistik perhitungan
  int get totalEvents => network?.nodes.length ?? 0;
  int get mainshockCount =>
      network?.nodes.where((n) => n.prediction == null).length ?? 0;
  int get aftershockCount =>
      network?.nodes.where((n) => n.prediction == "Aftershock").length ?? 0;
  int get connectionsCount => network?.edges.length ?? 0;

  @override
  void initState() {
    super.initState();
    loadNetwork();
  }

  Future<void> loadNetwork() async {
    try {
      final data = await NetworkService.fetchNetwork();
      if (!mounted) return;
      setState(() {
        network = data;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage =
        'Gagal memuat data gempa. Periksa koneksi internet dan coba lagi.';
      });
    }
  }

  void _selectNode(EarthquakeNode node) {
    setState(() {
      selectedNode = node;
      _mapZoom = 6.0;
      _mapCenter = LatLng(node.latitude, node.longitude);
    });
    _mapController.move(_mapCenter, _mapZoom);
  }

  List<Marker> _buildMarkers() {
    if (network == null) return [];

    return network!.nodes.map((node) {
      final bool isAftershock = node.prediction == "Aftershock";
      final bool isLargeMainshock =
          !isAftershock && (node.magnitude != null && node.magnitude! >= 5.0);
      final bool isSmallMainshock =
          !isAftershock && (node.magnitude != null && node.magnitude! < 5.0);

      double size = 36;
      if (node.magnitude != null) {
        if (node.magnitude! >= 5.0) {
          size = 48;
        } else if (node.magnitude! >= 3.0) {
          size = 40;
        }
      }

      Color markerColor;
      if (isAftershock) {
        markerColor = Colors.red;
      } else if (isLargeMainshock) {
        markerColor = Colors.orange;
      } else if (isSmallMainshock) {
        markerColor = Colors.amber;
      } else {
        markerColor = Colors.grey;
      }

      final bool isSelected = selectedNode?.id == node.id;

      return Marker(
        point: LatLng(node.latitude, node.longitude),
        width: size,
        height: size,
        child: GestureDetector(
          onTap: () {
            _selectNode(node);
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Event #${node.id} dipilih"),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isSelected)
                Container(
                  width: size + 14,
                  height: size + 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlphaPercent(0.65),
                  ),
                ),
              Icon(Icons.location_on, color: markerColor, size: size),
              if (node.magnitude != null && node.magnitude! >= 5.0)
                Container(
                  width: size + 10,
                  height: size + 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.red.withAlphaPercent(0.3),
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
              color: Colors.white.withAlpha(235),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withAlpha(102)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
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
                _legendItem(const Color(0xFFFF9800), 'Mainshock ≥ 5.0'),
                _legendItem(const Color(0xFFFFB74D), 'Mainshock < 5.0'),
                _legendItem(const Color(0xFFF44336), 'Aftershock'),
                const SizedBox(height: 4),
                _legendItem(
                  Colors.transparent,
                  '⭕ Magnitudo ≥ 5.0',
                  isCircle: true,
                ),
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
                border: Border.all(
                  color: Colors.red.withAlphaPercent(0.3),
                  width: 2,
                ),
              ),
            )
          else
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 11, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    final node = selectedNode!;
    final magnitude = node.magnitude?.toStringAsFixed(1) ?? "-";
    final depth = node.depth != null
        ? "${node.depth!.toStringAsFixed(0)} km"
        : "-";
    final probability = node.probability != null
        ? "${(node.probability! * 100).toStringAsFixed(2)}%"
        : "-";
    final isAftershock = node.prediction == "Aftershock";
    final riskLevel = _getRiskLevel(node.magnitude);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withAlphaPercent(0.95),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withAlphaPercent(0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlphaPercent(0.15),
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
                            color: isAftershock
                                ? Colors.red.shade50
                                : Colors.orange.shade50,
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: riskLevel.color.withAlphaPercent(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: riskLevel.color.withAlphaPercent(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            riskLevel.icon,
                            color: riskLevel.color,
                            size: 20,
                          ),
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isAftershock
                                  ? Colors.red.withAlphaPercent(0.1)
                                  : Colors.green.withAlphaPercent(0.1),
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
    );
  }

  RiskLevel _getRiskLevel(double? magnitude) {
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

  Widget _buildHeader(BuildContext context, bool isNarrow) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment:
      isNarrow ? CrossAxisAlignment.start : CrossAxisAlignment.center,
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
                  Flexible(
                    child: const Text(
                      'Amanin',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
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
                    final displayCity = cityName.isNotEmpty
                        ? cityName
                        : _currentCityName;
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
        Flexible(
          child: Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
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
                      color: Colors.black.withAlphaPercent(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.bar_chart,
                    color: showStatistics
                        ? const Color(0xFF00BCD4)
                        : Colors.grey.shade600,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      showStatistics = !showStatistics;
                    });
                  },
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlphaPercent(0.05),
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
                            color: Colors.black.withAlphaPercent(0.05),
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
                            color: const Color(0xFF00BCD4).withAlphaPercent(0.3),
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
        ),
      ],
    );
  }

  Widget _buildSimpleStatBox(
      String label,
      String value,
      Color color,
      IconData icon,
      ) {
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
              color: color.withAlphaPercent(0.1),
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

  Widget _buildEventTile(EarthquakeNode node) {
    final bool isSelected = selectedNode?.id == node.id;
    final String eventTime = DateFormat(
      'dd MMM yyyy • HH:mm',
    ).format(node.eventTime.toLocal());
    final String magnitudeText = node.magnitude != null
        ? node.magnitude!.toStringAsFixed(1)
        : '-';
    final Color statusColor = node.prediction == 'Aftershock'
        ? Colors.red
        : Colors.orange;
    final String statusText = node.prediction ?? 'Mainshock';

    return InkWell(
      onTap: () => _selectNode(node),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.blue.shade100 : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlphaPercent(0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: statusColor.withAlphaPercent(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  magnitudeText,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    node.wilayah ?? 'Lokasi tidak diketahui',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    eventTime,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withAlphaPercent(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventList() {
    if (network == null || network!.nodes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Text('Tidak ada data gempa tersedia.'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daftar Event Gempa',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: network!.nodes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final node = network!.nodes[index];
            return _buildEventTile(node);
          },
        ),
      ],
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

    if (errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.signal_wifi_off, size: 60, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                      errorMessage = null;
                    });
                    loadNetwork();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BCD4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Text('Muat Ulang', style: TextStyle(fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isNarrow = screenWidth < 420;

    final double mapHeight = isFullScreen
        ? (screenHeight - MediaQuery.of(context).padding.top - 120)
        .clamp(280.0, screenHeight * 0.78)
        : 340;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: _buildHeader(context, isNarrow),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              height: mapHeight,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(isFullScreen ? 0 : 20),
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _mapCenter,
                        initialZoom: _mapZoom,
                        minZoom: 2,
                        maxZoom: 18,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all,
                        ),
                        onPositionChanged: (position, _) {
                          if (_mapZoom != position.zoom) {
                            setState(() {
                              _mapZoom = position.zoom;
                              _mapCenter = position.center;
                            });
                          }
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.amanin.app',
                        ),
                        MarkerLayer(markers: _buildMarkers()),
                      ],
                    ),
                    _buildLegend(),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Column(
                        children: [
                          if (isFullScreen)
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: FloatingActionButton.small(
                                heroTag: 'btn_exit_fs',
                                backgroundColor: Colors.white.withAlphaPercent(0.95),
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
                          if (!isFullScreen)
                            FloatingActionButton.small(
                              heroTag: 'btn_enter_fs',
                              backgroundColor: Colors.white.withAlphaPercent(0.95),
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
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            child: FloatingActionButton.small(
                              heroTag: 'btn_zoom_in',
                              backgroundColor: Colors.white.withAlphaPercent(0.95),
                              onPressed: () {
                                setState(() {
                                  _mapZoom = (_mapZoom + 0.5).clamp(2.0, 18.0);
                                });
                                _mapController.move(_mapCenter, _mapZoom);
                              },
                              child: const Icon(
                                Icons.add,
                                color: Color(0xFF00BCD4),
                                size: 20,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            child: FloatingActionButton.small(
                              heroTag: 'btn_zoom_out',
                              backgroundColor: Colors.white.withAlphaPercent(0.95),
                              onPressed: () {
                                setState(() {
                                  _mapZoom = (_mapZoom - 0.5).clamp(2.0, 18.0);
                                });
                                _mapController.move(_mapCenter, _mapZoom);
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
                    if (selectedNode != null)
                      Positioned(
                        bottom: 20,
                        left: 16,
                        right: 16,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: mapHeight * 0.55),
                          child: SingleChildScrollView(
                            child: _buildInfoCard(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            if (!isFullScreen)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 12,
                    bottom: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildEventList(),
                      const SizedBox(height: 18),
                      if (showStatistics)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlphaPercent(0.04),
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
                                crossAxisCount: isNarrow ? 1 : 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                childAspectRatio: isNarrow ? 3.6 : 2.4,
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
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlphaPercent(0.04),
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
                                      colors: [
                                        Color(0xFF00BCD4),
                                        Color(0xFF26C6DA),
                                      ],
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
                                border: Border.all(
                                  color: Colors.amber.shade200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.amber.shade700,
                                    size: 18,
                                  ),
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
                                icon: const Icon(
                                  Icons.fullscreen_rounded,
                                  size: 18,
                                ),
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
          ],
        ),
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

  static const extreme = RiskLevel._(
    '⚠️ Bahaya Ekstrem',
    Colors.red,
    Icons.warning,
  );
  static const high = RiskLevel._(
    '⚠️ Bahaya Tinggi',
    Colors.orange,
    Icons.error,
  );
  static const medium = RiskLevel._(
    '⚠️ Bahaya Sedang',
    Colors.amber,
    Icons.info,
  );
  static const low = RiskLevel._(
    '✅ Bahaya Rendah',
    Colors.green,
    Icons.check_circle,
  );
}
