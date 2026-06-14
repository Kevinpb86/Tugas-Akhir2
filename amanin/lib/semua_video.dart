import 'package:flutter/material.dart';

class SemuaVideoPage extends StatelessWidget {
  const SemuaVideoPage({super.key});

  static const List<Map<String, String>> _videos = [
    {
      'judul': 'Simulasi Evakuasi Mandiri Saat Gempa Bumi',
      'durasi': '04:35',
      'sumber': 'BNPB Indonesia',
      'channel': 'youtube.com/@BNPBIndonesia',
      'deskripsi': 'Panduan visual cara melakukan evakuasi mandiri saat terjadi gempa bumi di area padat penduduk.',
      'tag': 'Evakuasi',
      'tagColor': '0xFF2196F3',
    },
    {
      'judul': 'Mengenal Skala Gempa dan Dampaknya',
      'durasi': '06:12',
      'sumber': 'BMKG Official',
      'channel': 'youtube.com/@infoBMKG',
      'deskripsi': 'Penjelasan lengkap mengenai skala magnitudo dan Modified Mercalli Intensity (MMI) serta dampaknya bagi masyarakat.',
      'tag': 'Edukasi',
      'tagColor': '0xFF4CAF50',
    },
    {
      'judul': 'Cara Membuat Tas Siaga Bencana',
      'durasi': '05:47',
      'sumber': 'BNPB Indonesia',
      'channel': 'youtube.com/@BNPBIndonesia',
      'deskripsi': 'Panduan menyiapkan tas siaga bencana yang ideal untuk bertahan 3 hari pertama pasca bencana.',
      'tag': 'Persiapan',
      'tagColor': '0xFFFF9800',
    },
    {
      'judul': 'Pertolongan Pertama Korban Gempa',
      'durasi': '08:03',
      'sumber': 'PMI Indonesia',
      'channel': 'youtube.com/@PMIIndonesia',
      'deskripsi': 'Teknik dasar pertolongan pertama untuk korban gempa bumi, termasuk penanganan luka, patah tulang, dan korban pingsan.',
      'tag': 'P3K',
      'tagColor': '0xFFE53935',
    },
    {
      'judul': 'Mitigasi Bencana Gempa untuk Anak-anak',
      'durasi': '03:20',
      'sumber': 'BNPB Indonesia',
      'channel': 'youtube.com/@BNPBIndonesia',
      'deskripsi': 'Edukasi mitigasi bencana gempa yang dikemas secara sederhana dan mudah dipahami oleh anak-anak.',
      'tag': 'Anak-anak',
      'tagColor': '0xFF9C27B0',
    },
    {
      'judul': 'Bangunan Tahan Gempa: Panduan Dasar',
      'durasi': '07:55',
      'sumber': 'BMKG Official',
      'channel': 'youtube.com/@infoBMKG',
      'deskripsi': 'Prinsip dasar konstruksi bangunan tahan gempa yang perlu diketahui masyarakat awam.',
      'tag': 'Konstruksi',
      'tagColor': '0xFF795548',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Video Edukasi'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Color(0xFF1A1A1A),
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF90CAF9)),
            ),
            child: Row(
              children: const [
                Icon(Icons.info_outline, color: Color(0xFF1976D2), size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Video bersumber dari channel resmi BMKG, BNPB, dan PMI. Tonton langsung di YouTube untuk kualitas terbaik.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF1565C0),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: _videos.length,
              itemBuilder: (context, index) {
                final video = _videos[index];
                final tagColor = Color(int.parse(video['tagColor']!));

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thumbnail
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: Container(
                          height: 130,
                          width: double.infinity,
                          color: const Color(0xFFE0E0E0),
                          child: Stack(
                            children: [
                              Center(
                                child: Icon(
                                  Icons.play_circle_fill,
                                  size: 48,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    video['durasi']!,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: tagColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    video['tag']!,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              video['judul']!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              video['deskripsi']!,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  height: 1.4),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.source,
                                    size: 12, color: Color(0xFF9E9E9E)),
                                const SizedBox(width: 4),
                                Text(
                                  video['sumber']!,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF9E9E9E),
                                      fontWeight: FontWeight.w600),
                                ),
                                const Spacer(),
                                const Icon(Icons.open_in_new,
                                    size: 12, color: Color(0xFF2196F3)),
                                const SizedBox(width: 4),
                                const Text(
                                  'Buka YouTube',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF2196F3),
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
