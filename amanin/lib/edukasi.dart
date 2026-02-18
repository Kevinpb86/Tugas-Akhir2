import 'package:flutter/material.dart';
import 'beranda.dart';
import 'gempa.dart';
import 'cuaca.dart';
// import 'gempa.dart'; // Future import

class EdukasiPage extends StatelessWidget {
  const EdukasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Column(
          children: const [
            Text(
              'Edukasi Bencana',
              style: TextStyle(
                color: Color(0xFF1A1A1A),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Panduan Keselamatan Gempa Bumi',
              style: TextStyle(
                color: Color(0xFF757575),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Intro Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF00BCD4),
                    Color(0xFF00ACC1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00BCD4).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Siaga Gempa Bumi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Pahami langkah-langkah keselamatan yang harus dilakukan sebelum, saat, dan sesudah gempa bumi terjadi.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Section 1: SAAT Terjadi Gempa (DURING) - HIGHLIGHT
            _buildSectionHeader('SAAT TERJADI GEMPA', Icons.warning_amber_rounded, const Color(0xFFE65100)),
            const SizedBox(height: 12),
            _buildSafetyCard(
              title: 'Drop, Cover, Hold On!',
              description: 'Segera MENUNDUK ke lantai, BERLINDUNG di bawah meja yang kuat, dan PEGANGAN hingga guncangan berhenti.',
              icon: Icons.accessibility_new_rounded,
              color: const Color(0xFFE65100),
              isHighlight: true,
            ),
            const SizedBox(height: 12),
            _buildSafetyCard(
              title: 'Jauhi Kaca & Benda Berat',
              description: 'Menjauh dari jendela kaca, lemari, cermin, dan benda yang bisa jatuh menimpa Anda.',
              icon: Icons.window_rounded,
              color: const Color(0xFFFF9800),
            ),
            const SizedBox(height: 12),
            _buildSafetyCard(
              title: 'Tetap di Dalam Ruangan',
              description: 'Jangan berlari keluar saat guncangan masih terjadi. Bahaya terbesar adalah benda jatuh.',
              icon: Icons.house_rounded,
              color: const Color(0xFFFF9800),
            ),

            const SizedBox(height: 24),

            // Section 2: SETELAH Gempa (AFTER)
            _buildSectionHeader('SETELAH GEMPA BERHENTI', Icons.check_circle_outline_rounded, const Color(0xFF2E7D32)),
            const SizedBox(height: 12),
            _buildSafetyCard(
              title: 'Periksa Cedera & Bahaya',
              description: 'Periksa diri sendiri dan orang sekitar. Waspada kebocoran gas, kabel putus, atau kerusakan struktur.',
              icon: Icons.medical_services_outlined,
              color: const Color(0xFF43A047),
            ),
            const SizedBox(height: 12),
            _buildSafetyCard(
              title: 'Evakuasi ke Tempat Terbuka',
              description: 'Menuju titik kumpul yang aman, jauh dari gedung tinggi, pohon, dan tiang listrik.',
              icon: Icons.directions_run_rounded,
              color: const Color(0xFF43A047),
            ),
            const SizedBox(height: 12),
            _buildSafetyCard(
              title: 'Waspada Gempa Susulan',
              description: 'Gempa susulan (aftershocks) umum terjadi. Tetap waspada dan jangan masuk kembali ke bangunan rusak.',
              icon: Icons.waves_rounded,
              color: const Color(0xFF43A047),
            ),

            const SizedBox(height: 24),

            // Section 3: PERSIAPAN (BEFORE)
            _buildSectionHeader('PERSIAPAN SEBELUMNYA', Icons.backpack_outlined, const Color(0xFF1565C0)),
            const SizedBox(height: 12),
            _buildSafetyCard(
              title: 'Siapkan Tas Siaga Bencana',
              description: 'Isi dengan P3K, makanan awet, air, senter, baterai, radio, dan dokumen penting.',
              icon: Icons.local_mall_outlined,
              color: const Color(0xFF1E88E5),
            ),
            
            const SizedBox(height: 24),

            // Section 4: JENIS BENCANA LAINNYA
            _buildSectionHeader('JENIS BENCANA LAINNYA', Icons.category_outlined, const Color(0xFF5E35B1)),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  _buildDisasterTypeCard(
                    'Tsunami',
                    'Lari ke tempat tinggi',
                    Icons.water_rounded,
                    const Color(0xFF0277BD),
                  ),
                  const SizedBox(width: 12),
                  _buildDisasterTypeCard(
                    'Banjir',
                    'Matikan listrik & evakuasi',
                    Icons.flood_rounded,
                    const Color(0xFF00838F),
                  ),
                  const SizedBox(width: 12),
                  _buildDisasterTypeCard(
                    'Longsor',
                    'Jauhi tebing curam',
                    Icons.landscape_rounded,
                    const Color(0xFF5D4037),
                  ),
                  const SizedBox(width: 12),
                  _buildDisasterTypeCard(
                    'Gunung Api',
                    'Gunakan masker debu',
                    Icons.volcano_rounded,
                    const Color(0xFFD84315),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section 5: NOMOR PENTING
            _buildSectionHeader('NOMOR PENTING', Icons.phone_in_talk_rounded, const Color(0xFFC62828)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildEmergencyContact('Ambulance / Medis', '118 / 119', Icons.medical_services_rounded),
                  const Divider(height: 24),
                  _buildEmergencyContact('Pemadam Kebakaran', '113', Icons.fire_truck),
                  const Divider(height: 24),
                  _buildEmergencyContact('Polisi', '110', Icons.local_police_rounded),
                  const Divider(height: 24),
                  _buildEmergencyContact('SAR / Basarnas', '115', Icons.support_rounded),
                ],
              ),
            ),
            
             const SizedBox(height: 80), // Bottom padding
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSafetyCard({
    required String title, 
    required String description, 
    required IconData icon, 
    required Color color,
    bool isHighlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isHighlight ? Border.all(color: color.withOpacity(0.5), width: 2) : Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF616161),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Bottom Nav - Replicated but Edukasi is Active
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
              _buildNavItem(Icons.home_outlined, 'Beranda', false, () {
                // Return to home, clearing stack appropriately if possible, or just push
                Navigator.of(context).popUntil((route) => route.isFirst);
              }),
              _buildNavItem(Icons.cloud_outlined, 'Cuaca', false, () {
                 Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const CuacaPage()),
                );
              }),
              _buildNavItem(Icons.grid_view_rounded, 'Fitur', false, () {}),
              _buildNavItem(Icons.language, 'Gempa', false, () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const GempaPage()),
                  );
              }),
              _buildNavItem(Icons.school, 'Edukasi', true, () {}),
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

  Widget _buildDisasterTypeCard(String title, String subtitle, IconData icon, Color color) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContact(String name, String number, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFEEEEEE),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF616161), size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              Text(
                number,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC62828),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.call, color: Color(0xFF1976D2), size: 20),
        ),
      ],
    );
  }
}
