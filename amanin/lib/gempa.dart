import 'package:flutter/material.dart';
import 'akun.dart';
import 'main.dart';
import 'login.dart';
import 'asuransi.dart';

class GempaPage extends StatelessWidget {
  const GempaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildFilterChips(),
              const SizedBox(height: 24),
              _buildMainEarthquakeCard(),
              const SizedBox(height: 24),
              _buildHistoryHeader(),
              const SizedBox(height: 16),
              _buildRecentEarthquakes(context),
              const SizedBox(height: 24),
              _buildInsuranceSection(context),
              const SizedBox(height: 100), // padding for floating bottom nav
            ],
          ),
        ),
      ),
    );
  }

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
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.location_on, color: Color(0xFF2196F3), size: 12),
                  SizedBox(width: 4),
                  Text(
                    'Jakarta Pusat',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF2196F3),
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
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFEEEEEE),
                              width: 1,
                            ),
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
                                color: const Color(0xFF00BCD4).withOpacity(0.3),
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

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip('Terkini', true),
          _buildChip('M ≥ 5', false),
          _buildChip('Dirasakan', false),
          _buildChip('Real-Time', false),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFFF1F8E9)
            : Colors
                  .transparent, // Adjust slightly since standard is blue but this looks blue text on light blue
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? const Color(0xFF2196F3) : const Color(0xFFE0E0E0),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? const Color(0xFF2196F3) : const Color(0xFF757575),
          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildMainEarthquakeCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Map Placeholder Area
          Container(
            height: 180,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.map,
                    size: 80,
                    color: const Color(0xFFCBD5E1),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.map_outlined,
                          color: Color(0xFF1E40AF),
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Peta Guncangan',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.share,
                      size: 16,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 15,
                        height: 15,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Gempabumi Dirasakan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'MAJOR ALERT',
                        style: TextStyle(
                          color: Color(0xFFF44336),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoBox(
                        '≈ 5.7',
                        'Magnitudo',
                        const Color(0xFFF44336),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoBox(
                        '10 Km',
                        'Kedalaman',
                        const Color(0xFF4CAF50),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoBox(
                        '1.54 LU',
                        'Lokasi',
                        const Color(0xFF2196F3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDetailRow(
                  Icons.access_time,
                  '19 Februari 2026, 07:26:15 WIB',
                  'Waktu Gempa',
                  const Color(0xFFFF9800),
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  Icons.track_changes,
                  'III-IV Buol, III Gorontalo Utara, II-III Gorontalo, II-III Bone Bolango',
                  'Wilayah Dirasakan (MMI)',
                  const Color(0xFFFF5722),
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  Icons.location_on,
                  'Pusat gempa berada di laut 110 Km Timur Laut Buol',
                  null,
                  const Color(0xFFFF9800),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9800),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Saya juga merasakannya',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.back_hand, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String value, String label, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF757575)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String text,
    String? subtext,
    Color iconColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                  height: 1.4,
                ),
              ),
              if (subtext != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtext,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Riwayat Gempa',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        Text(
          'Lihat Semua',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2196F3),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentEarthquakes(BuildContext context) {
    return Column(
      children: [
        _buildHistoryItem(
          context,
          '4.9',
          'Barat Daya Kuta Sel...',
          'Pusat gempa berada di laut',
          '19 Feb',
          '05:12 WIB',
          '10 km',
          const Color(0xFFFFC107),
        ),
        _buildHistoryItem(
          context,
          '3.2',
          'Tenggara Pacitan',
          'Tidak berpotensi tsunami',
          '18 Feb',
          '23:45 WIB',
          '15 km',
          const Color(0xFF42A5F5),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    String mag,
    String title,
    String subtitle,
    String date,
    String time,
    String depth,
    Color magColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 60,
            decoration: BoxDecoration(
              color: magColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  mag,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const Text(
                  'MAG',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF757575),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 10,
                      color: Color(0xFF9E9E9E),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.access_time,
                      size: 10,
                      color: Color(0xFF9E9E9E),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  children: [
                    Text(
                      depth.split(' ')[0],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      'km',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF64748B),
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                size: 16,
                color: Color(0xFFCBD5E1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsuranceSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
                  MaterialPageRoute(builder: (context) => const AsuransiWebPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF03A9F4),
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
