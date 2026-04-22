import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'services/news_service.dart';
import 'package:intl/intl.dart';

class IsiBeritaPage extends StatelessWidget {
  final NewsModel news;
  
  const IsiBeritaPage({Key? key, required this.news}) : super(key: key);

  String _formatDate(String utcDate) {
    try {
      final date = DateTime.parse(utcDate).toLocal();
      return DateFormat('dd MMMM yyyy').format(date);
    } catch (e) {
      return utcDate;
    }
  }

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse(news.link);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Isi Berita',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Color(0xFF1E293B)),
            onPressed: () {
              // Share action placeholder
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // Main Image
              Hero(
                tag: news.link, // using link as unique tag
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    news.photoUrl.isNotEmpty 
                        ? news.photoUrl 
                        : 'https://via.placeholder.com/400x200?text=No+Image',
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 220,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Meta info
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      news.sourceName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0284C7),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${_formatDate(news.publishedDatetimeUtc)} • 5 menit baca',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Title
              Text(
                news.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 24),
              
              // Summary Box (Ringkasan Utama)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9), // Light grayish-blue
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                    topLeft: Radius.circular(4),
                    bottomLeft: Radius.circular(4),
                  ),
                  border: const Border(
                    left: BorderSide(color: Color(0xFF0284C7), width: 4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.file_copy_outlined, color: Color(0xFF0284C7), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Ringkasan Utama',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0284C7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      news.snippet,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF334155),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Mock Main Body Content because API only gives snippet
              const Text(
                'Kondisi cuaca ekstrem yang dipicu oleh siklon tropis di Samudra Hindia diperkirakan akan memberikan dampak signifikan bagi pemukiman di sepanjang garis pantai. Pihak berwenang telah meningkatkan status kewaspadaan menjadi Level 3.',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF334155),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Meskipun upaya pencegahan fisik seperti tanggul telah dioptimalkan, peran aktif masyarakat dalam menjaga keselamatan diri tetap menjadi kunci utama dalam menghadapi potensi bencana ini.',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF334155),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),
              
              // Critical Action Points Box (Poin Tindakan Kritis)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED), // Light orange background
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.warning_amber_rounded, color: Color(0xFFB45309), size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Poin Tindakan Kritis',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildActionPoint(
                      '1', 
                      'Pindahkan barang elektronik ke lantai atas atau tempat yang lebih tinggi.'
                    ),
                    const SizedBox(height: 16),
                    _buildActionPoint(
                      '2', 
                      'Pastikan dokumen penting terbungkus plastik kedap air di dalam tas darurat.'
                    ),
                    const SizedBox(height: 16),
                    _buildActionPoint(
                      '3', 
                      'Matikan aliran listrik utama di rumah jika air mulai masuk ke pekarangan.'
                    ),
                    const SizedBox(height: 16),
                    _buildActionPoint(
                      '4', 
                      'Hafalkan rute evakuasi terdekat menuju Balai Desa atau Gedung Olahraga.'
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Button to read full original news
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _launchUrl,
                  icon: const Icon(Icons.open_in_browser),
                  label: const Text('Baca Berita Asli'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionPoint(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Color(0xFFF59E0B),
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
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1E293B),
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
