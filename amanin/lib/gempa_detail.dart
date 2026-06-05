import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'utils/map_utils.dart';
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
  final DraggableScrollableController _sheetController = DraggableScrollableController();

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
      backgroundColor: const Color(0xFFF8FAFC), // White/Light background
      body: Stack(
        children: [
          // Background Map (Top Half)
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
          
          // Map Gradient Overlay (Fade to bottom)
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
                    const Color(0xFFF8FAFC).withOpacity(0.4),
                    const Color(0xFFF8FAFC).withOpacity(0.0),
                    const Color(0xFFF8FAFC).withOpacity(1.0),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Custom App Bar (Floating)
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: status.color.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: status.color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: status.color.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 1,
                            )
                          ]
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'UPDATE TERKINI',
                        style: GoogleFonts.poppins(
                          color: status.color,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
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
                          builder: (context) => FullscreenMapPage(gempa: gempa!),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          // Scrollable Content (Draggable Sheet Style)
          Positioned.fill(
            child: DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: 0.65,
              minChildSize: 0.65,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      )
                    ]
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Drag Handle
                            Center(
                              child: Container(
                                width: 40,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFCBD5E1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            
                            // Magnitude Hero
                            _buildMagnitudeSection(status, mag),
                            const SizedBox(height: 32),
                            
                            // Coordinates & Location
                            _buildLocationSection(),
                            const SizedBox(height: 24),
                            
                            // Metrics Grid
                            _buildMetricsGrid(),
                            const SizedBox(height: 24),
                            
                            // Impact & Safety
                            _buildImpactSection(status),
                            const SizedBox(height: 24),
                            _buildSafetySection(),
                          ],
                        ),
                      ),
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

  Widget _buildGlassButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.9)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            ),
            child: Icon(icon, color: const Color(0xFF1E293B), size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildMagnitudeSection(_MagnitudeStatus status, double? mag) {
    return _buildGlassCard(
      color: status.color.withOpacity(0.05),
      borderColor: status.color.withOpacity(0.2),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.monitor_heart_rounded, color: status.color, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'SKALA RICHTER',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    widget.gempa?.magnitude ?? '0.0',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF1E293B),
                      fontSize: 56,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      letterSpacing: -1.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'SR',
                    style: GoogleFonts.poppins(
                      color: status.color,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Icon(
            Icons.waves_rounded,
            color: status.color.withOpacity(0.2),
            size: 64,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    final wilayah = widget.gempa?.wilayah ?? 'Lokasi tidak diketahui';
    final isDarat = wilayah.toLowerCase().contains('darat');

    return _buildGlassCard(
      color: const Color(0xFFF0F9FF), // Soft Sky Blue
      borderColor: const Color(0xFFE0F2FE),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BCD4).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.location_on_rounded, color: Color(0xFF00BCD4), size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PUSAT GEMPA',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      wilayah,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF1E293B),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Color(0xFFF1F5F9), height: 1),
          ),
          Row(
            children: [
              Expanded(
                child: _buildCoordinateColumn('LINTANG', widget.gempa?.coordinates.split(',').first ?? '-', Icons.south_rounded),
              ),
              Container(width: 1, height: 40, color: const Color(0xFFF1F5F9)),
              Expanded(
                child: _buildCoordinateColumn('BUJUR', widget.gempa?.coordinates.split(',').last ?? '-', Icons.east_rounded),
              ),
              Container(width: 1, height: 40, color: const Color(0xFFF1F5F9)),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(isDarat ? Icons.landscape_rounded : Icons.water_rounded, size: 12, color: const Color(0xFF64748B)),
                        const SizedBox(width: 6),
                        Text(
                          'AREA',
                          style: GoogleFonts.poppins(color: const Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isDarat ? 'DARAT' : 'LAUT',
                      style: GoogleFonts.poppins(
                        color: isDarat ? const Color(0xFFF57C00) : const Color(0xFF0288D1),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoordinateColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 12, color: const Color(0xFF64748B)),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(color: const Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildGlassCard(
            color: const Color(0xFFF5F3FF), // Soft Purple
            borderColor: const Color(0xFFEDE9FE),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.access_time_rounded, color: const Color(0xFF673AB7), size: 24),
                const SizedBox(height: 16),
                Text(
                  'WAKTU',
                  style: GoogleFonts.poppins(color: const Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.gempa?.jam.split(' ').first ?? '00:00',
                  style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.gempa?.jam.split(' ').last ?? 'WIB',
                  style: GoogleFonts.poppins(color: const Color(0xFF673AB7), fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildGlassCard(
            color: const Color(0xFFECFEFF), // Soft Cyan
            borderColor: const Color(0xFFCFFAFE),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.straighten_rounded, color: const Color(0xFF00BCD4), size: 24),
                const SizedBox(height: 16),
                Text(
                  'KEDALAMAN',
                  style: GoogleFonts.poppins(color: const Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                const SizedBox(height: 4),
                Text(
                  (widget.gempa?.kedalaman ?? '0 km').split(' ').first,
                  style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Kilometer',
                  style: GoogleFonts.poppins(color: const Color(0xFF00BCD4), fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImpactSection(_MagnitudeStatus status) {
    return _buildGlassCard(
      color: const Color(0xFFEEF2FF), // Soft Indigo
      borderColor: const Color(0xFFE0E7FF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_rounded, color: Color(0xFF64748B), size: 20),
              const SizedBox(width: 12),
              Text(
                'ANALISIS DAMPAK',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF1E293B),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildImpactRow(
            icon: Icons.vibration_rounded,
            color: const Color(0xFF673AB7),
            title: 'INTENSITAS GETARAN',
            desc: 'Dirasakan di wilayah pusat gempa',
          ),
          const SizedBox(height: 16),
          _buildImpactRow(
            icon: Icons.waves_rounded,
            color: const Color(0xFF00BCD4),
            title: 'POTENSI TSUNAMI',
            desc: 'Tidak berpotensi tsunami',
            badge: 'AMAN',
            badgeColor: const Color(0xFF00BCD4),
          ),
          const SizedBox(height: 16),
          _buildImpactRow(
            icon: Icons.home_work_rounded,
            color: status.color,
            title: 'RISIKO KERUSAKAN',
            desc: _getMagnitudeWarning(double.tryParse(widget.gempa?.magnitude ?? '0')),
            badge: status.label,
            badgeColor: status.color,
          ),
        ],
      ),
    );
  }

  Widget _buildImpactRow({required IconData icon, required Color color, required String title, required String desc, String? badge, Color? badgeColor}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(color: const Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        if (badge != null && badgeColor != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: badgeColor.withOpacity(0.3)),
            ),
            child: Text(
              badge,
              style: GoogleFonts.poppins(color: badgeColor, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ),
      ],
    );
  }

  Widget _buildSafetySection() {
    return _buildGlassCard(
      color: const Color(0xFFFEF2F2), // Light red
      borderColor: const Color(0xFFFEE2E2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.security_rounded, color: Color(0xFFF44336), size: 20),
              const SizedBox(width: 12),
              Text(
                'PANDUAN KESELAMATAN',
                style: GoogleFonts.poppins(
                  color: const Color(0xFFF44336),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSafetyRow('Hindari bangunan yang retak atau rusak akibat gempa.'),
          _buildSafetyRow('Waspada terhadap potensi gempa susulan yang mungkin terjadi.'),
          _buildSafetyRow('Pastikan jalur evakuasi di sekitar Anda aman dan terbuka.'),
          _buildSafetyRow('Pantau selalu informasi resmi dari kanal BMKG.'),
        ],
      ),
    );
  }

  Widget _buildSafetyRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(Icons.circle, color: Color(0xFFF44336), size: 6),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(color: const Color(0xFF334155), fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child, EdgeInsetsGeometry? padding, Color? color, Color? borderColor}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: borderColor ?? const Color(0xFFF1F5F9),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ]
      ),
      child: child,
    );
  }

  _MagnitudeStatus _getMagnitudeStatus(double? mag) {
    if (mag == null) return _MagnitudeStatus('MOHON TUNGGU', Colors.grey, Icons.help_outline);
    if (mag < 4.0) {
      return _MagnitudeStatus('GEMPA RINGAN', const Color(0xFF00BCD4), Icons.sentiment_satisfied_rounded); // Cyan
    } else if (mag < 6.0) {
      return _MagnitudeStatus('GEMPA SEDANG', const Color(0xFFFF9800), Icons.warning_amber_rounded); // Orange
    } else {
      return _MagnitudeStatus('GEMPA KUAT', const Color(0xFFF44336), Icons.warning_rounded); // Red
    }
  }

  String _getMagnitudeWarning(double? mag) {
    if (mag == null) return 'Data sedang diproses...';
    if (mag < 4.0) return 'Dirasakan oleh beberapa orang';
    if (mag < 6.0) return 'Dapat menyebabkan kerusakan ringan';
    return 'Berpotensi bahaya dan kerusakan luas';
  }
}

class _MagnitudeStatus {
  final String label;
  final Color color;
  final IconData icon;

  _MagnitudeStatus(this.label, this.color, this.icon);
}
