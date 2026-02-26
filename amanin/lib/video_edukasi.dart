import 'package:flutter/material.dart';

class VideoEdukasiPage extends StatelessWidget {
  const VideoEdukasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            const Text(
              'Video Edukasi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Channel Resmi Amanin',
                  style: TextStyle(fontSize: 10, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black54),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black54),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Player Placeholder
            Container(
              width: double.infinity,
              height: 220,
              decoration: const BoxDecoration(
                color: Colors.black,
                image: DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1544717305-2782549b5136?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                  ),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2196F3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        const Text('04:35 / 12:00', style: TextStyle(color: Colors.white, fontSize: 12)),
                        const Spacer(),
                        const Icon(Icons.fullscreen, color: Colors.white, size: 20),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24, left: 12, right: 32),
                      child: Container(
                        height: 2,
                        width: double.infinity,
                        color: Colors.white.withOpacity(0.3),
                        alignment: Alignment.centerLeft,
                        child: Container(
                          height: 2,
                          width: 100, // Progress
                          color: const Color(0xFF2196F3),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Simulasi Evakuasi Mandiri:\nGempa Bumi di Area Padat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.visibility, size: 14, color: Colors.black54),
                      const SizedBox(width: 4),
                      const Text('12.5k x ditonton', style: TextStyle(fontSize: 12, color: Colors.black54)),
                      const SizedBox(width: 16),
                      const Icon(Icons.access_time, size: 14, color: Colors.black54),
                      const SizedBox(width: 4),
                      const Text('2 hari lalu', style: TextStyle(fontSize: 12, color: Colors.black54)),
                      const Spacer(),
                      const Icon(Icons.thumb_up_alt_outlined, size: 18, color: Colors.black54),
                      const SizedBox(width: 16),
                      const Icon(Icons.bookmark_border, size: 18, color: Colors.black54),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFF03A9F4),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Amanin Official', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text('Verified Education Partner', style: TextStyle(color: Colors.black54, fontSize: 11)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE1F5FE),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Langganan', style: TextStyle(color: Color(0xFF03A9F4), fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Panduan visual lengkap cara melakukan evakuasi mandiri saat terjadi gempa bumi. Video ini mencakup teknik "Drop, Cover, Hold On" dan cara mengamankan jalur evakuasi di dalam rumah.',
                          style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.5),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: [
                            _buildTag('#MitigasiBencana'),
                            _buildTag('#SafetyFirst'),
                            _buildTag('#Edukasi'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Buka di YouTube', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF03A9F4),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Tonton video ini di aplikasi YouTube untuk kualitas 4K.',
                      style: TextStyle(fontSize: 10, color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Text('Komentar ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('(24)', style: TextStyle(color: Colors.black54, fontSize: 14)),
                        ],
                      ),
                      const Text('Lihat Semua', style: TextStyle(color: Color(0xFF03A9F4), fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildCommentItem('BP', 'Budi Pratama', '1 jam lalu', 'Sangat informatif! Terima kasih Amanin, saya jadi lebih paham apa yang harus dilakukan.', const Color(0xFFFFE0B2), const Color(0xFFE65100)),
                  const SizedBox(height: 12),
                  _buildCommentItem('SR', 'Siti Rahayu', '3 jam lalu', 'Video ini sangat membantu untuk lansia seperti saya. Jelas dan mudah dimengerti.', const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
                  const SizedBox(height: 24),
                  const Text('Video Selanjutnya', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  _buildNextVideoCard(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8FD),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(color: Color(0xFF03A9F4), fontSize: 10)),
    );
  }

  Widget _buildCommentItem(String avatarText, String name, String time, String comment, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(avatarText, style: TextStyle(color: textColor, fontSize: 8, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 8),
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const Spacer(),
              Text(time, style: const TextStyle(color: Colors.black54, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 8),
          Text(comment, style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildNextVideoCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow, color: Colors.white, size: 16),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('03:20', style: TextStyle(color: Colors.white, fontSize: 8)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Persiapan Tas Siaga Bencana untuk Keluarga',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                const Text('Amanin Official', style: TextStyle(color: Colors.black54, fontSize: 10)),
                const SizedBox(height: 4),
                Row(
                  children: const [
                    Icon(Icons.play_circle_fill, color: Color(0xFF03A9F4), size: 12),
                    SizedBox(width: 4),
                    Text('Putar Sekarang', style: TextStyle(color: Color(0xFF03A9F4), fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
