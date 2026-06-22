import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'utils/earthquake_map.dart';
import 'fullscreen_map.dart';
import 'services/bmkg_service.dart';

class GempaDetailPage extends StatefulWidget {
  final GempaModel? gempa;

  const GempaDetailPage({super.key, this.gempa});

  @override
  State<GempaDetailPage> createState() => _GempaDetailPageState();
}

class _GempaDetailPageState extends State<GempaDetailPage> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gempa = widget.gempa;
    final mag = double.tryParse(gempa?.magnitude ?? '0');
    final status = _getMagnitudeStatus(mag);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Background Map
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: gempa?.coordinates.isNotEmpty == true
                ? EarthquakeMap(
                    coordinates: gempa!.coordinates,
                    initialZoom: 7.0,
                    interactive: false,
                  )
                : Container(color: const Color(0xFFE2E8F0)),
          ),

          // Gradient Overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFF8FAFC).withValues(alpha: 0.3),
                    const Color(0xFFF8FAFC).withValues(alpha: 0.0),
                    const Color(0xFFF8FAFC).withValues(alpha: 1.0),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // AppBar
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildGlassButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: status.color.withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: status.color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: status.color.withValues(alpha: 0.5),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        status.label,
                        style: GoogleFonts.poppins(
                          color: status.color,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildGlassButton(
                  icon: Icons.fullscreen_rounded,
                  onTap: () {
                    if (gempa != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullscreenMapPage(gempa: gempa),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          // Draggable Sheet
          Positioned.fill(
            child: DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: 0.63,
              minChildSize: 0.63,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(36),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Drag Handle
                        Center(
                          child: Container(
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFFDDE3EC),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Magnitude Header
                        _buildMagnitudeHeader(status, mag),
                        const SizedBox(height: 20),

                        // Info Grid: Waktu & Kedalaman
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoTile(
                                icon: Icons.access_time_rounded,
                                iconColor: const Color(0xFF7C3AED),
                                label: 'Waktu',
                                value: gempa?.jam.split(' ').first ?? '--:--',
                                unit: gempa?.jam.split(' ').last ?? 'WIB',
                                bgColor: const Color(0xFFF5F3FF),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInfoTile(
                                icon: Icons.straighten_rounded,
                                iconColor: const Color(0xFF00ACC1),
                                label: 'Kedalaman',
                                value: (gempa?.kedalaman ?? '0 km')
                                    .split(' ')
                                    .first,
                                unit: 'km',
                                bgColor: const Color(0xFFE0F7FA),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Tanggal
                        _buildDetailCard(
                          icon: Icons.calendar_today_rounded,
                          iconColor: const Color(0xFFFF9800),
                          title: 'Tanggal',
                          content: gempa?.tanggal ?? '-',
                        ),
                        const SizedBox(height: 12),

                        // Pusat Gempa
                        _buildDetailCard(
                          icon: Icons.location_on_rounded,
                          iconColor: const Color(0xFF00BCD4),
                          title: 'Pusat Gempa',
                          content: gempa?.wilayah ?? 'Lokasi tidak diketahui',
                        ),
                        const SizedBox(height: 12),

                        // Koordinat
                        _buildCoordinatesCard(gempa),
                        const SizedBox(height: 12),

                        // Dampak Guncangan (jika ada)
                        if (gempa?.dirasakan.isNotEmpty == true &&
                            gempa!.dirasakan != '-') ...[
                          _buildDetailCard(
                            icon: Icons.track_changes_rounded,
                            iconColor: const Color(0xFFFF5722),
                            title: 'Dampak Guncangan',
                            content: gempa.dirasakan,
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Analisis Risiko
                        _buildRiskCard(status, mag),
                        const SizedBox(height: 12),

                        // Panduan Keselamatan
                        _buildSafetyCard(mag),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: const Color(0xFF1E293B), size: 18),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMagnitudeHeader(_MagnitudeStatus status, double? mag) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: status.color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Magnitudo',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    widget.gempa?.magnitude ?? '0.0',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF1E293B),
                      fontSize: 54,
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                      letterSpacing: -2,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Mw',
                    style: GoogleFonts.poppins(
                      color: status.color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: status.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status.label,
                  style: GoogleFonts.poppins(
                    color: status.color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Icon(
            status.icon,
            color: status.color.withValues(alpha: 0.25),
            size: 80,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String unit,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: const Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: const Color(0xFF1E293B),
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
          Text(
            unit,
            style: GoogleFonts.poppins(
              color: iconColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9EEF4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF94A3B8),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  content,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF1E293B),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoordinatesCard(GempaModel? gempa) {
    final coords = gempa?.coordinates.split(',') ?? ['-', '-'];
    final lat = coords.isNotEmpty ? coords[0].trim() : '-';
    final lon = coords.length > 1 ? coords[1].trim() : '-';
    final wilayah = gempa?.wilayah ?? '';
    final isDarat = wilayah.toLowerCase().contains('darat');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9EEF4)),
      ),
      child: Row(
        children: [
          Expanded(child: _buildCoordItem('Lintang', lat, Icons.south_rounded)),
          Container(width: 1, height: 36, color: const Color(0xFFE2E8F0)),
          Expanded(child: _buildCoordItem('Bujur', lon, Icons.east_rounded)),
          Container(width: 1, height: 36, color: const Color(0xFFE2E8F0)),
          Expanded(
            child: Column(
              children: [
                Icon(
                  isDarat ? Icons.landscape_rounded : Icons.water_rounded,
                  size: 14,
                  color: isDarat
                      ? const Color(0xFFF57C00)
                      : const Color(0xFF0288D1),
                ),
                const SizedBox(height: 4),
                Text(
                  'Area',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF94A3B8),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isDarat ? 'Darat' : 'Laut',
                  style: GoogleFonts.poppins(
                    color: isDarat
                        ? const Color(0xFFF57C00)
                        : const Color(0xFF0288D1),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoordItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF94A3B8)),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: const Color(0xFF94A3B8),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: const Color(0xFF1E293B),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRiskCard(_MagnitudeStatus status, double? mag) {
    final items = [
      _RiskItem(
        icon: Icons.vibration_rounded,
        color: const Color(0xFF7C3AED),
        label: 'Intensitas getaran',
        value: _getIntensityDesc(mag),
      ),
      _RiskItem(
        icon: Icons.home_work_rounded,
        color: status.color,
        label: 'Risiko kerusakan',
        value: _getMagnitudeWarning(mag),
        badge: status.label,
        badgeColor: status.color,
      ),
      _RiskItem(
        icon: Icons.waves_rounded,
        color: const Color(0xFF0288D1),
        label: 'Potensi tsunami',
        value: _getTsunamiRisk(mag, widget.gempa?.wilayah ?? ''),
        badge: _getTsunamiBadge(mag, widget.gempa?.wilayah ?? ''),
        badgeColor: _getTsunamiColor(mag, widget.gempa?.wilayah ?? ''),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9EEF4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.analytics_rounded,
                color: Color(0xFF64748B),
                size: 17,
              ),
              const SizedBox(width: 8),
              Text(
                'Analisis Dampak',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF1E293B),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) => _buildRiskRow(item)),
        ],
      ),
    );
  }

  Widget _buildRiskRow(_RiskItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: item.color, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF94A3B8),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  item.value,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF1E293B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (item.badge != null && item.badgeColor != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: item.badgeColor!.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: item.badgeColor!.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                item.badge!,
                style: GoogleFonts.poppins(
                  color: item.badgeColor,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.4,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSafetyCard(double? mag) {
    final tips = _getSafetyTips(mag);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F0),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFE0B2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.shield_rounded,
                color: Color(0xFFF57C00),
                size: 17,
              ),
              const SizedBox(width: 8),
              Text(
                'Panduan Keselamatan',
                style: GoogleFonts.poppins(
                  color: const Color(0xFFF57C00),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Icon(
                      Icons.circle,
                      color: Color(0xFFF57C00),
                      size: 5,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tip,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF4A3800),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────
  _MagnitudeStatus _getMagnitudeStatus(double? mag) {
    if (mag == null) {
      return _MagnitudeStatus('Memuat...', Colors.grey, Icons.help_outline);
    }
    if (mag < 4.0) {
      return _MagnitudeStatus(
        'Gempa Ringan',
        const Color(0xFF00ACC1),
        Icons.sentiment_satisfied_rounded,
      );
    }
    if (mag < 6.0) {
      return _MagnitudeStatus(
        'Gempa Sedang',
        const Color(0xFFFF9800),
        Icons.warning_amber_rounded,
      );
    }
    return _MagnitudeStatus(
      'Gempa Kuat',
      const Color(0xFFF44336),
      Icons.warning_rounded,
    );
  }

  String _getMagnitudeWarning(double? mag) {
    if (mag == null) return 'Data sedang diproses';
    if (mag < 3.0) return 'Hampir tidak dirasakan';
    if (mag < 4.0) return 'Dirasakan oleh sebagian orang';
    if (mag < 5.0) return 'Terasa cukup kuat, kerusakan ringan mungkin terjadi';
    if (mag < 6.0) return 'Dapat menyebabkan kerusakan pada bangunan lemah';
    if (mag < 7.0) return 'Berpotensi bahaya, kerusakan cukup luas';
    return 'Sangat berbahaya, kerusakan luas dan masif';
  }

  String _getIntensityDesc(double? mag) {
    if (mag == null) return '-';
    if (mag < 3.0) return 'Mikro — tidak terasa oleh manusia';
    if (mag < 4.0) return 'Lemah — dirasakan beberapa orang';
    if (mag < 5.0) return 'Sedang — benda berguncang, dirasakan banyak orang';
    if (mag < 6.0) return 'Kuat — getaran terasa di area luas';
    return 'Sangat kuat — getaran besar dan luas';
  }

  String _getTsunamiRisk(double? mag, String wilayah) {
    final isSea = !wilayah.toLowerCase().contains('darat');
    if (mag == null) return 'Data tidak tersedia';
    if (mag >= 7.0 && isSea) return 'Perhatikan peringatan tsunami';
    if (mag >= 6.0 && isSea) return 'Pantau informasi BMKG secara berkala';
    return 'Tidak berpotensi tsunami';
  }

  String _getTsunamiBadge(double? mag, String wilayah) {
    final isSea = !wilayah.toLowerCase().contains('darat');
    if (mag == null) return 'N/A';
    if (mag >= 7.0 && isSea) return 'WASPADA';
    if (mag >= 6.0 && isSea) return 'PANTAU';
    return 'AMAN';
  }

  Color _getTsunamiColor(double? mag, String wilayah) {
    final isSea = !wilayah.toLowerCase().contains('darat');
    if (mag == null) return Colors.grey;
    if (mag >= 7.0 && isSea) return const Color(0xFFF44336);
    if (mag >= 6.0 && isSea) return const Color(0xFFFF9800);
    return const Color(0xFF00ACC1);
  }

  List<String> _getSafetyTips(double? mag) {
    if (mag == null || mag < 4.0) {
      return [
        'Tetap tenang, gempa kecil ini tidak berbahaya.',
        'Pantau informasi BMKG untuk memastikan tidak ada gempa susulan.',
        'Periksa sekitar Anda untuk memastikan tidak ada kerusakan.',
      ];
    } else if (mag < 6.0) {
      return [
        'Berlindung di bawah meja atau benda kokoh jika masih dalam guncangan.',
        'Jauhi kaca, lemari, dan benda yang bisa jatuh.',
        'Setelah guncangan berhenti, keluar dengan tertib melalui tangga.',
        'Waspada terhadap kemungkinan gempa susulan.',
        'Pantau saluran resmi BMKG untuk informasi terkini.',
      ];
    } else {
      return [
        'Segera evakuasi ke tempat terbuka yang aman.',
        'Hindari bangunan yang berpotensi runtuh atau retak parah.',
        'Jika berada di pantai, segera menjauh ke dataran tinggi.',
        'Gunakan tangga darurat, jangan gunakan lift.',
        'Ikuti arahan petugas dan tim SAR setempat.',
        'Pantau informasi resmi dari BMKG dan BNPB.',
      ];
    }
  }
}

class _MagnitudeStatus {
  final String label;
  final Color color;
  final IconData icon;

  _MagnitudeStatus(this.label, this.color, this.icon);
}

class _RiskItem {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String? badge;
  final Color? badgeColor;

  _RiskItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.badge,
    this.badgeColor,
  });
}
