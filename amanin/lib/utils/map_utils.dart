import 'package:flutter/material.dart';

class PulsatingMarker extends StatefulWidget {
  final Color color;
  final double radius;

  const PulsatingMarker({
    super.key,
    this.color = Colors.red,
    this.radius = 40.0,
  });

  @override
  State<PulsatingMarker> createState() => _PulsatingMarkerState();
}

class _PulsatingMarkerState extends State<PulsatingMarker> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer Wave 2
            _buildWave(1.0, 0.0),
            // Outer Wave 1
            _buildWave(0.66, 0.33),
            // Middle Wave
            _buildWave(0.33, 0.66),
            // Center Dot
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWave(double startAt, double delay) {
    // delay is not really used with repeat(), instead we use intervals within the animation
    double progress = (_controller.value + (1.0 - startAt)) % 1.0;
    double opacity = (1.0 - progress).clamp(0.0, 1.0);
    double size = progress * widget.radius * 2;

    return Opacity(
      opacity: opacity * 0.5,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.color,
            width: 2.0,
          ),
        ),
      ),
    );
  }
}
