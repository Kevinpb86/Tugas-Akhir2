import 'package:flutter/material.dart';
import 'beranda.dart';
import 'edukasi.dart'; // Import for navigation consistency if needed
import 'gempa.dart';
import 'asuransi.dart';
import 'main.dart'; // For userCityNameNotifier

import 'services/bmkg_service.dart';

class CuacaPage extends StatefulWidget {
  final VoidCallback? onBack;
  const CuacaPage({super.key, this.onBack});

  @override
  State<CuacaPage> createState() => _CuacaPageState();
}

class _CuacaPageState extends State<CuacaPage> {
  CuacaModel? _latestCuaca;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    try {
      final cuaca = await BmkgService.fetchCurrentWeather(
        '32.04.08.2002',
      ); // Bojongsoang
      if (mounted) {
        setState(() {
          _latestCuaca = cuaca;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching cuaca detail: $e. Using mock fallback data.");
      if (mounted) {
        setState(() {
          _latestCuaca = BmkgService.getMockWeather();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              'Cuaca Mingguan',
              style: TextStyle(
                color: Color(0xFF1A1A1A),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.location_on,
                  size: 12,
                  color: Color(0xFF2196F3),
                ),
                const SizedBox(width: 4),
                ValueListenableBuilder<String>(
                  valueListenable: userCityNameNotifier,
                  builder: (context, cityName, _) {
                    return Text(
                      cityName,
                      style: const TextStyle(
                        color: Color(0xFF2196F3),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Color(0xFF1A1A1A)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Weather Card
              _buildCurrentWeatherCard(),
              const SizedBox(height: 24),
              // Early Warning Card
              _buildEarlyWarningCard(),
              const SizedBox(height: 24),
              // Weekly Forecast Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '7 Hari Kedepan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Lihat Radar',
                      style: TextStyle(
                        color: Color(0xFF2196F3),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Weekly Forecast List
              _buildWeeklyForecast(),
              const SizedBox(height: 24),
              _buildInsuranceSection(context),
              const SizedBox(height: 100), // Bottom padding for floating nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentWeatherCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF00BCD4), // Vivid Cyan
            Color(0xFF00838F), // Darker Cyan for premium gradient depth
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00BCD4).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Weather Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'SAAT INI',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isLoading
                          ? '...'
                          : (_latestCuaca?.cuaca.isNotEmpty == true
                              ? _latestCuaca!.cuaca
                              : 'Berawan'),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.1,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Terasa seperti ${_isLoading ? "..." : (_latestCuaca != null ? _latestCuaca!.suhu + 2 : 34)}\u00B0C',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ValueListenableBuilder<String>(
                      valueListenable: userCityNameNotifier,
                      builder: (context, cityName, _) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 11,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                cityName,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _isLoading
                              ? '--'
                              : '${_latestCuaca?.suhu.toString() ?? '32'}\u00B0',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          child: _isLoading
                              ? const Center(
                                  child: SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 1.5,
                                    ),
                                  ),
                                )
                              : (_latestCuaca != null &&
                                      _latestCuaca!.image.isNotEmpty
                                  ? Center(
                                      child: Image.network(
                                        _latestCuaca!.image,
                                        width: 24,
                                        height: 24,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) => const Icon(
                                          Icons.cloud_outlined,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.cloud_outlined,
                                      color: Colors.white,
                                      size: 20,
                                    )),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              height: 1,
              color: Colors.white.withValues(alpha: 0.15),
            ),
            const SizedBox(height: 14),
            // Bottom Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherDetail(
                  Icons.water_drop_outlined,
                  _isLoading
                      ? '--%'
                      : '${_latestCuaca?.kelembapan ?? 94}%',
                  'Air',
                ),
                _buildWeatherDetail(
                  Icons.air_rounded,
                  _isLoading
                      ? '--'
                      : (_latestCuaca?.kecAngin.toString() ?? '3.6'),
                  'km/h',
                ),
                _buildWeatherDetail(
                  Icons.wb_sunny_outlined,
                  'UV 6',
                  'Sedang',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildEarlyWarningCard() {
    final String warningMsg = _isLoading
        ? "Memeriksa peringatan cuaca..."
        : (_latestCuaca?.peringatanDini ??
              "Sedang tidak ada peringatan cuaca yang signifikan untuk saat ini.");

    final bool hasWarning = warningMsg.contains("Waspada");

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasWarning ? const Color(0xFFFFF3E0) : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasWarning ? const Color(0xFFFFE0B2) : const Color(0xFFC8E6C9),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: hasWarning
                  ? const Color(0xFFFF9800)
                  : const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              hasWarning
                  ? Icons.warning_amber_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
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
                        ? const Color(0xFFE65100)
                        : const Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  warningMsg,
                  style: TextStyle(
                    fontSize: 12,
                    color: hasWarning
                        ? const Color(0xFFE65100)
                        : const Color(0xFF388E3C),
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

  Widget _buildWeeklyForecast() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_latestCuaca == null || _latestCuaca!.dailyForecasts.isEmpty) {
      return const Center(child: Text("Data prakiraan belum tersedia."));
    }

    // Calculate the overall minimum and maximum temperatures of the week
    int minWeekly = 100;
    int maxWeekly = -100;
    for (var f in _latestCuaca!.dailyForecasts) {
      if (f.minTemp < minWeekly) minWeekly = f.minTemp;
      if (f.maxTemp > maxWeekly) maxWeekly = f.maxTemp;
    }

    return Column(
      children: _latestCuaca!.dailyForecasts
          .map((f) => _buildForecastItem(f, minWeekly, maxWeekly))
          .toList(),
    );
  }

  Widget _buildForecastItem(DailyForecast data, int minWeekly, int maxWeekly) {
    final isEst = data.isEstimate;
    
    // Parse weather condition to determine premium color themes
    final condition = data.condition.toLowerCase();
    
    // Default colors (Cloudy / Partly Cloudy)
    Color themeColor = const Color(0xFF64748B);
    Color badgeBgColor = const Color(0xFFF1F5F9);
    Color badgeTextColor = const Color(0xFF475569);
    IconData fallbackIcon = Icons.cloud_outlined;

    if (condition.contains('cerah') && !condition.contains('berawan')) {
      // Sunny / Clear
      themeColor = const Color(0xFFF59E0B);
      badgeBgColor = const Color(0xFFFEF3C7);
      badgeTextColor = const Color(0xFFD97706);
      fallbackIcon = Icons.wb_sunny_rounded;
    } else if (condition.contains('hujan')) {
      // Rainy
      themeColor = const Color(0xFF3B82F6);
      badgeBgColor = const Color(0xFFDBEAFE);
      badgeTextColor = const Color(0xFF1D4ED8);
      fallbackIcon = Icons.umbrella_rounded;
    } else if (condition.contains('petir') || condition.contains('kilat')) {
      // Thunderstorm
      themeColor = const Color(0xFF8B5CF6);
      badgeBgColor = const Color(0xFFEDE9FE);
      badgeTextColor = const Color(0xFF6D28D9);
      fallbackIcon = Icons.thunderstorm_rounded;
    } else if (condition.contains('berawan') || condition.contains('mendung')) {
      // Cloudy
      themeColor = const Color(0xFF64748B);
      badgeBgColor = const Color(0xFFE2E8F0);
      badgeTextColor = const Color(0xFF334155);
      fallbackIcon = Icons.cloud_rounded;
    }

    final Color dayColor = isEst ? const Color(0xFF94A3B8) : const Color(0xFF0F172A);
    final Color subColor = isEst ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);
    final double contentOpacity = isEst ? 0.6 : 1.0;

    String mainText = data.dayName;
    String? subText;
    
    if (data.dayName.startsWith("Besok ")) {
      mainText = "Besok";
      subText = data.dayName.substring(6); // e.g. "(Rabu)"
    }

    // iOS Weather Style Temperature Range Bar Math
    double range = (maxWeekly - minWeekly).toDouble();
    if (range <= 0) range = 1.0;
    
    final double startPct = (data.minTemp - minWeekly) / range;
    final double endPct = (data.maxTemp - minWeekly) / range;
    final double widthPct = (endPct - startPct).clamp(0.12, 1.0);
    
    const double trackWidth = 55.0;
    final double leftPosition = (startPct * trackWidth).clamp(0.0, trackWidth - 8.0);
    final double barWidth = (widthPct * trackWidth).clamp(8.0, trackWidth - leftPosition);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Accent Line for visual indication
              Container(
                width: 6,
                color: isEst ? const Color(0xFFCBD5E1) : themeColor,
              ),
              // Main content of the card
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      // Left: Day name and details
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              mainText,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: dayColor,
                                letterSpacing: -0.3,
                              ),
                            ),
                            if (subText != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                subText,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: subColor,
                                ),
                              ),
                            ],
                            if (isEst) ...[
                              const SizedBox(height: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'ESTIMASI',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF64748B),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Center: Weather icon and condition badge
                      Expanded(
                        flex: 4,
                        child: Opacity(
                          opacity: contentOpacity,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isEst ? const Color(0xFFF8FAFC) : themeColor.withOpacity(0.06),
                                  shape: BoxShape.circle,
                                ),
                                child: Image.network(
                                  data.imagePath,
                                  width: 36,
                                  height: 36,
                                  errorBuilder: (context, error, stackTrace) => Icon(
                                    fallbackIcon,
                                    color: isEst ? const Color(0xFF94A3B8) : themeColor,
                                    size: 32,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                data.condition,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isEst ? const Color(0xFF94A3B8) : themeColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Right: Temperatures & iOS-style Range Bar
                      Expanded(
                        flex: 5,
                        child: Opacity(
                          opacity: contentOpacity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Min Temp Text
                              SizedBox(
                                width: 32,
                                child: Text(
                                  '${data.minTemp}°',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: isEst ? const Color(0xFFCBD5E1) : const Color(0xFF94A3B8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Range Bar
                              Container(
                                width: trackWidth,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(2.5),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: leftPosition,
                                      width: barWidth,
                                      top: 0,
                                      bottom: 0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              const Color(0xFF60A5FA), // Cool blue for min
                                              isEst ? const Color(0xFF94A3B8) : themeColor, // Theme color for max
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(2.5),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Max Temp Text
                              SizedBox(
                                width: 32,
                                child: Text(
                                  '${data.maxTemp}°',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: isEst ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildInsuranceSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
}
