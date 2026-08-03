import 'package:flutter/material.dart';
import 'services/anomali_service.dart';

class PanduanAnomaliPage extends StatefulWidget {
  const PanduanAnomaliPage({super.key});

  @override
  State<PanduanAnomaliPage> createState() => _PanduanAnomaliPageState();
}

class _PanduanAnomaliPageState extends State<PanduanAnomaliPage> {
  @override
  void initState() {
    super.initState();
    DemoState.selectedDemoGempa.addListener(_onDemoStateChanged);
  }

  @override
  void dispose() {
    DemoState.selectedDemoGempa.removeListener(_onDemoStateChanged);
    super.dispose();
  }

  void _onDemoStateChanged() {
    if (!mounted) return;
    setState(() {});
  }

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
            // ================= STUDI KASUS / SHAP (fokus utama) =================
            _buildSectionLabel(
              icon: Icons.insights,
              iconColor: const Color(0xFF1565C0),
              text: 'HASIL DETEKSI GEMPA',
              textColor: const Color(0xFF1565C0),
            ),
            const SizedBox(height: 4),
            Text(
              DemoState.selectedDemoGempa.value != null
                  ? 'Gempa demonstrasi yang kamu pilih:'
                  : 'Gempa terbaru yang sudah diproses oleh model:',
              style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 10),
            _buildStudiKasus(),

            const SizedBox(height: 20),

