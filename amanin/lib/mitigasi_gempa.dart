import 'package:flutter/material.dart';

class MitigasiGempaPage extends StatelessWidget {
  const MitigasiGempaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text(
            'Mitigasi Gempa Bumi',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          backgroundColor: const Color(0xFF2196F3),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(fontSize: 13),
            tabs: [
              Tab(text: 'Pra-Bencana'),
              Tab(text: 'Saat Bencana'),
              Tab(text: 'Pasca-Bencana'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPraBencana(),
            _buildSaatBencana(),
            _buildPascaBencana(),
          ],
        ),
      ),
    );
  }

  Widget _buildPraBencana() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Foto placeholder
        _buildImagePlaceholder('Foto persiapan tas siaga (4:3 • ~400×300px)', const Color(0xFF2196F3)),
        const SizedBox(height: 20),
        _buildGroup(
          color: const Color(0xFFF44336),
          label: 'PRIORITAS UTAMA',
          items: [
            _ActionItem(number: 1, text: 'Siapkan tas siaga bencana berisi dokumen penting, obat, dan makanan untuk 3 hari.'),
            _ActionItem(number: 2, text: 'Tentukan titik kumpul keluarga dan pastikan semua anggota keluarga tahu lokasinya.'),
            _ActionItem(number: 3, text: 'Pelajari jalur evakuasi terdekat dari rumah dan tempat kerja.'),
          ],
        ),
        const SizedBox(height: 16),
        _buildGroup(
          color: const Color(0xFF2196F3),
          label: 'PERSIAPAN TAMBAHAN',
          items: [
            _ActionItem(number: 4, text: 'Kenali struktur bangunan tempat tinggal Anda.'),
            _ActionItem(number: 5, text: 'Amankan perabot berat agar tidak mudah jatuh saat guncangan.'),
            _ActionItem(number: 6, text: 'Simpan nomor darurat BPBD dan rumah sakit terdekat di ponsel.'),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSaatBencana() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildImagePlaceholder('Foto ilustrasi berlindung (4:3 • ~400×300px)', const Color(0xFFF44336)),
        const SizedBox(height: 20),
        _buildGroup(
          color: const Color(0xFFF44336),
          label: 'DI DALAM RUANGAN',
          items: [
            _ActionItem(number: 1, text: 'Tetap tenang, jangan panik dan segera berlindung.'),
            _ActionItem(number: 2, text: 'Berlindung di bawah meja yang kuat atau di sudut ruangan.'),
            _ActionItem(number: 3, text: 'Lindungi kepala dan leher dengan tangan atau benda lunak.'),
            _ActionItem(number: 4, text: 'Jauhi jendela, lemari, dan benda yang bisa jatuh.'),
          ],
        ),
        const SizedBox(height: 16),
        _buildGroup(
          color: const Color(0xFFFF9800),
          label: 'DI LUAR RUANGAN',
          items: [
            _ActionItem(number: 1, text: 'Jauhi gedung, tiang listrik, dan pohon tinggi.'),
            _ActionItem(number: 2, text: 'Berlindung di area terbuka, jauh dari struktur bangunan.'),
            _ActionItem(number: 3, text: 'Jangan masuk ke dalam gedung selama guncangan berlangsung.'),
          ],
        ),
        const SizedBox(height: 16),
        _buildGroup(
          color: const Color(0xFF9C27B0),
          label: 'DI DALAM KENDARAAN',
          items: [
            _ActionItem(number: 1, text: 'Menepi ke area aman, jauh dari jembatan dan flyover.'),
            _ActionItem(number: 2, text: 'Matikan mesin, tetap di dalam kendaraan hingga guncangan berhenti.'),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPascaBencana() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildImagePlaceholder('Foto evakuasi / posko (4:3 • ~400×300px)', const Color(0xFF4CAF50)),
        const SizedBox(height: 20),
        _buildGroup(
          color: const Color(0xFFF44336),
          label: 'SEGERA LAKUKAN',
          items: [
            _ActionItem(number: 1, text: 'Periksa kondisi diri dan orang di sekitar — berikan pertolongan pertama jika diperlukan.'),
            _ActionItem(number: 2, text: 'Waspadai gempa susulan, segera keluar dari bangunan yang rusak.'),
            _ActionItem(number: 3, text: 'Jika dekat pantai, segera menuju titik evakuasi tsunami.'),
          ],
        ),
        const SizedBox(height: 16),
        _buildGroup(
          color: const Color(0xFF4CAF50),
          label: 'LANGKAH SELANJUTNYA',
          items: [
            _ActionItem(number: 4, text: 'Periksa kerusakan bangunan sebelum masuk kembali.'),
            _ActionItem(number: 5, text: 'Hindari menggunakan api atau listrik sebelum dipastikan aman oleh petugas.'),
            _ActionItem(number: 6, text: 'Ikuti informasi resmi dari BMKG dan pemerintah daerah.'),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildImagePlaceholder(String label, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Image.network(
          'https://placehold.co/400x300/${color.toARGB32().toRadixString(16).substring(2)}/ffffff/png?text=${Uri.encodeComponent(label)}',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: const Color(0xFFF0F4F8),
            child: Center(
              child: Icon(Icons.broken_image_outlined, color: Colors.grey[400], size: 40),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroup({
    required Color color,
    required String label,
    required List<_ActionItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label kelompok
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final isLast = entry.key == items.length - 1;
              final item = entry.value;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${item.number}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.text,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF424242),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Divider(height: 1, indent: 54, color: Colors.grey[100]),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _ActionItem {
  final int number;
  final String text;
  const _ActionItem({required this.number, required this.text});
}
