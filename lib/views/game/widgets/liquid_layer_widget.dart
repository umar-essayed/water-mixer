import 'package:flutter/material.dart';

class LiquidPainter extends CustomPainter {
  final List<Color> layers;
  final int capacity;
  final int hiddenCount;
  final double rimOffset;
  final double bottomRadius;
  final double surfaceWobble; // Subtle dynamic wave factor

  LiquidPainter({
    required this.layers,
    this.capacity = 4,
    this.hiddenCount = 0,
    this.rimOffset = 18.0,
    this.bottomRadius = 24.0,
    this.surfaceWobble = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (layers.isEmpty) return;

    final double innerMargin = 8.0;
    final double contentWidth = size.width - (innerMargin * 2);
    final double contentHeight = size.height - rimOffset - 8.0;
    final double layerHeight = contentHeight / capacity;
    final double bottomY = size.height - 8.0;

    for (int i = 0; i < layers.length; i++) {
      final isHidden = (i < hiddenCount) && (i < layers.length - 1);
      final color = isHidden ? const Color(0xFF334155) : layers[i];
      final double layerBottom = bottomY - (i * layerHeight);
      final double layerTop = layerBottom - layerHeight;

      final Rect layerRect = Rect.fromLTRB(
        innerMargin,
        layerTop,
        innerMargin + contentWidth,
        layerBottom,
      );

      final Paint fillPaint = Paint()
        ..shader = isHidden
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF475569),
                  Color(0xFF334155),
                  Color(0xFF1E293B),
                ],
              ).createShader(layerRect)
            : LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  color.withValues(alpha: 0.95),
                  color,
                  color.withValues(alpha: 0.85),
                ],
              ).createShader(layerRect);

      // Path for the liquid layer
      Path path = Path();
      if (i == 0) {
        // Bottom layer: apply rounded bottom corners matching U-shape
        final rrect = RRect.fromRectAndCorners(
          layerRect,
          bottomLeft: Radius.circular(bottomRadius),
          bottomRight: Radius.circular(bottomRadius),
        );
        path.addRRect(rrect);
      } else {
        // Upper layers: rectangular body
        path.addRect(layerRect);
      }

      canvas.drawPath(path, fillPaint);

      if (isHidden) {
        // Subtle mystery border
        final Paint borderPaint = Paint()
          ..color = const Color(0xFF64748B).withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
        canvas.drawPath(path, borderPaint);

        // Draw '?' symbol in center of the hidden layer
        final textSpan = TextSpan(
          text: '?',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: (layerHeight * 0.55).clamp(10.0, 18.0),
            fontWeight: FontWeight.bold,
          ),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        final textOffset = Offset(
          layerRect.center.dx - (textPainter.width / 2),
          layerRect.center.dy - (textPainter.height / 2),
        );
        textPainter.paint(canvas, textOffset);
      } else {
        // Top surface oval highlight for 3D liquid depth
        final double ovalHeight = 6.0;
        final Rect surfaceOvalRect = Rect.fromCenter(
          center: Offset(size.width / 2, layerTop),
          width: contentWidth - 2,
          height: ovalHeight,
        );

        final Paint surfacePaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.28)
          ..style = PaintingStyle.fill;

        canvas.drawOval(surfaceOvalRect, surfacePaint);

        // Subtle surface rim edge line
        final Paint rimLinePaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

        canvas.drawOval(surfaceOvalRect, rimLinePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant LiquidPainter oldDelegate) {
    if (oldDelegate.layers.length != layers.length) return true;
    if (oldDelegate.hiddenCount != hiddenCount) return true;
    for (int i = 0; i < layers.length; i++) {
      if (oldDelegate.layers[i] != layers[i]) return true;
    }
    return oldDelegate.surfaceWobble != surfaceWobble;
  }
}
