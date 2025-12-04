import 'package:flutter/material.dart';
import 'dart:math' as math;

class LoadingOverlay extends StatefulWidget {
  final AnimationController controller;

  const LoadingOverlay({super.key, required this.controller});

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return CustomPaint(
              size: const Size(80, 80),
              painter: _ElasticLoadingPainter(_animationController.value),
            );
          },
        ),
      ),
    );
  }
}

class _ElasticLoadingPainter extends CustomPainter {
  final double progress;

  _ElasticLoadingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = const Color(0xFFFF00FF)
      ..style = PaintingStyle.fill;

    // Animación elástica de dos cuadrados
    final angle = progress * 2 * math.pi;
    final distance = 20.0;
    final scale = 0.9 + 0.1 * math.sin(progress * 4 * math.pi);

    // Cuadrado 1
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.translate(-distance, distance);
    canvas.scale(scale);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-10, -10, 20, 20),
        const Radius.circular(4),
      ),
      paint,
    );
    canvas.restore();

    // Cuadrado 2
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.translate(distance, -distance);
    canvas.scale(scale);
    final alpha = (math.sin(progress * 2 * math.pi) + 1) / 2;
    paint.color = const Color(0xFFFF00FF).withOpacity(alpha);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-10, -10, 20, 20),
        const Radius.circular(4),
      ),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ElasticLoadingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

