import 'package:flutter/material.dart';

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
        Rect.fromCircle(center: Offset(size.width + 8, size.height / 2), radius: 16),
        2.3, // start angle
        1.68, // sweep angle
        false,
        paint,
      );
      // Large arc
      canvas.drawArc(
        Rect.fromCircle(center: Offset(size.width + 8, size.height / 2), radius: 24),
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
        // Semi-transparent background (IgnorePointer to allow scrolls to pass through to underlying view)
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
                shadows: [
                  Shadow(
                    color: Color(0xFF00BCD4),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
          ),
          // Tooltip container
          Positioned(
            top: 200, // Fixed top coordinate to keep tooltip readable during scrolls
            left: 20,
            right: 20,
            child: _buildTooltipBox(
              context,
              number: "1",
              title: "Deteksi Lingkungan Dinamis",
              description: "Kartu ini memantau kondisi Anda secara cerdas. Panel 'Posisi Anda' dapat diketuk untuk beralih status secara manual, sedangkan panel 'Tipe Wilayah' mendeteksi otomatis tipe geografi Anda menggunakan koordinat GPS di seluruh Indonesia.",
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
                shadows: [
                  Shadow(
                    color: Color(0xFF00BCD4),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
          ),
          // Tooltip container
          Positioned(
            bottom: 125, // Fixed bottom coordinate to stay visible and readable during scrolls
            left: 20,
            right: 20,
            child: _buildTooltipBox(
              context,
              number: "2",
              title: "Info Gempa Terkini",
              description: "Menampilkan peta episentrum gempa bumi terkini beserta parameter detailnya (magnitudo, kedalaman, wilayah, jarak dari Anda, dan getaran yang dirasakan).",
            ),
          ),
        ],

        if (step == 3) ...[
          // Highlight target: Perlengkapan Siaga (Survival Kit)
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
                shadows: [
                  Shadow(
                    color: Color(0xFF00BCD4),
                    blurRadius: 12,
                  ),
                ],
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
              title: "Perlengkapan Siaga Bencana",
              description: "Menyediakan akses cepat ke toko perlengkapan siaga darurat (tas 72 jam, radio engkol surya, P3K, dll.) dengan harga/diskon khusus mitra Amanin.",
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
                shadows: [
                  Shadow(
                    color: Color(0xFF00BCD4),
                    blurRadius: 12,
                  ),
                ],
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
              title: "Informasi Cuaca Terkini",
              description: "Menampilkan prakiraan cuaca, suhu, kelembaban, kecepatan angin, dan indeks radiasi UV secara real-time berdasarkan lokasi GPS perangkat Anda.",
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
                shadows: [
                  Shadow(
                    color: Color(0xFF00BCD4),
                    blurRadius: 12,
                  ),
                ],
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
              title: "Sistem Peringatan Dini",
              description: "Kotak status peringatan dini yang otomatis berubah warna menjadi jingga/merah apabila terdapat peringatan cuaca buruk ekstrim dari BMKG di wilayah Anda.",
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
                shadows: [
                  Shadow(
                    color: Color(0xFF00BCD4),
                    blurRadius: 12,
                  ),
                ],
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
              title: "Berita Kebencanaan Terbaru",
              description: "Menyajikan artikel berita aktual seputar kejadian gempa bumi, tsunami, cuaca ekstrim, dan mitigasi bencana langsung dari sumber terpercaya.",
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
                shadows: [
                  Shadow(
                    color: Color(0xFF00BCD4),
                    blurRadius: 12,
                  ),
                ],
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
              title: "Asuransi Gempa & Bencana",
              description: "Layanan Asuransi Pro-Siaga untuk memberikan perlindungan finansial bagi aset berharga Anda dari dampak bencana alam gempa bumi dan banjir.",
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
            bottom: size.height - (bottomNavRect?.top ?? (size.height - 100)) + 5,
            left: size.width / 2 - 18,
            child: IgnorePointer(
              child: const Icon(
                Icons.arrow_downward_rounded,
                color: Colors.white,
                size: 36,
                shadows: [
                  Shadow(
                    color: Color(0xFF00BCD4),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
          ),
          // Tooltip container
          Positioned(
            bottom: size.height - (bottomNavRect?.top ?? (size.height - 100)) + 45,
            left: 20,
            right: 20,
            child: _buildTooltipBox(
              context,
              number: "8",
              title: "Navigasi Menu Utama",
              description: "Gunakan bar navigasi ini untuk beralih secara cepat ke fitur prakiraan cuaca detail, peta anomali gempa AI, dan pusat edukasi mitigasi bencana.",
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("Lewati Panduan", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTooltipBox(BuildContext context, {required String number, required String title, required String description}) {
    final int currentStep = int.parse(number);
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 330),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                      fontSize: 9,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF94A3B8)),
                  onPressed: onSkip,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Sleek progress bar
            Container(
              height: 3,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(1.5),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: currentStep / 8.0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00BCD4), Color(0xFF1E88E5)],
                    ),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Title
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF0F172A), // Slate 900
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 5),
            // Description
            Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF475569), // Slate 600
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      "Kembali",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
                        color: const Color(0xFF1E88E5).withOpacity(0.25),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      currentStep == 8 ? "Selesai" : "Lanjut",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