            // ================= PENJELASAN KONSEP (selalu terbuka) =================
            _buildPenjelasanKonsep(),
          ],
        ),
      ),
    );
  }

  Widget _buildPenjelasanKonsep() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EAED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- Judul section ----------
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(Icons.help_outline,
                      size: 16, color: Color(0xFF1565C0)),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: Text(
                      'Apa itu anomali & bagaimana cara kerjanya?',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                        height: 1.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ---------- Perbandingan Normal vs Anomali ----------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              children: [
                _buildKondisiTile(
                  icon: Icons.check_circle,
                  iconColor: const Color(0xFF2E7D32),
                  bgColor: const Color(0xFFF1F8F2),
                  borderColor: const Color(0xFFC8E6C9),
                  title: 'Data Normal',
                  titleColor: const Color(0xFF2E7D32),
                  description:
                      'Kekuatan dan kedalaman gempa masih sesuai kebiasaan wilayah tersebut.',
                  descColor: const Color(0xFF41603F),
                ),
                const SizedBox(height: 10),
                _buildKondisiTile(
                  icon: Icons.warning_rounded,
                  iconColor: const Color(0xFFE65100),
                  bgColor: const Color(0xFFFFF8F0),
                  borderColor: const Color(0xFFFFD9B0),
                  title: 'Data Anomali',
                  titleColor: const Color(0xFFE65100),
                  description:
                      'Kombinasi kekuatan (magnitudo) dan kedalaman gempa menyimpang jauh dari kebiasaan wilayah — perlu kewaspadaan ekstra.',
                  descColor: const Color(0xFF8A5023),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F1F3)),
          const SizedBox(height: 18),

          // ---------- Cara kerja model ----------
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cara Kerja Model',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Model Isolation Forest membandingkan tiap gempa baru dengan data historis se-Indonesia. Semakin tidak biasa kombinasi datanya, semakin tinggi skor anomalinya.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF5F6368),
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F1F3)),
          const SizedBox(height: 18),

          // ---------- Arti persentase pada hasil deteksi ----------
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Arti Angka Persentase',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Persentase pada hasil deteksi di atas menunjukkan seberapa besar andil tiap faktor dalam menentukan hasil gempa tersebut — bukan tingkat bahayanya. Totalnya selalu 100% dari keempat faktor.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF5F6368),
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              children: [
                _buildPersentaseTile(
                  badge: 'Tinggi',
                  badgeBg: const Color(0xFFE8F0FE),
                  badgeColor: const Color(0xFF1565C0),
                  description:
                      'Faktor tersebut paling menentukan hasil deteksi gempa ini.',
                ),
                const SizedBox(height: 8),
                _buildPersentaseTile(
                  badge: 'Rendah',
                  badgeBg: const Color(0xFFF1F3F4),
                  badgeColor: const Color(0xFF5F6368),
                  description:
                      'Faktor tersebut hanya sedikit memengaruhi hasil deteksi gempa ini.',
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F1F3)),
          const SizedBox(height: 18),

          // ---------- 4 faktor yang diperiksa ----------
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              '4 Faktor yang Diperiksa',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              children: [
                _buildFactorItem(
                  icon: Icons.speed,
                  label: 'Magnitudo',
                  description: 'Kekuatan gempa dibanding kebiasaan wilayah.',
                ),
                _buildFactorItem(
                  icon: Icons.vertical_align_bottom,
                  label: 'Kedalaman',
                  description:
                      'Seberapa dangkal/dalam dibanding kebiasaan wilayah.',
                ),
                _buildFactorItem(
                  icon: Icons.explore_outlined,
                  label: 'Lintang & Bujur',
                  description: 'Seberapa jarang lokasi tersebut mengalami gempa.',
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  /// Tile perbandingan kondisi (Normal / Anomali) di dalam kartu penjelasan.
  Widget _buildKondisiTile({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required Color borderColor,
    required String title,
    required Color titleColor,
    required String description,
    required Color descColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: descColor,
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

  /// Baris keterangan arti persentase besar/kecil pada hasil deteksi.
  Widget _buildPersentaseTile({
    required String badge,
    required Color badgeBg,
    required Color badgeColor,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 62,
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            badge,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF5F6368),
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStudiKasus() {
    final demoGempa = DemoState.selectedDemoGempa.value;

    if (demoGempa != null) {
      final title = 'M ${demoGempa.magnitude} - ${demoGempa.wilayah}';
      return AnomaliOutputCard(
        title: title,
        isAnomaly: demoGempa.isAnomali,
        score: demoGempa.anomalyScore,
        time: '${demoGempa.tanggal} ${demoGempa.jam}',
        shapExplanation: demoGempa.shapExplanation,
        initiallyExpanded: true,
      );
    }

    return FutureBuilder<List<AnomaliGempaModel>>(
      future: AnomaliService.fetchAnomaliTerkini(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Text(
              'Gagal memuat data: ${snapshot.error}',
              style: TextStyle(color: Colors.red.shade700),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('Tidak ada data gempa saat ini.'),
          );
        }

        final gempa = snapshot.data!.first;
        final title = 'M ${gempa.magnitude} - ${gempa.wilayah}';
        return AnomaliOutputCard(
          title: title,
          isAnomaly: gempa.isAnomali,
          score: gempa.anomalyScore,
          time: '${gempa.tanggal} ${gempa.jam}',
          shapExplanation: gempa.shapExplanation,
          initiallyExpanded: true,
        );
      },
    );
  }

  Widget _buildSectionLabel({
    required IconData icon,
    required Color iconColor,
    required String text,
    required Color textColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: textColor,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFactorItem({
    required IconData icon,
    required String label,
    required String description,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5FB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: const Color(0xFF1565C0)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF5F6368),
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

/// Kartu hasil deteksi anomali satu gempa, lengkap dengan ringkasan naratif
/// dan breakdown SHAP per fitur (dari IF_SHAP_explainer.pkl), untuk ditampilkan
/// sebagai contoh nyata di halaman Panduan Anomali Seismisitas.
class AnomaliOutputCard extends StatefulWidget {
  final String title;
  final bool isAnomaly;
  final double score;
  final String time;
  final ShapExplanation? shapExplanation;
  final bool initiallyExpanded;

  const AnomaliOutputCard({
    super.key,
    required this.title,
    required this.isAnomaly,
    required this.score,
    required this.time,
    this.shapExplanation,
    this.initiallyExpanded = false,
  });

  @override
  State<AnomaliOutputCard> createState() => _AnomaliOutputCardState();
}

class _AnomaliOutputCardState extends State<AnomaliOutputCard> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final hasPenjelasan = widget.shapExplanation != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isAnomaly ? Colors.red.shade300 : Colors.green.shade300,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: widget.isAnomaly
                      ? Colors.red.withValues(alpha: 0.1)
                      : Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.isAnomaly
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle_outline,
                  color: widget.isAnomaly ? Colors.red : Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.time,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          widget.isAnomaly
                              ? 'Status: Anomali Terdeteksi'
                              : 'Status: Normal',
                          style: TextStyle(
                            color: widget.isAnomaly ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Penjelasan awam (ringkasan bahasa manusia dari SHAP)
          if (hasPenjelasan) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _expanded ? 'Sembunyikan detail' : 'Lihat detail penjelasan',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2196F3),
                      ),
                    ),
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      size: 18,
                      color: const Color(0xFF2196F3),
                    ),
                  ],
                ),
              ),
            ),
            if (_expanded) ...[
              const SizedBox(height: 4),
              ...widget.shapExplanation!.contributions.map(
                (c) => _buildFeatureBar(c),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureBar(ShapContribution c) {
    final isAnomaliArah = c.arah == 'anomali';
    final barColor = isAnomaliArah ? Colors.red.shade400 : Colors.green.shade400;
    final nilaiTeks = c.nilaiAktual != null
        ? '${c.nilaiAktual} ${c.unit}'
        : '-';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${c.label}: $nilaiTeks',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
              Text(
                '${c.kontribusiPersen.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: barColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (c.kontribusiPersen / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: const Color(0xFFF0F0F0),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
  }
}
