import os, re

filepath = 'lib/cuaca.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    code = f.read()

# Replace _buildCurrentWeatherCard and _buildWeatherStat
weather_regex = re.compile(r'  Widget _buildCurrentWeatherCard\(\) \{.*?  Widget _buildEarlyWarningCard\(\) \{', re.DOTALL)

new_weather = '''  Widget _buildCurrentWeatherCard() {
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
                children: const [
                  Text(
                    '32°',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                      height: 1,
                    ),
                  ),
                  SizedBox(height: 8),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                   SizedBox(
                     height: 80,
                     width: 80,
                     child: Stack(
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
                     ),
                   ),
                  const SizedBox(height: 8),
                  _buildWeatherStat(Icons.water_drop, 'Kelembapan 65%', const Color(0xFF2196F3)),
                  const SizedBox(height: 4),
                  _buildWeatherStat(Icons.air, 'Angin 12 km/j', const Color(0xFF4DB6AC)),
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

  Widget _buildEarlyWarningCard() {'''

code = weather_regex.sub(new_weather, code, count=1)


forecast_list_code = '''              // Weekly Forecast List
              _buildWeeklyForecast(),
              const SizedBox(height: 24),
              _buildInsuranceSection(),
              const SizedBox(height: 100), // Bottom padding for floating nav
            ],'''

code = code.replace('''              // Weekly Forecast List
              _buildWeeklyForecast(),
              const SizedBox(height: 80), // Bottom padding
            ],''', forecast_list_code)

insurance_code = '''
  Widget _buildInsuranceSection() {
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
              onPressed: () {},
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
}'''

# Replace the last `}` with the insurance code. (the very last character of the file should be `}`)
c = code.rsplit('}', 1)
code = c[0] + insurance_code

# Also fix the Peringatan Dini card background color if it matches the screenshot. Wait, looking at the screenshot, the background color is `#FFF3E0` and border `#FFE0B2`. This is already in `cuaca.dart` correctly. So skip changing it.

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(code)

print("cuaca.dart updated properly")
