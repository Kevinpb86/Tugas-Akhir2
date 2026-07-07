import 'package:flutter/material.dart';

class PanduanAnomaliPage extends StatelessWidget {
  const PanduanAnomaliPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Panduan Anomali Seismisitas',
          style: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFCC80)),
              ),
              child: Column(
                children: const [
                  Icon(Icons.warning_amber_rounded, size: 48, color: Color(0xFFF57C00)),
                  SizedBox(height: 12),
                  Text(
                    'Pentingnya Kewaspadaan Ekstra',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE65100),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Apa itu Deteksi Anomali?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 12),
            const Text(
              'Sistem ini secara real-time membandingkan gempa yang baru terjadi dengan data historis di wilayah tersebut. Jika kombinasi kekuatan (magnitudo) dan kedalamannya jauh menyimpang dari kebiasaan normal, sistem akan menandainya sebagai anomali.',
              style: TextStyle(fontSize: 14, color: Color(0xFF424242), height: 1.6),
            ),
            const SizedBox(height: 24),
            const Text(
              'Tindakan yang Disarankan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 12),
            _buildActionItem(
              '1',
              'Tetap Tenang',
              'Jangan panik. Status anomali bukan berarti pasti terjadi bencana susulan berskala besar, melainkan sekadar variasi data alam.',
            ),
            _buildActionItem(
              '2',
              'Cek Informasi Resmi',
              'Terus pantau informasi dari BMKG dan BPBD setempat terkait potensi bahaya lanjutan seperti tsunami atau longsor.',
            ),
            _buildActionItem(
              '3',
              'Siapkan Tas Siaga',
              'Pastikan Tas Siaga Bencana (TSB) Anda mudah dijangkau jika sewaktu-waktu harus melakukan evakuasi mendadak.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
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
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF424242),
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
}
