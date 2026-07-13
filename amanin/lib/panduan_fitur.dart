import 'package:flutter/material.dart';
import 'dart:ui';

class LocationWaveWidget extends StatelessWidget {
  final bool isLeft;
  const LocationWaveWidget({required this.isLeft, super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(12, 40),
      painter: LocationWavePainter(isLeft: isLeft),
    );
  }
}

class LocationWavePainter extends CustomPainter {
  final bool isLeft;
  LocationWavePainter({required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00BCD4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    if (isLeft) {
      // Small arc: center at x = size.width + 8
      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(size.width + 8, size.height / 2),
          radius: 16,
        ),
        2.3, // start angle
        1.68, // sweep angle
        false,
        paint,
      );
      // Large arc
      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(size.width + 8, size.height / 2),
          radius: 24,
        ),
        2.3,
        1.68,
        false,
        paint,
      );
    } else {
      // Small arc: center at x = -8
      canvas.drawArc(
        Rect.fromCircle(center: Offset(-8, size.height / 2), radius: 16),
        -0.84,
        1.68,
        false,
        paint,
      );
      // Large arc
      canvas.drawArc(
        Rect.fromCircle(center: Offset(-8, size.height / 2), radius: 24),
        -0.84,
        1.68,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HelpTourOverlay extends StatelessWidget {
  final int step;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;
  final Rect? chipsRect;
  final Rect? mapCardRect;
  final Rect? survivalKitRect;
  final Rect? weatherRect;
  final Rect? earlyWarningRect;
  final Rect? newsRect;
  final Rect? insuranceRect;
  final Rect? bottomNavRect;

  const HelpTourOverlay({
    required this.step,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
    this.chipsRect,
    this.mapCardRect,
    this.survivalKitRect,
    this.weatherRect,
    this.earlyWarningRect,
    this.newsRect,
    this.insuranceRect,
    this.bottomNavRect,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Semi-transparent background
        IgnorePointer(
          ignoring: true,
          child: Container(
            color: Colors.black.withOpacity(0.65),
            width: double.infinity,
            height: double.infinity,
          ),
        ),

        // Help content depending on step
        if (step == 1) ...[
          // Highlight target: Indoor/Outdoor & Location Chips
          Positioned(
            top: (chipsRect?.top ?? 105) - 4,
            left: (chipsRect?.left ?? 16) - 8,
            width: (chipsRect?.width ?? (size.width - 32)) + 16,
            height: (chipsRect?.height ?? 48) + 8,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF00BCD4), width: 3),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
          // Arrow pointing up
          Positioned(
            top: ((chipsRect?.bottom ?? 153) + 4),
            left: (chipsRect?.left ?? 16) + 44,
            child: IgnorePointer(
              child: const Icon(
                Icons.arrow_upward_rounded,
                color: Colors.white,
                size: 36,
                shadows: [Shadow(color: Color(0xFF00BCD4), blurRadius: 12)],
              ),
            ),
          ),
          // Tooltip container
          Positioned(
            top: 200,
            left: 20,
            right: 20,
            child: _buildTooltipBox(
              context,
              number: "1",
              title: "Deteksi Posisi & Wilayah",
              description:
                  "Fitur ini mendeteksi posisi Anda. Anda bisa mengetuk 'Posisi Anda' untuk mengubah status (Dalam/Luar Ruangan) secara manual, atau membiarkan GPS mendeteksi jenis wilayah secara otomatis.",
            ),
          ),
        ],

        if (step == 2) ...[
          // Highlight target: Gempabumi Terkini Map & Card
          Positioned(
            top: (mapCardRect?.top ?? 240) - 4,
            left: (mapCardRect?.left ?? 16) - 4,
            width: (mapCardRect?.width ?? (size.width - 32)) + 8,
            height: (mapCardRect?.height ?? 220) + 8,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF00BCD4), width: 3),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          // Arrow pointing down
          Positioned(
            top: (mapCardRect?.top ?? 240) - 45,
            left: (mapCardRect?.left ?? 16) + 84,
            child: IgnorePointer(
              child: const Icon(
                Icons.arrow_downward_rounded,
                color: Colors.white,
                size: 36,
                shadows: [Shadow(color: Color(0xFF00BCD4), blurRadius: 12)],
              ),
            ),
          ),
          // Tooltip container
          Positioned(
            bottom: 125,
            left: 20,
            right: 20,
            child: _buildTooltipBox(
              context,
              number: "2",
              title: "Info Gempa Terkini",
              description:
                  "Menampilkan peta pusat gempa terbaru secara real-time, lengkap dengan magnitudo, kedalaman, lokasi, jarak dari Anda, dan tingkat getaran yang dirasakan.",
            ),
          ),
        ],

        if (step == 3) ...[
          // Highlight target: Perlengkapan Siaga (Prudential Partner)
          Positioned(
            top: (survivalKitRect?.top ?? 480) - 4,
            left: (survivalKitRect?.left ?? 16) - 4,
            width: (survivalKitRect?.width ?? (size.width - 32)) + 8,
            height: (survivalKitRect?.height ?? 160) + 8,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF00BCD4), width: 3),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          // Arrow pointing down
          Positioned(
            top: (survivalKitRect?.top ?? 480) - 45,
            left: (survivalKitRect?.left ?? 16) + 84,
            child: IgnorePointer(
              child: const Icon(
                Icons.arrow_downward_rounded,
                color: Colors.white,
                size: 36,
                shadows: [Shadow(color: Color(0xFF00BCD4), blurRadius: 12)],
              ),
            ),
          ),
          // Tooltip container
          Positioned(
            bottom: 125,
            left: 20,
            right: 20,
            child: _buildTooltipBox(
              context,
              number: "3",
              title: "Proteksi Bencana Prudential",
              description:
                  "Menyediakan pilihan perlindungan dari Prudential pasca-bencana, mulai dari bantuan kecelakaan, jaminan kesehatan keluarga, hingga perlindungan aset rumah Anda.",
            ),
          ),
        ],

        if (step == 4) ...[
          // Highlight target: Cuaca Lokal (Weather Card)
          Positioned(
            top: (weatherRect?.top ?? 660) - 4,
            left: (weatherRect?.left ?? 16) - 4,
            width: (weatherRect?.width ?? (size.width - 32)) + 8,
            height: (weatherRect?.height ?? 180) + 8,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF00BCD4), width: 3),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          // Arrow pointing down
          Positioned(
            top: (weatherRect?.top ?? 660) - 45,
            left: (weatherRect?.left ?? 16) + 84,
            child: IgnorePointer(
              child: const Icon(
                Icons.arrow_downward_rounded,
                color: Colors.white,
                size: 36,
                shadows: [Shadow(color: Color(0xFF00BCD4), blurRadius: 12)],
              ),
            ),
          ),
          // Tooltip container
          Positioned(
            bottom: 125,
            left: 20,
            right: 20,
            child: _buildTooltipBox(
              context,
              number: "4",
              title: "Prakiraan Cuaca Lokal",
              description:
                  "Menampilkan kondisi cuaca, suhu, kelembaban, kecepatan angin, serta indeks sinar UV berdasarkan lokasi GPS HP Anda.",
            ),
          ),
        ],

        if (step == 5) ...[
          // Highlight target: Peringatan Dini (Early Warning Card)
          Positioned(
            top: (earlyWarningRect?.top ?? 860) - 4,
            left: (earlyWarningRect?.left ?? 16) - 4,
            width: (earlyWarningRect?.width ?? (size.width - 32)) + 8,
            height: (earlyWarningRect?.height ?? 80) + 8,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF00BCD4), width: 3),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          // Arrow pointing down
          Positioned(
            top: (earlyWarningRect?.top ?? 860) - 45,
            left: (earlyWarningRect?.left ?? 16) + 84,
            child: IgnorePointer(
              child: const Icon(
                Icons.arrow_downward_rounded,
                color: Colors.white,
                size: 36,
                shadows: [Shadow(color: Color(0xFF00BCD4), blurRadius: 12)],
              ),
            ),
          ),
          // Tooltip container
          Positioned(
            bottom: 125,
            left: 20,
            right: 20,
            child: _buildTooltipBox(
              context,
              number: "5",
              title: "Peringatan Dini Cuaca",
              description:
                  "Kotak informasi siaga yang otomatis berubah warna menjadi jingga atau merah jika BMKG mendeteksi potensi cuaca buruk di wilayah Anda.",
            ),
          ),
        ],

        if (step == 6) ...[
          // Highlight target: Berita Kebencanaan (News Section)
          Positioned(
            top: (newsRect?.top ?? 960) - 4,
            left: (newsRect?.left ?? 16) - 4,
            width: (newsRect?.width ?? (size.width - 32)) + 8,
            height: (newsRect?.height ?? 320) + 8,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF00BCD4), width: 3),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          // Arrow pointing down
          Positioned(
            top: (newsRect?.top ?? 960) - 45,
            left: (newsRect?.left ?? 16) + 84,
            child: IgnorePointer(
              child: const Icon(
                Icons.arrow_downward_rounded,
                color: Colors.white,
                size: 36,
                shadows: [Shadow(color: Color(0xFF00BCD4), blurRadius: 12)],
              ),
            ),
          ),
          // Tooltip container
          Positioned(
            bottom: 125,
            left: 20,
            right: 20,
            child: _buildTooltipBox(
              context,
              number: "6",
              title: "Berita & Edukasi Mitigasi",
              description:
                  "Kumpulan artikel berita bencana terbaru dan panduan keselamatan resmi agar Anda selalu siap menghadapi situasi darurat.",
            ),
          ),
        ],

        if (step == 7) ...[
          // Highlight target: Asuransi Pro-Siaga (Insurance Card)
          Positioned(
            top: (insuranceRect?.top ?? 1300) - 4,
            left: (insuranceRect?.left ?? 16) - 4,
            width: (insuranceRect?.width ?? (size.width - 32)) + 8,
            height: (insuranceRect?.height ?? 320) + 8,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF00BCD4), width: 3),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          // Arrow pointing down
          Positioned(
            top: (insuranceRect?.top ?? 1300) - 45,
            left: (insuranceRect?.left ?? 16) + 84,
            child: IgnorePointer(
              child: const Icon(
                Icons.arrow_downward_rounded,
                color: Colors.white,
                size: 36,
                shadows: [Shadow(color: Color(0xFF00BCD4), blurRadius: 12)],
              ),
            ),
          ),
          // Tooltip container
          Positioned(
            bottom: 125,
            left: 20,
            right: 20,
            child: _buildTooltipBox(
              context,
              number: "7",
              title: "Asuransi Pro-Siaga",
              description:
                  "Program perlindungan mandiri untuk membantu meringankan kerugian materi dan menjaga kondisi keuangan keluarga setelah terjadi bencana alam.",
            ),
          ),
        ],

        if (step == 8) ...[
          // Highlight target: Bottom Navigation Bar
          Positioned(
            top: (bottomNavRect?.top ?? (size.height - 100)) - 4,
            left: (bottomNavRect?.left ?? 16) - 4,
            width: (bottomNavRect?.width ?? (size.width - 32)) + 8,
            height: (bottomNavRect?.height ?? 80) + 8,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF00BCD4), width: 3),
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
          ),
          // Arrow pointing down
          Positioned(
            bottom:
                size.height - (bottomNavRect?.top ?? (size.height - 100)) + 5,
            left: size.width / 2 - 18,
            child: IgnorePointer(
              child: const Icon(
                Icons.arrow_downward_rounded,
                color: Colors.white,
                size: 36,
                shadows: [Shadow(color: Color(0xFF00BCD4), blurRadius: 12)],
              ),
            ),
          ),
          // Tooltip container
          Positioned(
            bottom:
                size.height - (bottomNavRect?.top ?? (size.height - 100)) + 45,
            left: 20,
            right: 20,
            child: _buildTooltipBox(
              context,
              number: "8",
              title: "Menu Navigasi Utama",
              description:
                  "Gunakan menu di bagian bawah untuk berpindah cepat ke halaman cuaca detail, peta anomali gempa AI, dan modul klasifikasi seismik.",
            ),
          ),
        ],

        // Skip button
        Positioned(
          top: 20,
          right: 20,
          child: SafeArea(
            child: TextButton(
              onPressed: onSkip,
              style: TextButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.4),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                "Lewati Panduan",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTooltipBox(
    BuildContext context, {
    required String number,
    required String title,
    required String description,
  }) {
    final int currentStep = int.parse(number);
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 350),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Row with Step badge and Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00BCD4), Color(0xFF1E88E5)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "PANDUAN $number DARI 8",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: Color(0xFF94A3B8),
                  ),
                  onPressed: onSkip,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Sleek progress bar
            Container(
              height: 4,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(2.0),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: currentStep / 8.0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00BCD4), Color(0xFF1E88E5)],
                    ),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Title
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: Color(0xFF0F172A), // Slate 900
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 6),
            // Description
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E293B), // Slate 800 (high contrast for elderly)
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Kembali button (only if step > 1)
                if (currentStep > 1)
                  OutlinedButton(
                    onPressed: onBack,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1E88E5),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      "Kembali",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                const Spacer(),
                // Lanjut button
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00BCD4), Color(0xFF1E88E5)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E88E5).withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 10,
                      ),
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      currentStep == 8 ? "Selesai" : "Lanjut",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
