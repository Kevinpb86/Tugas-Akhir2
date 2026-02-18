import 'package:flutter/material.dart';
import 'beranda.dart';
import 'edukasi.dart'; // Import for navigation consistency if needed

class CuacaPage extends StatelessWidget {
  const CuacaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          children: const [
             Text(
              'Cuaca Mingguan',
              style: TextStyle(
                color: Color(0xFF1A1A1A),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
             SizedBox(height: 2),
             Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Icon(Icons.location_on, size: 12, color: Color(0xFF2196F3)),
                 SizedBox(width: 4),
                 Text(
                   'Jakarta Pusat',
                   style: TextStyle(
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
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
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
              const SizedBox(height: 80), // Bottom padding
            ],
          ),
        ),
      ),
      // Use existing bottom nav structure or similar look
      bottomNavigationBar: _buildBottomNavigationBar(context),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildCurrentWeatherCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD), // Light blue background
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE3F2FD),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2196F3).withOpacity(0.1),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '32°',
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                      height: 1,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Berawan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF424242),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Terasa seperti 36°C',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF757575),
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.wb_sunny_rounded, // Replace with cloud/sun mix asset if available
                size: 80,
                color: Color(0xFFFFB74D), // Sun color
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildWeatherStat(Icons.water_drop, 'Kelembapan 65%', const Color(0xFF2196F3)),
              const SizedBox(width: 16),
              _buildWeatherStat(Icons.air, 'Angin 12 km/j', const Color(0xFF4DB6AC)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherStat(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEarlyWarningCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFE0B2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Peringatan Dini',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE65100),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Waspada potensi hujan lebat disertai kilat/petir di Jakarta Selatan sore ini.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFE65100),
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
    final List<Map<String, dynamic>> forecasts = [
      {'day': 'Besok', 'icon': Icons.wb_sunny_rounded, 'cond': 'Cerah', 'max': 33, 'min': 24, 'color': const Color(0xFFFFB74D)},
      {'day': 'Kamis', 'icon': Icons.cloud_rounded, 'cond': 'Berawan', 'max': 31, 'min': 23, 'color': const Color(0xFF90A4AE)},
      {'day': 'Jumat', 'icon': Icons.thunderstorm_rounded, 'cond': 'Hujan Petir', 'max': 29, 'min': 22, 'color': const Color(0xFF5C6BC0)},
      {'day': 'Sabtu', 'icon': Icons.water_drop_rounded, 'cond': 'Hujan Ringan', 'max': 30, 'min': 23, 'color': const Color(0xFF42A5F5)},
      {'day': 'Minggu', 'icon': Icons.wb_cloudy_rounded, 'cond': 'Cerah Berawan', 'max': 32, 'min': 24, 'color': const Color(0xFFFFB74D)},
      {'day': 'Senin', 'icon': Icons.wb_sunny_rounded, 'cond': 'Cerah', 'max': 33, 'min': 24, 'color': const Color(0xFFFFB74D)},
      {'day': 'Selasa', 'icon': Icons.cloud_rounded, 'cond': 'Berawan', 'max': 31, 'min': 23, 'color': const Color(0xFF90A4AE)},
    ];

    return Column(
      children: forecasts.map((f) => _buildForecastItem(f)).toList(),
    );
  }

  Widget _buildForecastItem(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              data['day'],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF424242),
              ),
            ),
          ),
          Column(
            children: [
              Icon(data['icon'], color: data['color'], size: 28),
              const SizedBox(height: 4),
              Text(
                data['cond'],
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
          SizedBox(
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${data['max']}°',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${data['min']}°',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Bottom Nav Elements (Replicated from Beranda for consistency/demo)
  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(Icons.home_outlined, 'Beranda', false, () => Navigator.pop(context)),
              _buildNavItem(Icons.cloud, 'Cuaca', true, () {}),
              const SizedBox(width: 60), // Space for FAB
              _buildNavItem(Icons.language, 'Gempa', false, () {}),
              _buildNavItem(Icons.school_outlined, 'Edukasi', false, () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const EdukasiPage()),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFF00BCD4) : const Color(0xFF9E9E9E),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? const Color(0xFF00BCD4) : const Color(0xFF9E9E9E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF00BCD4),
            Color(0xFF00ACC1),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00BCD4).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(32),
          child: const Center(
            child: Icon(
              Icons.location_on,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
