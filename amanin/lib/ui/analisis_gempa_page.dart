import 'package:flutter/material.dart';
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

  final String _currentCityName = 'Memuat lokasi...';

  // Helper Function untuk node lookup
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

  // Inisiasi Data Gempa
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

  // Inisiasi Data Gempa
  List<Marker> _buildMarkers() {
    if (network == null) return [];

    // final centers = getClusterCenters();

    return network!.nodes.map((node) {
      final bool isAftershock = node.prediction == "Aftershock";
      final bool isMainshock = node.prediction == null;

      /*
      final bool isCenter =
      centers.contains(node.id);

      final bool isAftershock =
          node.prediction == "Aftershock";
      */

      Color markerColor;

      /*
      if (isCenter) {
        markerColor = Colors.purple;
      } else if (isAftershock) {
        markerColor = Colors.red;
      } else {
        markerColor = Colors.orange;
      }
      */
      if (isAftershock) {
        markerColor = Colors.red;
      } else {
        markerColor = Colors.orange; // mainshock / unknown
      }

      return Marker(
        point: LatLng(
          node.latitude,
          node.longitude,
        ),
        width: 40,
        height: 40,

        child: GestureDetector(
          onTap: () {
            setState(() {
              selectedNode = node;
            });

            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Event ${node.id} selected"),
                duration: const Duration(
                    seconds: 1), // Agar tidak terlalu lama munculnya
              ),
            );
          },

          child: Icon(
            Icons.location_on,
            color: markerColor,
            size: 36,
          ),
        ),
      );
    }).toList();
  }

  /* Dimatiakn dulu untuk iterasi 1
  // Inisiasi Cluster Gempa
  Set<int> getClusterCenters() {
    if (network == null) return {};

    return network!.edges
        .map((e) => e.source)
        .toSet();
  }


  // Polylin Bulider
  List<Polyline> _buildPolylines() {
    if (network == null) return [];

    List<Polyline> lines = [];

    for (final edge in network!.edges) {
      final sourceNode = findNode(edge.source);
      final targetNode = findNode(edge.target);

      if (sourceNode == null || targetNode == null) {
        continue;
      }

      lines.add(
        Polyline(
          points: [
            LatLng(
              sourceNode.latitude,
              sourceNode.longitude,
            ),
            LatLng(
              targetNode.latitude,
              targetNode.longitude,
            ),
          ],
          strokeWidth: 2.5,
          color: Colors.deepPurple,
        ),
      );
    }

    return lines;
  }
  */

  // Widget
  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [

          const Text(
            "Legenda",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          _legendItem(Colors.orange, "Mainshock / Event"),
          _legendItem(Colors.red, "Aftershock"),
        ],
      ),
    );
  }

  // helper widget
  Widget _legendItem(Color color,
      String text,) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 3,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
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
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Widget Info Card
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // HEADER
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.sensors, color: Colors.blueAccent),
                    const SizedBox(width: 8),
                    Text(
                      "Detail Event #${node.id}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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

          const Divider(),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // MAG + DEPTH
                Row(
                  children: [
                    _infoBadge(
                        Icons.analytics, "Mag: $magnitude", Colors.orange),
                    const SizedBox(width: 12),
                    _infoBadge(
                        Icons.unfold_more, "Depth: $depth", Colors.blueGrey),
                  ],
                ),

                const SizedBox(height: 16),

                _infoRow(Icons.location_on, "Wilayah", node.wilayah ?? "-"),

                const SizedBox(height: 10),

                _infoRow(
                  Icons.access_time_filled,
                  "Waktu (UTC)",
                  node.eventTime.toIso8601String(),
                ),

                const SizedBox(height: 12),

                // PREDIKSI BOX
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isAftershock ? Colors.red.shade50 : Colors.green
                        .shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isAftershock ? Colors.red.shade100 : Colors.green
                          .shade100,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.psychology,
                        color: isAftershock ? Colors.red : Colors.green,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Prediksi: ${node.prediction ?? "Mainshock"}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isAftershock
                                    ? Colors.red.shade900
                                    : Colors.green.shade900,
                              ),
                            ),
                            Text(
                              "Probabilitas: $probability",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget untuk Badge (Magnitude/Depth)
  Widget _infoBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

// Helper widget untuk Baris Informasi
  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Text(
                value,
                style: const TextStyle(fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Header
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
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
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


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // 1. LAPISAN PETA (Full Screen)
          Positioned.fill(
            child: FlutterMap(
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
          ),

          // 2. LAPISAN HEADER (Ditinggikan dan Gradasi Halus)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery
                    .of(context)
                    .padding
                    .top + 10,
                left: 16,
                right: 16,
                bottom: 60, // PERUBAHAN: Ditinggikan agar gradasi lebih luas
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(1.0), // Solid di atas
                    Colors.white.withOpacity(0.9), // Sedikit transparan
                    Colors.white.withOpacity(0.0), // Menghilang total
                  ],
                  // PERUBAHAN: 0.0-0.6 tetap putih, baru mulai pudar di 0.6 ke atas
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
              child: _buildHeader(context),
            ),
          ),

          // 3. LEGENDA (Diturunkan agar tidak menabrak header)
          Positioned(
            top: MediaQuery
                .of(context)
                .padding
                .top + 110,
            right: 16,
            child: _buildLegend(),
          ),

          // 4. INFO CARD
          if (selectedNode != null)
            Positioned(
              bottom: 120,
              left: 16,
              right: 16,
              child: _buildInfoCard(),
            ),
        ],
      ),
    );
  }
}