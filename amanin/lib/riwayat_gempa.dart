import 'package:flutter/material.dart';
import 'services/bmkg_service.dart';
import 'gempa_detail.dart';
import 'fullscreen_map.dart';

class RiwayatGempaPage extends StatelessWidget {
  final List<GempaModel> quakes;

  const RiwayatGempaPage({super.key, required this.quakes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text(
          'Riwayat Gempa',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: quakes.length,
        itemBuilder: (context, index) {
          final quake = quakes[index];
          final String date = quake.tanggal.split(' ').take(2).join(' ');
          final String time = quake.jam.replaceAll(' WIB', '');
          Color magColor = const Color(0xFFFFC107);

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullscreenMapPage(gempa: quake),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: magColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              quake.magnitude,
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
                                fontWeight: FontWeight.bold,
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
                              quake.wilayah,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 12, color: Color(0xFF9E9E9E)),
                                const SizedBox(width: 4),
                                Text(
                                  '$date, $time',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF757575)),
                                ),
                                const SizedBox(width: 12),
                                const Icon(Icons.show_chart, size: 12, color: Color(0xFF9E9E9E)),
                                const SizedBox(width: 4),
                                Text(
                                  quake.kedalaman,
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF757575)),
                                ),
                              ],
                            ),
                            if (quake.dirasakan.isNotEmpty && quake.dirasakan != '-') ...[
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF3E0),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Dirasakan',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF9800),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Color(0xFFE0E0E0)),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
