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
  final ValueChanged<bool>? onFullscreenChanged;

  const AnalisisGempaPage({super.key, this.onFullscreenChanged});

  @override
  State<AnalisisGempaPage> createState() => _AnalisisGempaPageState();
}

class _AnalisisGempaPageState extends State<AnalisisGempaPage>
    with SingleTickerProviderStateMixin {
  late final MapController _mapController;
  final String _currentCityName = 'Memuat lokasi...';

  EarthquakeMapData? mapData;
  bool isLoading = true;
  bool isRefreshing = false;
  String? errorMessage;
  double _mapZoom = 4.5;
  LatLng _mapCenter = const LatLng(-2.5, 118.0);
  EarthquakeEvent? selectedEvent;
  bool isFullScreen = false;
  int selectedDays = 30;
  List<List<LatLng>> faultSegments = [];

  // Tambahan untuk Tab
  late TabController _tabController;
  int _selectedTabIndex = 0;

  int get totalEvents => mapData?.earthquakes.length ?? 0;
  int get mainshockCount =>
      mapData?.earthquakes
          .where((event) => event.prediction == 'Mainshock')
          .length ??
      0;

  int get dependentEventCount =>
      mapData?.earthquakes
          .where((event) => event.prediction == 'Dependent Event')
          .length ??
      0;

  int get unknownPredictionCount =>
      mapData?.earthquakes
          .where(
            (event) =>
                event.prediction != 'Mainshock' &&
                event.prediction != 'Dependent Event',
          )
          .length ??
      0;

  void _setFullscreen(bool value) {
    if (isFullScreen == value) return;

    setState(() {
      isFullScreen = value;

      // Tutup detail saat berpindah mode agar layout bersih.
      selectedEvent = null;
    });

    widget.onFullscreenChanged?.call(value);
  }

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
    try {
      final segments = await ShapefileLoader.loadFaultSegmentsFromAssets();

      if (!mounted) return;

      setState(() {
        faultSegments = segments;
      });
    } catch (error, stackTrace) {
      debugPrint('Gagal memuat shapefile sesar: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        faultSegments = [];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Layer sesar tidak dapat dimuat. Peta gempa tetap tersedia.',
          ),
        ),
      );
    }
  }

  Future<void> loadMapData() async {
    final bool isInitialLoad = mapData == null;

    if (mounted) {
      setState(() {
        if (isInitialLoad) {
          isLoading = true;
        } else {
          isRefreshing = true;
        }

        errorMessage = null;
        selectedEvent = null;
      });
    }

    try {
      final rawData = await EarthquakeMapService.fetchMapData(
        days: selectedDays,
      );

      final sortedEvents = [...rawData.earthquakes]
        ..sort((a, b) => b.eventTime.compareTo(a.eventTime));

      final data = EarthquakeMapData(earthquakes: sortedEvents);

      if (!mounted) return;

      setState(() {
        mapData = data;
        isLoading = false;
        isRefreshing = false;
        errorMessage = null;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updateMapCenter();
        }
      });
    } catch (error, stackTrace) {
      debugPrint('Gagal memuat data gempa: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        isLoading = false;
        isRefreshing = false;

        // Hanya ganti seluruh halaman dengan error jika belum ada data.
        if (mapData == null) {
          errorMessage =
              'Data gempa bumi belum dapat dimuat. '
              'Pastikan backend aktif dan perangkat terhubung ke jaringan.';
        }
      });

      // Jika data lama masih tersedia, tampilkan error ringan.
      if (mapData != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Gagal memperbarui data. Data sebelumnya tetap ditampilkan.',
            ),
          ),
        );
      }
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

      if (prediction == 'Mainshock') {
        markerColor = Colors.red;
      } else if (prediction == 'Dependent Event') {
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
    return Positioned(top: 10, right: 16, child: _buildLegendCard());
  }

  Widget _buildLegendCard() {
    return ClipRRect(
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
              _legendItem(Colors.red, 'Mainshock'),
              _legendItem(Colors.orange, 'Dependent Event'),
              _legendItem(Colors.grey, 'Belum terklasifikasi'),
              const SizedBox(height: 4),
              _legendFaultItem(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String text) {
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
                    Expanded(
                      child: Column(
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
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          selectedEvent = null;
                        });
                      },
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
                      event.prediction == 'Mainshock'
                          ? Colors.red
                          : event.prediction == 'Dependent Event'
                          ? Colors.orange
                          : Colors.grey,
                    ),
                    const SizedBox(height: 10),
                    _infoItem(
                      Icons.percent,
                      'Probabilitas',
                      event.probability != null
                          ? '${(event.probability!.clamp(0.0, 1.0) * 100).toStringAsFixed(1)}%'
                          : '-',
                      Colors.purple,
                    ),
                    const SizedBox(height: 10),
                    _buildClassificationInterpretation(event),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassificationInterpretation(EarthquakeEvent event) {
    final String title;
    final String description;
    final Color color;
    final IconData icon;

    if (event.prediction == 'Mainshock') {
      title = 'Interpretasi Mainshock';
      description =
          'Kejadian ini diperkirakan model sebagai kejadian '
          'utama atau independen dalam pola seismik yang '
          'dianalisis. Klasifikasi ini tidak menunjukkan '
          'tingkat kerusakan atau besarnya dampak.';
      color = Colors.red;
      icon = Icons.warning_amber_rounded;
    } else if (event.prediction == 'Dependent Event') {
      title = 'Interpretasi Dependent Event';
      description =
          'Kejadian ini diperkirakan memiliki keterkaitan '
          'waktu dan wilayah dengan kejadian lainnya. '
          'Hasil ini tidak membuktikan hubungan sebab-akibat '
          'secara langsung dan tidak berarti gempa tersebut '
          'tidak berbahaya.';
      color = Colors.orange;
      icon = Icons.hub_rounded;
    } else if (event.magnitude != null && event.magnitude! <= 4.7) {
      title = 'Di luar cakupan klasifikasi';
      description =
          'Kejadian tetap ditampilkan sebagai informasi, '
          'tetapi tidak diklasifikasikan karena magnitudonya '
          'berada pada atau di bawah batas kelengkapan model '
          '(Mc 4,7).';
      color = Colors.blueGrey;
      icon = Icons.info_outline_rounded;
    } else {
      title = 'Klasifikasi belum tersedia';
      description =
          'Model belum menghasilkan klasifikasi untuk '
          'kejadian ini. Gunakan informasi resmi BMKG '
          'sebagai acuan utama.';
      color = Colors.grey;
      icon = Icons.help_outline_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  softWrap: true,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
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
                  softWrap: true,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Riksa',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 4),
              ValueListenableBuilder<String>(
                valueListenable: userCityNameNotifier,
                builder: (context, cityName, _) {
                  final displayCity = cityName.isNotEmpty
                      ? cityName
                      : 'Lokasi tidak tersedia';

                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F7FA),
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
                          Flexible(
                            child: Text(
                              displayCity,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF00BCD4),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        Row(
          mainAxisSize: MainAxisSize.min,
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
                if (isLoggedIn) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AkunPage(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
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
                          color: const Color(0xFF00BCD4).withValues(alpha: 0.3),
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
              avatar: selected && isRefreshing
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : null,
              onSelected: (value) {
                if (!value || selectedDays == days || isRefreshing) {
                  return;
                }

                setState(() {
                  selectedDays = days;
                  selectedEvent = null;
                });

                loadMapData();
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

    if (event.prediction == 'Mainshock') {
      statusText = 'Mainshock';
      statusColor = Colors.red;
    } else if (event.prediction == 'Dependent Event') {
      statusText = 'Dependent Event';
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
                    maxLines: 3,
                    softWrap: true,
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
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusText,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
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
    return Padding(
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
                  'Klasifikasi Aktifitas Gempa Bumi - Situational Awareness Gempa Bumi',
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
            icon: Icons.account_tree_rounded,
            title: 'Apa itu Rangkaian Gempa Bumi?',
            color: const Color(0xFF00BCD4),
            children: [
              const Text(
                'Rangkaian gempa bumi adalah sekumpulan kejadian gempa '
                'yang terjadi dalam waktu dan wilayah yang berdekatan. '
                'Dalam satu rangkaian, terdapat kejadian yang dapat '
                'berperan sebagai gempa utama serta kejadian lain yang '
                'diperkirakan berkaitan dengannya.',
                softWrap: true,
                style: TextStyle(fontSize: 14, height: 1.6),
              ),

              const SizedBox(height: 14),

              _buildGuideListItem(
                icon: Icons.warning_amber_rounded,
                color: Colors.red,
                title: 'Mainshock',
                description:
                    'Kejadian yang diperkirakan model sebagai gempa '
                    'utama atau kejadian independen dalam pola gempa '
                    'yang dianalisis.',
              ),

              const SizedBox(height: 12),

              _buildGuideListItem(
                icon: Icons.hub_rounded,
                color: Colors.orange,
                title: 'Dependent Event',
                description:
                    'Kejadian yang diperkirakan memiliki keterkaitan '
                    'waktu dan lokasi dengan aktivitas gempa lain '
                    'dalam rangkaian tersebut.',
              ),

              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Amanin menggunakan machine learning untuk '
                        'mengenali pola rangkaian gempa berdasarkan '
                        'data kejadian yang tersedia. Hasil klasifikasi '
                        'bersifat informatif dan bukan penetapan resmi '
                        'dari BMKG.',
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          _buildGuideSection(
            icon: Icons.psychology_alt_rounded,
            title: 'Memahami Hasil Klasifikasi',
            color: Colors.indigo,
            children: [
              _buildGuideListItem(
                icon: Icons.warning_amber_rounded,
                color: Colors.red,
                title: 'Mainshock',
                description:
                    'Kejadian yang diperkirakan model sebagai '
                    'kejadian utama atau independen dalam pola '
                    'seismik yang dianalisis. Label ini tidak '
                    'otomatis menunjukkan dampak paling besar.',
              ),
              const SizedBox(height: 12),
              _buildGuideListItem(
                icon: Icons.hub_rounded,
                color: Colors.orange,
                title: 'Dependent Event',
                description:
                    'Kejadian yang diperkirakan memiliki '
                    'waktu dan wilayah yang berdekatan. '
                    'dengan gempa lain. Label ini tidak membuktikan '
                    'hubungan sebab-akibat secara langsung.',
              ),
              const SizedBox(height: 12),
              _buildGuideListItem(
                icon: Icons.remove_circle_outline_rounded,
                color: Colors.blueGrey,
                title: 'Tidak Diklasifikasikan',
                description:
                    'Kejadian dengan magnitudo pada atau di bawah '
                    'Mc 4,7 tetap ditampilkan, tetapi berada di luar '
                    'cakupan klasifikasi model.',
              ),
              const SizedBox(height: 12),
              _buildGuideListItem(
                icon: Icons.percent_rounded,
                color: Colors.purple,
                title: 'Keyakinan Model',
                description:
                    'Persentase keyakinan model terhadap kelas yang '
                    'ditampilkan; bukan peluang terjadinya gempa dan '
                    'bukan ukuran kerusakan.',
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 20,
                      color: Color(0xFFF57F17),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Dampak gempa tidak ditentukan oleh kelas '
                        'Mainshock atau Dependent Event. Dampak '
                        'dipengaruhi magnitudo, kedalaman, jarak '
                        'dari sumber, kondisi geologi lokal, dan '
                        'kerentanan bangunan. Ikuti informasi resmi '
                        'BMKG sebagai acuan utama.',
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

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
                      'Mainshock - Gempa latar belakang',
                    ),
                    _buildLegendItemRow(
                      Colors.orange,
                      'Dependent Event - Gempa yang dipicu',
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

            if (!isFullScreen) _buildLegend(),

            // Tombol hanya muncul saat detail tertutup.
            if (selectedEvent == null)
              Positioned(
                bottom: isFullScreen ? 32 : 28,
                right: 16,
                child: Column(
                  children: [
                    if (isFullScreen)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: FloatingActionButton.small(
                          heroTag: 'btn_exit_fs',
                          backgroundColor: Colors.white.withValues(alpha: 0.95),
                          onPressed: () => _setFullscreen(false),
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
                        backgroundColor: Colors.white.withValues(alpha: 0.95),
                        onPressed: () => _setFullscreen(true),
                        child: const Icon(
                          Icons.fullscreen,
                          color: Color(0xFF00BCD4),
                          size: 20,
                        ),
                      ),

                    const SizedBox(height: 8),

                    FloatingActionButton.small(
                      heroTag: 'btn_zoom_in',
                      backgroundColor: Colors.white.withValues(alpha: 0.95),
                      onPressed: _zoomIn,
                      child: const Icon(
                        Icons.add,
                        color: Color(0xFF00BCD4),
                        size: 20,
                      ),
                    ),

                    const SizedBox(height: 4),

                    FloatingActionButton.small(
                      heroTag: 'btn_zoom_out',
                      backgroundColor: Colors.white.withValues(alpha: 0.95),
                      onPressed: _zoomOut,
                      child: const Icon(
                        Icons.remove,
                        color: Color(0xFF00BCD4),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

            // Bagian ini yang hilang.
            if (selectedEvent != null)
              Positioned(
                bottom: isFullScreen ? 24 : 20,
                left: 16,
                right: 16,
                child: SafeArea(
                  top: false,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: isFullScreen
                          ? MediaQuery.of(context).size.height * 0.55
                          : mapHeight * 0.65,
                    ),
                    child: SingleChildScrollView(child: _buildInfoCard()),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _zoomIn() {
    try {
      final camera = _mapController.camera;
      final newZoom = (camera.zoom + 0.5).clamp(2.0, 18.0);

      _mapController.move(camera.center, newZoom);
    } catch (error) {
      debugPrint('Gagal memperbesar peta: $error');
    }
  }

  void _zoomOut() {
    try {
      final camera = _mapController.camera;
      final newZoom = (camera.zoom - 0.5).clamp(2.0, 18.0);

      _mapController.move(camera.center, newZoom);
    } catch (error) {
      debugPrint('Gagal memperkecil peta: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading && mapData == null) {
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
      body: isFullScreen
          ? _buildFullscreenLayout(mapHeight, isNarrow)
          : SafeArea(child: _buildScrollableLayout(mapHeight, isNarrow)),
    );
  }

  // 🔥 Layout untuk Fullscreen (tanpa scroll)
  Widget _buildFullscreenLayout(double mapHeight, bool isNarrow) {
    return Stack(
      children: [
        Positioned.fill(child: _buildMapContainer(mapHeight, isNarrow)),

        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildFullscreenDisclaimer(),

                const SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildLegendCard(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFullscreenDisclaimer() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange.shade50.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.orange.shade800, size: 19),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Hasil klasifikasi ini bersifat informatif dan '
              'memerlukan analisis lebih lanjut dari BMKG untuk '
              'pengambilan keputusan resmi.',
              softWrap: true,
              overflow: TextOverflow.visible,
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFFE65100),
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
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
            child: _buildHeader(context),
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
                      'Klasifikasi Aktivitas Gempa Bumi',
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
                    color: Colors.black.withValues(alpha: 0.08),
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
                          color: const Color(
                            0xFF00BCD4,
                          ).withValues(alpha: 0.15),
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
          const SizedBox(height: 12),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: KeyedSubtree(
              key: ValueKey<int>(_selectedTabIndex),
              child: _selectedTabIndex == 0
                  ? _buildGuideTab()
                  : _buildEventContent(isNarrow),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventContent(bool isNarrow) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEventTab(),

          const SizedBox(height: 18),

          _buildAnalysisDescription(),
        ],
      ),
    );
  }

  Widget _buildAnalysisDescription() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00BCD4), Color(0xFF26C6DA)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.map, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Halaman ini menampilkan situational awareness '
                  'gempa: gempa terbaru dan sesar aktif sebagai '
                  'konteks geologi.',
                  softWrap: true,
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
                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 18),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Ketuk marker untuk melihat detail gempa.',
                    softWrap: true,
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
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
