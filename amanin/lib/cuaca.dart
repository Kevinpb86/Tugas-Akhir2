import 'package:flutter/material.dart';
import 'beranda.dart';
import 'edukasi.dart'; // Import for navigation consistency if needed
import 'gempa.dart';
import 'asuransi.dart';

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
      final cuaca = await BmkgService.fetchCurrentWeather('31.71.01.1001'); // Jakarta Pusat, Gambir
      if (mounted) {
        setState(() {
          _latestCuaca = cuaca;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        print("Error fetching cuaca detail: $e");
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
                 const Icon(Icons.location_on, size: 12, color: Color(0xFF2196F3)),
                 const SizedBox(width: 4),
                 Text(
                   _isLoading ? '...' : (_latestCuaca?.kota ?? 'Jakarta Pusat'),
                   style: const TextStyle(
                     color: Color(0xFF2196F3),
                     fontSize: 12,
                     fontWeight: FontWeight.w500,
                   ),
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
          onPressed: () { if (onBack != null) {
            onBack!();
          } else {
            Navigator.pop(context);
          } },
          onPressed: () { if (widget.onBack != null) widget.onBack!(); else Navigator.pop(context); },
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE1F5FE),
            Color(0xFFE1F5FE),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'SAAT INI',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isLoading ? '--' : '${_latestCuaca?.suhu ?? 32}°',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLoading ? '...' : (_latestCuaca?.cuaca.isNotEmpty == true ? _latestCuaca!.cuaca : 'Berawan'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF424242),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Terasa seperti ${_isLoading ? "..." : (_latestCuaca != null ? _latestCuaca!.suhu + 2 : 36)}°C',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF757575),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                   SizedBox(
                     height: 80,
                     width: 80,
                     child: _isLoading 
                          ? const Center(child: CircularProgressIndicator()) 
                          : (_latestCuaca != null && _latestCuaca!.image.isNotEmpty 
                              ? Center(
                                  child: Image.network(
                                    _latestCuaca!.image,
                                    width: 60,
                                    height: 60,
                                    errorBuilder: (context, error, stackTrace) => const Icon(
                                      Icons.cloud,
                                      size: 50,
                                      color: Color(0xFF90A4AE),
                                    ),
                                  ),
                                )
                              : Stack(
                                  children: [
                                    Positioned(
                                      top: 5,
                                      right: 15,
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFFFC107),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 10,
                                      left: 5,
                                      child: Container(
                                        width: 60,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.05),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                   ),
                  const SizedBox(height: 8),
                  _buildWeatherStat(Icons.water_drop, 'Kelembapan ${_isLoading ? "--" : _latestCuaca?.kelembapan ?? 65}%', const Color(0xFF2196F3)),
                  const SizedBox(height: 4),
                  _buildWeatherStat(Icons.air, 'Angin ${_isLoading ? "--" : _latestCuaca?.kecAngin ?? 12} km/j', const Color(0xFF4DB6AC)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildWeatherStat(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEarlyWarningCard() {
    final String warningMsg = _isLoading 
        ? "Memeriksa peringatan cuaca..." 
        : (_latestCuaca?.peringatanDini ?? "Sedang tidak ada peringatan cuaca yang signifikan untuk saat ini.");
        
    final bool hasWarning = warningMsg.contains("Waspada");

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasWarning ? const Color(0xFFFFF3E0) : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: hasWarning ? const Color(0xFFFFE0B2) : const Color(0xFFC8E6C9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: hasWarning ? const Color(0xFFFF9800) : const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              hasWarning ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded, 
              color: Colors.white, 
              size: 20
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
                    color: hasWarning ? const Color(0xFFE65100) : const Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  warningMsg,
                  style: TextStyle(
                    fontSize: 12,
                    color: hasWarning ? const Color(0xFFE65100) : const Color(0xFF388E3C),
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

    return Column(
      children: _latestCuaca!.dailyForecasts.map((f) => _buildForecastItem(f)).toList(),
    );
  }

  Widget _buildForecastItem(DailyForecast data) {
    final isEst = data.isEstimate;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: isEst ? Colors.white.withOpacity(0.6) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isEst ? Colors.grey.withOpacity(0.08) : Colors.grey.withOpacity(0.12),
          style: isEst ? BorderStyle.none : BorderStyle.solid,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isEst ? 0.01 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 90,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.dayName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isEst ? const Color(0xFF9E9E9E) : const Color(0xFF424242),
                  ),
                ),
                if (isEst)
                  const Text(
                    'estimasi',
                    style: TextStyle(fontSize: 9, color: Color(0xFFBDBDBD), fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          ),
          Opacity(
            opacity: isEst ? 0.6 : 1.0,
            child: Column(
              children: [
                Image.network(
                  data.imagePath,
                  width: 28,
                  height: 28,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.cloud,
                    color: Color(0xFF90A4AE),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.condition,
                  style: TextStyle(
                    fontSize: 10,
                    color: isEst ? Colors.grey[300] : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${data.maxTemp}°',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isEst ? const Color(0xFFBDBDBD) : const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${data.minTemp}°',
                  style: TextStyle(
                    fontSize: 14,
                    color: isEst ? Colors.grey[300] : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildInsuranceSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 4))]),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Color(0xFFE3F2FD), shape: BoxShape.circle),
            child: const Icon(Icons.security, color: Color(0xFF2196F3), size: 32),
          ),
          const SizedBox(height: 16),
          const Text('Asuransi Pro-Siaga', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
          const SizedBox(height: 8),
          const Text('Perlindungan aset dan kesehatan keluarga dari dampak bencana alam.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Color(0xFF757575), height: 1.4)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Row(children: const [Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 16), SizedBox(width: 8), Text('Klaim cepat 24 jam', style: TextStyle(fontSize: 12, color: Color(0xFF424242)))]),
                const SizedBox(height: 8),
                Row(children: const [Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 16), SizedBox(width: 8), Text('Cover gempa & banjir', style: TextStyle(fontSize: 12, color: Color(0xFF424242)))]),
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
                  MaterialPageRoute(builder: (context) => const AsuransiWebPage()),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BCD4), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Cek Asuransi Sekarang', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Disponsori • S&K berlaku', style: TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
        ],
      ),
    );
  }
}