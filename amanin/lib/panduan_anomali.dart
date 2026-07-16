import 'package:flutter/material.dart';
import 'services/anomali_service.dart';

class PanduanAnomaliPage extends StatefulWidget {
  const PanduanAnomaliPage({super.key});

  @override
  State<PanduanAnomaliPage> createState() => _PanduanAnomaliPageState();
}

class _PanduanAnomaliPageState extends State<PanduanAnomaliPage> {
  bool _showPenjelasan = false;

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

            // ================= PENJELASAN KONSEP (ringkas, expandable) =================
            _buildPenjelasanToggle(),
            if (_showPenjelasan) ...[
              const SizedBox(height: 16),
              _buildPenjelasanKonsep(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPenjelasanToggle() {
    return InkWell(
      onTap: () => setState(() => _showPenjelasan = !_showPenjelasan),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.help_outline, size: 18, color: Color(0xFF1565C0)),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Apa itu anomali & bagaimana cara kerjanya?',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
              ),
            ),
            Icon(
              _showPenjelasan ? Icons.expand_less : Icons.expand_more,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPenjelasanKonsep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Data Normal (ringkas)
        _buildSectionLabel(
          icon: Icons.check_circle_outline,
          iconColor: const Color(0xFF2E7D32),
          text: 'DATA NORMAL',
          textColor: const Color(0xFF2E7D32),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFA5D6A7)),
          ),
          child: const Text(
            'Kekuatan dan kedalaman gempa masih sesuai kebiasaan wilayah tersebut.',
            style: TextStyle(fontSize: 13, color: Color(0xFF33691E), height: 1.5),
          ),
        ),

        const SizedBox(height: 20),

        // Data Anomali (ringkas)
        _buildSectionLabel(
          icon: Icons.warning_amber_rounded,
          iconColor: const Color(0xFFE65100),
          text: 'DATA ANOMALI',
          textColor: const Color(0xFFE65100),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFFCC80)),
          ),
          child: const Text(
            'Kombinasi kekuatan (magnitudo) dan kedalaman gempa menyimpang jauh dari kebiasaan wilayah tersebut — perlu kewaspadaan ekstra.',
            style: TextStyle(fontSize: 13, color: Color(0xFFE65100), height: 1.5),
          ),
        ),

        const SizedBox(height: 20),

        // Cara kerja (ringkas)
        const Text(
          'Cara Kerja Model',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
        ),
        const SizedBox(height: 8),
        const Text(
          'Model Isolation Forest membandingkan tiap gempa baru dengan data historis se-Indonesia. Semakin tidak biasa kombinasi datanya, semakin tinggi skor anomalinya.',
          style: TextStyle(fontSize: 13, color: Color(0xFF424242), height: 1.5),
        ),

        const SizedBox(height: 20),

        // 4 Faktor (ringkas)
        const Text(
          '4 Faktor yang Diperiksa',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
        ),
        const SizedBox(height: 12),
        _buildFactorItem(
          icon: Icons.speed,
          label: 'Magnitudo',
          description: 'Kekuatan gempa dibanding kebiasaan wilayah.',
        ),
        _buildFactorItem(
          icon: Icons.vertical_align_bottom,
          label: 'Kedalaman',
          description: 'Seberapa dangkal/dalam dibanding kebiasaan wilayah.',
        ),
        _buildFactorItem(
          icon: Icons.explore_outlined,
          label: 'Lintang & Bujur',
          description: 'Seberapa jarang lokasi tersebut mengalami gempa.',
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF1565C0)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
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
                        const Spacer(),
                        Text(
                          'Skor: ${widget.score.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.isAnomaly ? const Color(0xFFFFF8E1) : const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: widget.isAnomaly ? const Color(0xFFFFE0B2) : const Color(0xFFBBDEFB),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 18,
                    color: widget.isAnomaly ? const Color(0xFFF57C00) : const Color(0xFF1565C0),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.shapExplanation!.summary,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: widget.isAnomaly ? const Color(0xFF5D4037) : const Color(0xFF0D47A1),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
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
              const SizedBox(height: 4),
              Text(
                widget.isAnomaly
                    ? 'Semakin panjang bar merah, semakin besar pengaruh faktor tersebut dalam menandai gempa ini sebagai anomali.'
                    : 'Semakin panjang bar hijau, semakin besar pengaruh faktor tersebut dalam menandai gempa ini sebagai normal. Bar merah (jika ada) berarti faktor itu justru sedikit tidak biasa, tapi belum cukup kuat untuk membuat keseluruhan gempa ditandai anomali.',
                style: TextStyle(
                  fontSize: 10.5,
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
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
    final rataRataTeks = c.rataRataHistoris != null
        ? 'rata-rata historis: ${c.rataRataHistoris} ${c.unit}'
        : null;

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
          if (c.keterangan != null) ...[
            const SizedBox(height: 4),
            Text(
              rataRataTeks != null
                  ? '${c.keterangan} ($rataRataTeks)'
                  : c.keterangan!,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }
}
