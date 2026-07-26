import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';

import '../main.dart';
import '../services/analisis_gempa_service.dart';
import '../models/analisis_gempa_model.dart';
import '../utils/shapefile_loader.dart';
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

class _AnalisisGempaPageState extends State<AnalisisGempaPage>
    with SingleTickerProviderStateMixin {
  late final MapController _mapController;
  final String _currentCityName = 'Memuat lokasi...';

  EarthquakeMapData? mapData;
  bool isLoading = true;
  String? errorMessage;
  double _mapZoom = 4.5;
  LatLng _mapCenter = const LatLng(-2.5, 118.0);
  EarthquakeEvent? selectedEvent;
  bool isFullScreen = false;
  bool showStatistics = false;
  int selectedDays = 30;
  List<List<LatLng>> faultSegments = [];

  // Tambahan untuk Tab
  late TabController _tabController;
  int _selectedTabIndex = 0;

  int get totalEvents => mapData?.earthquakes.length ?? 0;
  int get backgroundEventCount =>
      mapData?.earthquakes
          .where((e) => e.prediction == 'Background Event')
          .length ??
      0;
  int get triggeredEventCount =>
      mapData?.earthquakes
          .where((e) => e.prediction == 'Triggered Event')
          .length ??
      0;
  int get unknownPredictionCount =>
      mapData?.earthquakes.where((e) => e.prediction == null).length ?? 0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _tabController = TabController(length: 2, vsync: this);
    _loadFaultSegments();
    loadMapData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFaultSegments() async {
    final segments = await ShapefileLoader.loadFaultSegmentsFromAssets();
    if (!mounted) return;
    setState(() {
      faultSegments = segments;
    });
  }

  Future<void> loadMapData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
        selectedEvent = null;
      });

      final data = await EarthquakeMapService.fetchMapData(days: selectedDays);
      if (!mounted) return;

      print('Total earthquakes: ${data.earthquakes.length}');

      setState(() {
        mapData = data;
        isLoading = false;
        errorMessage = null;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updateMapCenter();
        }
      });
    } catch (e) {
      print("Error detail: $e");
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage =
            'Gagal memuat data gempa. Periksa koneksi internet dan coba lagi.';
      });
    }
  }

  void _updateMapCenter() {
    if (mapData == null || mapData!.earthquakes.isEmpty) {
      return;
    }

    final events = mapData!.earthquakes;
    final avgLat =
        events.map((event) => event.latitude).reduce((a, b) => a + b) /
        events.length;
    final avgLng =
        events.map((event) => event.longitude).reduce((a, b) => a + b) /
        events.length;

    _mapCenter = LatLng(avgLat, avgLng);
    _mapZoom = 5.2;
    try {
      _mapController.move(_mapCenter, _mapZoom);
    } catch (e) {
      print('Error moving map: $e');
    }
  }

  void _selectEvent(EarthquakeEvent event) {
    setState(() {
      selectedEvent = event;
    });
    // Tidak memindahkan peta
  }

  List<Marker> _buildMarkers() {
    if (mapData?.earthquakes.isEmpty ?? true) return [];

    return mapData!.earthquakes.map((event) {
      final magnitude = event.magnitude ?? 0.0;
      final double markerSize = (28 + magnitude * 4).clamp(28.0, 56.0);
      final String prediction = event.prediction ?? 'Unknown';
      final Color markerColor;

      if (prediction == 'Background Event') {
        markerColor = Colors.red;
      } else if (prediction == 'Triggered Event') {
        markerColor = Colors.orange;
      } else {
        markerColor = Colors.grey;
      }

      return Marker(
        point: LatLng(event.latitude, event.longitude),
        width: markerSize,
        height: markerSize,
        child: GestureDetector(
          onTap: () => _selectEvent(event),
          child: Container(
            alignment: Alignment.center,
            child: Icon(
              Icons.location_on,
              color: markerColor,
              size: markerSize,
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Polyline> _buildFaultPolylines() {
    final List<Polyline> polylines = [];

    for (final segment in faultSegments) {
      polylines.add(
        Polyline(
          points: segment,
          color: Colors.white.withOpacity(0.6),
          strokeWidth: 5,
        ),
      );

      polylines.add(
        Polyline(
          points: segment,
          color: const Color(0xFFC0392B).withOpacity(0.8),
          strokeWidth: 2.5,
        ),
      );
    }

    return polylines;
  }

  Widget _legendFaultItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔥 Garis sesar dengan 2 layer (putih + merah)
          SizedBox(
            width: 20,
            height: 14,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Garis putih (outline)
                Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Garis merah (utama)
                Container(
                  height: 2.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC0392B).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Sesar Aktif',
            style: TextStyle(fontSize: 11, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    final double topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      // 🔥 Gunakan MediaQuery untuk posisi yang lebih akurat
      top: isFullScreen ? 10 + topPadding : 10,
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
                _legendItem(Colors.red, 'Background Event'),
                _legendItem(Colors.orange, 'Triggered Event'),
                _legendItem(Colors.grey, 'Belum terklasifikasi'),
                const SizedBox(height: 4),
                // 🔥 Tambahkan garis sesar
                _legendFaultItem(),
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
    final event = selectedEvent;

    if (event == null) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(230),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withAlpha(180)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlphaPercent(0.12),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Detail Gempa',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event.wilayah ?? 'Lokasi tidak diketahui',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() {
                        selectedEvent = null;
                      }),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoItem(
                      Icons.access_time,
                      'Waktu kejadian',
                      DateFormat(
                        'dd MMM yyyy • HH:mm',
                      ).format(event.eventTime.toLocal()),
                      Colors.blue,
                    ),
                    const SizedBox(height: 10),
                    _infoItem(
                      Icons.speed,
                      'Magnitudo',
                      event.magnitude != null
                          ? '${event.magnitude!.toStringAsFixed(1)} Mw'
                          : '-',
                      Colors.orange,
                    ),
                    const SizedBox(height: 10),
                    _infoItem(
                      Icons.landscape,
                      'Kedalaman',
                      event.depth != null
                          ? '${event.depth!.toStringAsFixed(0)} km'
                          : '-',
                      Colors.teal,
                    ),
                    const SizedBox(height: 10),
                    _infoItem(
                      Icons.place,
                      'Wilayah',
                      event.wilayah ?? '-',
                      Colors.green,
                    ),
                    const SizedBox(height: 10),
                    _infoItem(
                      Icons.analytics,
                      'Klasifikasi',
                      event.prediction ?? 'Belum terklasifikasi',
                      event.prediction == 'Background Event'
                          ? Colors.red
                          : event.prediction == 'Triggered Event'
                          ? Colors.orange
                          : Colors.grey,
                    ),
                    const SizedBox(height: 10),
                    _infoItem(
                      Icons.percent,
                      'Probabilitas',
                      event.probability != null
                          ? '${(event.probability! * 100).toStringAsFixed(0)}%'
                          : '-',
                      Colors.purple,
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
      crossAxisAlignment: isNarrow
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SizedBox(width: 8),
                  Flexible(
                    child: const Text(
                      'Riksa',
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
                            color: const Color(
                              0xFF00BCD4,
                            ).withAlphaPercent(0.3),
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

  Widget _buildDayFilter() {
    const filterDays = [7, 30, 90, 365];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: filterDays.map((days) {
          final bool selected = selectedDays == days;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text('$days hari'),
              selected: selected,
              selectedColor: const Color(0xFF00BCD4),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              elevation: 0,
              side: BorderSide(
                color: selected
                    ? const Color(0xFF00BCD4)
                    : Colors.grey.shade300,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              onSelected: (_) {
                if (selectedDays != days) {
                  setState(() {
                    selectedDays = days;
                    isLoading = true;
                    errorMessage = null;
                    selectedEvent = null;
                  });
                  loadMapData();
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEventTile(EarthquakeEvent event) {
    final bool isSelected = selectedEvent?.id == event.id;
    final String eventTime = DateFormat(
      'dd MMM yyyy • HH:mm',
    ).format(event.eventTime.toLocal());
    final String statusText;
    final Color statusColor;

    if (event.prediction == 'Background Event') {
      statusText = 'Background Event';
      statusColor = Colors.red;
    } else if (event.prediction == 'Triggered Event') {
      statusText = 'Triggered Event';
      statusColor = Colors.orange;
    } else {
      statusText = 'Belum terklasifikasi';
      statusColor = Colors.grey;
    }

    return InkWell(
      onTap: () => _selectEvent(event),
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
                  event.magnitude != null
                      ? event.magnitude!.toStringAsFixed(1)
                      : '-',
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
                    event.wilayah ?? 'Lokasi tidak diketahui',
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
                color: statusColor.withAlphaPercent(0.16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 10,
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

  Widget _buildEventTab() {
    final events = mapData?.earthquakes ?? [];
    if (events.isEmpty) {
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
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              const Text(
                '📋 Daftar Gempa',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BCD4).withAlphaPercent(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${events.length} event',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF00BCD4),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: events.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final event = events[index];
            return _buildEventTile(event);
          },
        ),
      ],
    );
  }

  Widget _buildGuideTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00BCD4), Color(0xFF26C6DA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Panduan Penggunaan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Analisis Seismik - Situational Awareness Gempa Bumi',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withAlpha(220),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _buildGuideSection(
            icon: Icons.waves,
            title: 'Apa itu Analisis Seismik?',
            color: const Color(0xFF00BCD4),
            children: [
              const Text(
                'Fitur ini menampilkan informasi gempa bumi terkini beserta analisis aktivitas seismik berbasis machine learning. '
                'Data disajikan dalam peta interaktif untuk membantu pengguna memahami kondisi kegempaan di wilayah Indonesia dan mengidentifikasi pola aktivitas seismik yang terdeteksi.',
                style: TextStyle(fontSize: 14, height: 1.6),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Data gempa diperbarui secara real-time dari API BMKG. '
                        'Hasil klasifikasi memerlukan validasi lebih lanjut.',
                        style: TextStyle(fontSize: 13, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _buildGuideSection(
            icon: Icons.map,
            title: 'Cara Membaca Peta',
            color: Colors.orange,
            children: [
              _buildGuideListItem(
                icon: Icons.location_on,
                color: Colors.red,
                title: 'Marker Gempa',
                description: 'Menunjukkan lokasi kejadian gempa. Warna marker:',
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 36),
                child: Column(
                  children: [
                    _buildLegendItemRow(
                      Colors.red,
                      'Background Event - Gempa latar belakang',
                    ),
                    _buildLegendItemRow(
                      Colors.orange,
                      'Triggered Event - Gempa yang dipicu',
                    ),
                    _buildLegendItemRow(
                      Colors.grey,
                      'Belum terklasifikasi - Magnitude terlalu kecil',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildGuideListItem(
                icon: Icons.timeline,
                color: Colors.red,
                title: 'Sesar Aktif',
                description:
                    'Garis merah pada peta menunjukkan jalur sesar aktif yang menjadi konteks geologi terjadinya gempa.',
              ),
            ],
          ),

          const SizedBox(height: 20),

          _buildGuideSection(
            icon: Icons.touch_app,
            title: 'Cara Menggunakan Fitur',
            color: Colors.purple,
            children: [
              _buildGuideStep(
                number: '1',
                title: 'Filter Data',
                description:
                    'Gunakan tombol filter hari (7, 30, 90, 365) untuk menampilkan data gempa dalam periode waktu tertentu.',
              ),
              _buildGuideStep(
                number: '2',
                title: 'Lihat Detail Gempa',
                description:
                    'Ketuk marker gempa di peta atau ketuk kartu event di daftar untuk melihat informasi lengkap seperti magnitudo, kedalaman, dan klasifikasi.',
              ),
              _buildGuideStep(
                number: '3',
                title: 'Navigasi Peta',
                description:
                    'Gunakan tombol zoom (+/-) atau tombol layar penuh untuk menjelajahi peta dengan lebih leluasa.',
              ),
              _buildGuideStep(
                number: '4',
                title: 'Statistik Kejadian',
                description:
                    'Aktifkan tombol statistik (📊) untuk melihat ringkasan data gempa secara keseluruhan.',
              ),
            ],
          ),

          const SizedBox(height: 20),

          _buildGuideSection(
            icon: Icons.tips_and_updates,
            title: 'Tips & Informasi Penting',
            color: Colors.green,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  children: [
                    _buildTipItem(
                      icon: Icons.verified,
                      color: Colors.green,
                      text:
                          'Analisis yang ditampilkan merupakan hasil pemodelan machine learning sebagai informasi pendukung untuk meningkatkan kewaspadaan dan tidak menggantikan analisis resmi BMKG.',
                    ),
                    const SizedBox(height: 10),
                    _buildTipItem(
                      icon: Icons.warning,
                      color: Colors.orange,
                      text:
                          'Selalu ikuti arahan resmi dari BMKG dan pemerintah daerah terkait potensi bencana.',
                    ),
                    const SizedBox(height: 10),
                    _buildTipItem(
                      icon: Icons.phone,
                      color: Colors.blue,
                      text:
                          'Jika terjadi gempa signifikan, segera cari informasi resmi dan lakukan tindakan evakuasi yang aman.',
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BCD4).withAlphaPercent(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.help_outline,
                    color: Color(0xFF00BCD4),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Butuh bantuan?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Hubungi tim Riksa melalui fitur bantuan di aplikasi.',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
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

  Widget _buildGuideSection({
    required IconData icon,
    required String title,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlphaPercent(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withAlphaPercent(0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideListItem({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGuideStep({
    required String number,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF00BCD4).withAlphaPercent(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00BCD4),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItemRow(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTipItem({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade800,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapContainer(double mapHeight, bool isNarrow) {
    return AnimatedContainer(
      duration: const Duration(
        milliseconds: 600,
      ), // 🔥 Tambah durasi dari 500 ke 600
      curve: Curves.easeInOutCubic, // 🔥 Ganti dari Curves.easeInOut
      height: isFullScreen ? double.infinity : mapHeight,
      margin: EdgeInsets.symmetric(
        horizontal: isFullScreen ? 0 : 16, // 🔥 Animasi margin juga
      ),
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
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.amanin.app',
                ),
                if (faultSegments.isNotEmpty)
                  PolylineLayer(polylines: _buildFaultPolylines()),
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
                        try {
                          final currentCenter = _mapController.camera.center;
                          final currentZoom = _mapController.camera.zoom;
                          final newZoom = (currentZoom + 0.5).clamp(2.0, 18.0);
                          _mapController.move(currentCenter, newZoom);

                          setState(() {
                            _mapCenter = currentCenter;
                            _mapZoom = newZoom;
                          });
                        } catch (e) {
                          print('Error zoom in: $e');
                        }
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
                        try {
                          final currentCenter = _mapController.camera.center;
                          final currentZoom = _mapController.camera.zoom;
                          final newZoom = (currentZoom - 0.5).clamp(2.0, 18.0);
                          _mapController.move(currentCenter, newZoom);

                          setState(() {
                            _mapCenter = currentCenter;
                            _mapZoom = newZoom;
                          });
                        } catch (e) {
                          print('Error zoom out: $e');
                        }
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
            if (selectedEvent != null)
              Positioned(
                bottom: 20,
                left: 16,
                right: 16,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: (isFullScreen
                        ? MediaQuery.of(context).size.height * 0.5
                        : mapHeight * 0.55),
                  ),
                  child: SingleChildScrollView(child: _buildInfoCard()),
                ),
              ),
          ],
        ),
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
                    loadMapData();
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
        ? (screenHeight - MediaQuery.of(context).padding.top - 120).clamp(
            280.0,
            screenHeight * 0.78,
          )
        : 340;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: isFullScreen
            ? _buildFullscreenLayout(mapHeight, isNarrow)
            : _buildScrollableLayout(mapHeight, isNarrow),
      ),
    );
  }

  // 🔥 Layout untuk Fullscreen (tanpa scroll)
  Widget _buildFullscreenLayout(double mapHeight, bool isNarrow) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: _buildHeader(context, isNarrow),
        ),
        // Judul
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BCD4).withAlphaPercent(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.map,
                  color: Color(0xFF00BCD4),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analisis Seismik',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    'Pantau aktivitas gempa terkini di Indonesia',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
        _buildDayFilter(),
        _buildDisclaimer(),
        Expanded(child: _buildMapContainer(mapHeight, isNarrow)),
      ],
    );
  }

  // 🔥 Layout untuk Normal Mode (Scrollable)
  Widget _buildScrollableLayout(double mapHeight, bool isNarrow) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _buildHeader(context, isNarrow),
          ),
          // Judul
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BCD4).withAlphaPercent(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.map,
                    color: Color(0xFF00BCD4),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analisis Seismik',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.riksa.app',
                        ),
                        if (faultSegments.isNotEmpty)
                          PolylineLayer(polylines: _buildFaultPolylines()),
                        if (mapData?.influenceZones.isNotEmpty ?? false)
                          CircleLayer(circles: _buildInfluenceZoneCircles()),
                        if (mapData?.influenceZones.isNotEmpty ?? false)
                          MarkerLayer(markers: _buildZoneTapMarkers()),
                        MarkerLayer(markers: _buildMarkers()),
                      ],
                    ),
                    Text(
                      'Pantau aktivitas gempa terkini di Indonesia',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Filter
          _buildDayFilter(),
          // Disclaimer
          _buildDisclaimer(),
          // Map
          _buildMapContainer(mapHeight, isNarrow),
          // TabBar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlphaPercent(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: const Color(0xFF00BCD4),
              unselectedLabelColor: Colors.grey.shade600,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 4,
              ),
              tabs: [
                // Tab 0: Panduan (KIRI)
                const Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.help_outline, size: 18),
                      SizedBox(width: 6),
                      Text('Panduan'),
                    ],
                  ),
                ),
                // Tab 1: Event (KANAN)
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.list, size: 18),
                      const SizedBox(width: 6),
                      const Text('Event'),
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00BCD4).withAlphaPercent(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${mapData?.earthquakes.length ?? 0}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00BCD4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              onTap: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
            ),
          ),
          // TabBarView
          SizedBox(
            height: 500, // 🔥 Tinggi fixed untuk TabBarView
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 0: Panduan (KIRI)
                _buildGuideTab(),
                // Tab 1: Event (KANAN)
                SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 4,
                    bottom: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildEventTab(),
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
                                    'Background Event',
                                    '$backgroundEventCount',
                                    Colors.red,
                                    Icons.event,
                                  ),
                                  _buildSimpleStatBox(
                                    'Triggered Event',
                                    '$triggeredEventCount',
                                    Colors.orange,
                                    Icons.bolt,
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
                                    Icons.map,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                const Expanded(
                                  child: Text(
                                    'Halaman ini menampilkan situational awareness seismik: gempa terbaru dan sesar aktif sebagai konteks geologi.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF1A1A1A),
                                      height: 1.6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.blue.shade100),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.blue.shade700,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Text(
                                      'Ketuk marker untuk detail gempa.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
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
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // 🔥 Method untuk Disclaimer
  Widget _buildDisclaimer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange.shade700, size: 18),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              '⚠️ Hasil klasifikasi ini bersifat informatif dan memerlukan analisis lebih lanjut dari BMKG untuk pengambilan keputusan resmi.',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFFE65100),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
