import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'gempa_detail.dart';
import 'cuaca.dart';
import 'edukasi.dart';
import 'gempa.dart';
import 'akun.dart';
import 'utils/localization.dart';

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  late final WebViewController _controller;
  
  // Earthquake location: 81 Km Barat Daya Kuta Selatan
  final double _latitude = -8.8;
  final double _longitude = 115.0;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _initializeWebView();
    }
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(_getMapHtml());
  }

  String _getMapHtml() {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <style>
        body, html { margin: 0; padding: 0; height: 100%; }
        #map { height: 100%; width: 100%; }
      </style>
    </head>
    <body>
      <div id="map"></div>
      <script>
        function initMap() {
          const earthquakeLocation = { lat: $_latitude, lng: $_longitude };
          const map = new google.maps.Map(document.getElementById("map"), {
            zoom: 8,
            center: earthquakeLocation,
            mapTypeId: 'terrain'
          });
          
          const marker = new google.maps.Marker({
            position: earthquakeLocation,
            map: map,
            title: "Gempabumi Terkini",
            animation: google.maps.Animation.DROP
          });
          
          const infoWindow = new google.maps.InfoWindow({
            content: '<div style="padding:10px;"><h3>Gempabumi Terkini</h3><p>Magnitudo: 4.3 SR</p><p>Lokasi: 81 Km Barat Daya Kuta Selatan</p></div>'
          });
          
          marker.addListener("click", () => {
            infoWindow.open(map, marker);
          });
        }
      </script>
      <script async defer
        src="https://maps.googleapis.com/maps/api/js?key=AIzaSyBFhfkKjQ9cVl87LYVD8GPJdamlHBCbOOs&callback=initMap">
      </script>
    </body>
    </html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeader(),
                const SizedBox(height: 24),
                
                // Earthquake Status Section
                _buildEarthquakeStatus(),
                const SizedBox(height: 16),
                
                // Merged Earthquake Card
                _buildEarthquakeCard(),
                const SizedBox(height: 16),
                
                // Survival Kit Card
                _buildSurvivalKitSection(),
                const SizedBox(height: 24),
                
                // Weather Card
                _buildWeatherCard(),
                const SizedBox(height: 16),
                
                // Early Warning Card
                _buildEarlyWarningCard(),
                const SizedBox(height: 24),
                
                // News Section
                _buildNewsSection(),
                const SizedBox(height: 24),

                // Asuransi Section
                _buildInsuranceSection(),
                const SizedBox(height: 100), // padding for floating bottom nav
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildMenuItem(Icons.report_problem_outlined, Localization.of(context).get('home_menu_report'), const Color(0xFFFFEBEE), const Color(0xFFEF5350)),
        _buildMenuItem(Icons.volunteer_activism_outlined, Localization.of(context).get('home_menu_donate'), const Color(0xFFE8F5E9), const Color(0xFF66BB6A)),
        _buildMenuItem(Icons.check_circle_outline, Localization.of(context).get('home_menu_safe'), const Color(0xFFE3F2FD), const Color(0xFF42A5F5)),
        _buildMenuItem(Icons.map_outlined, Localization.of(context).get('home_menu_map'), const Color(0xFFFFF3E0), const Color(0xFFFFCA28)),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String label, Color bgColor, Color iconColor) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF424242),
          ),
        ),
      ],
    );
  }



  // Helper method for News Section (needed to be moved/created if not existing in view, but assuming it exists or needs replacement)
  // Since the original view didn't show _buildNewsSection content in detail, I will target the known functions above first.
  // Wait, I need to check if _buildNewsSection is available in the file.




  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Localization.of(context).get('home_header_title'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Color(0xFF00BCD4),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  Localization.of(context).get('home_location'),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF00BCD4),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            // Notification Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
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
                    right: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF5252),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Profile Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AkunPage()),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: const Center(
                    child: Icon(
                      Icons.person_outline,
                      color: Color(0xFF1A1A1A),
                      size: 24,
                    ),
                  ),
                ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEarthquakeStatus() {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFFFF5252),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          Localization.of(context).get('home_quake_status_danger'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFF5252).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'MAJOR ALERT',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF5252),
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEarthquakeCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                child: SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: kIsWeb ? Container(color: const Color(0xFF90EE90).withOpacity(0.3), child: const Center(child: Icon(Icons.map, size: 48, color: Color(0xFF4CAF50)))) : WebViewWidget(controller: _controller),
                ),
              ),
              Positioned(
                top: 12, left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(6)),
                  child: const Text('LIVE TRACKING', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('MAGNITUDO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9E9E9E), letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    RichText(text: const TextSpan(children: [TextSpan(text: '4.3', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A), height: 1.2)), TextSpan(text: ' SR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF9E9E9E)))])),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFFFFEAEA), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.waves, color: Color(0xFFFF5252), size: 30),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('LOKASI PUSAT', '81 Km Barat Daya Kuta Selatan'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildDetailRow('KEDALAMAN', ' 37 Km')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildDetailRow('WAKTU', ' 02:23 WIB')),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity, height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const GempaDetailPage()));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [Text('DETAIL LENGKAP', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5)), SizedBox(width: 8), Icon(Icons.arrow_forward, size: 16)]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurvivalKitSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.shopping_bag, color: Color(0xFF0088CC), size: 24),
                SizedBox(width: 8),
                Text('Perlengkapan Siaga', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
              ],
            ),
            const Text('Diskon Spesial', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF00BCD4))),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 4))]),
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.backpack, color: Color(0xFF4CAF50), size: 40),
                  ),
                  Positioned(
                    top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFFF5252), borderRadius: BorderRadius.circular(4)),
                      child: const Text('30%', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sedia Payung Sebelum Gempa!', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
                    const SizedBox(height: 4),
                    const Text('Paket survival kit lengkap untuk 3 hari darurat. Tas anti-air & senter', style: TextStyle(fontSize: 11, color: Color(0xFF757575)), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Rp 450.000', style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E), decoration: TextDecoration.lineThrough)),
                            Text('Rp 315.000', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFFF5252), height: 1.1)),
                          ],
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BCD4), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          child: const Text('Beli Sekarang', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInsuranceSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 4))]),
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
          const Text('Perlindungan aset dan kesehatan keluarga dari dampak bencana alam.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Color(0xFF757575))),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
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

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9E9E9E),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Cuaca Lokal',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            Row(
              children: const [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Color(0xFF757575),
                ),
                SizedBox(width: 4),
                Text(
                  'Cilacap',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFE1F5FE), // Sangat muda
                Color(0xFFB3E5FC), // Agak biru
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Weather Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2196F3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'SAAT INI',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Berawan',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Terasa seperti 34°C',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF757575),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '32',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w300,
                            color: Color(0xFF1A1A1A),
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              '°',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w300,
                                color: Color(0xFF1A1A1A),
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.cloud,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Bottom Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildWeatherDetail(
                      Icons.water_drop,
                      '94%',
                      'Air',
                      const Color(0xFF2196F3),
                    ),
                    _buildWeatherDetail(
                      Icons.air,
                      '3.6',
                      'km/h',
                      const Color(0xFF4CAF50),
                    ),
                    _buildWeatherDetail(
                      Icons.wb_sunny,
                      'UV 6',
                      'Sedang',
                      const Color(0xFFFF9800),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherDetail(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF757575),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarlyWarningCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFB74D),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Peringatan Dini',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Waspada potensi hujan disertai kilat/petir dan angin kencang di sebagian wilayah Jakarta dan Jaktim pada sore hari.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF424242),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             Text(
              Localization.of(context).get('home_news_title'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to all news
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                Localization.of(context).get('home_news_more'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00BCD4),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Horizontal Scrollable News Cards
        SizedBox(
          height: 280,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildNewsCard(
                'BMKG',
                'Analisis Dinamika Atmosfer Dasarian II Februari 2026',
                '1 Jam yang lalu',
                const Color(0xFF2196F3),
                Icons.cloud,
              ),
              const SizedBox(width: 12),
              _buildNewsCard(
                'LHK',
                'Status Siaga Kebakaran Hutan dan Lahan di Wilayah Sumatera',
                '3 Jam yang lalu',
                const Color(0xFF4CAF50),
                Icons.local_fire_department,
              ),
              const SizedBox(width: 12),
              _buildNewsCard(
                'BMKG',
                'Prakiraan Cuaca Ekstrem untuk Wilayah Jawa Barat',
                '5 Jam yang lalu',
                const Color(0xFF2196F3),
                Icons.thunderstorm,
              ),
              const SizedBox(width: 12),
              _buildNewsCard(
                'BNPB',
                'Peringatan Dini Tsunami di Pesisir Selatan Jawa',
                '6 Jam yang lalu',
                const Color(0xFFFF5252),
                Icons.tsunami,
              ),
              const SizedBox(width: 12),
              _buildNewsCard(
                'PVMBG',
                'Status Aktivitas Gunung Merapi Meningkat ke Level Siaga',
                '8 Jam yang lalu',
                const Color(0xFFFF9800),
                Icons.landscape,
              ),
              const SizedBox(width: 12),
              _buildNewsCard(
                'BMKG',
                'Potensi Hujan Lebat dan Angin Kencang di Wilayah Kalimantan',
                '10 Jam yang lalu',
                const Color(0xFF2196F3),
                Icons.water_drop,
              ),
              const SizedBox(width: 12),
              _buildNewsCard(
                'BNPB',
                'Update Banjir Bandang di Kabupaten Bogor',
                '12 Jam yang lalu',
                const Color(0xFFFF5252),
                Icons.flood,
              ),
              const SizedBox(width: 12),
              _buildNewsCard(
                'LHK',
                'Monitoring Kualitas Udara di Jakarta dan Sekitarnya',
                '1 Hari yang lalu',
                const Color(0xFF4CAF50),
                Icons.air,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNewsCard(
    String category,
    String title,
    String time,
    Color categoryColor,
    IconData icon,
  ) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image/Icon Section
          Container(
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  categoryColor.withOpacity(0.7),
                  categoryColor.withOpacity(0.9),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Stack(
              children: [
                // Background pattern
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.1,
                    child: Icon(
                      icon,
                      size: 120,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Category Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: categoryColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                // Main Icon
                Center(
                  child: Icon(
                    icon,
                    size: 64,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          // Content Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
