// lib/presentation/widgets/liquid_stream_painter.dart

import 'package:flutter/material.dart';

class LiquidStreamPainter extends CustomPainter {
  final Offset from;
  final Offset to;
  final Color color;
  final double progress; // 0.0 -> 1.0

  LiquidStreamPainter({
    required this.from,
    required this.to,
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.01) return;

    final paint = Paint()
      ..color = color.withOpacity(0.85)
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(from.dx, from.dy);

    // نقطة التحكم بالقوس المنحني
    final controlPoint = Offset(
      (from.dx + to.dx) / 2,
      from.dy - 30,
    );

    // النقطة الحالية بناءً على تقدم الأنيميشن
    final currentTo = Offset(
      from.dx + (to.dx - from.dx) * progress,
      from.dy + (to.dy - from.dy) * progress,
    );

    path.quadraticBezierTo(
      controlPoint.dx,
      controlPoint.dy,
      currentTo.dx,
      currentTo.dy,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant LiquidStreamPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.from != from ||
        oldDelegate.to != to ||
        oldDelegate.color != color;
  }
}
