import 'package:flutter/material.dart';

class DualTubesLoaderWidget extends StatefulWidget {
  final double width;
  final double height;

  const DualTubesLoaderWidget({
    super.key,
    this.width = 170.0,
    this.height = 110.0,
  });

  @override
  State<DualTubesLoaderWidget> createState() => _DualTubesLoaderWidgetState();
}

class _DualTubesLoaderWidgetState extends State<DualTubesLoaderWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
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
        return CustomPaint(
          size: Size(widget.width, widget.height),
          painter: _DualTubesPainter(progress: _controller.value),
        );
      },
    );
  }
}

class _DualTubesPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0

  _DualTubesPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final tubeW = 28.0;
    final tubeH = 75.0;
    final bottomY = size.height - 10.0;

    // Tube 1 base position (Left)
    final tube1Center = Offset(size.width * 0.28, bottomY - (tubeH / 2));
    // Tube 2 base position (Right)
    final tube2Center = Offset(size.width * 0.72, bottomY - (tubeH / 2));

    double tube1Tilt = 0.0;
    double tube2Tilt = 0.0;
    double tube1Lift = 0.0;
    double tube2Lift = 0.0;
    double tube1Fill = 0.8; // 0.0 to 1.0
    double tube2Fill = 0.2;

    bool pouring1to2 = false;
    bool pouring2to1 = false;
    double streamProgress = 0.0;

    if (progress < 0.45) {
      // Cycle 1: Tube 1 pours into Tube 2
      final p = progress / 0.45;
      if (p < 0.3) {
        // Lift and tilt
        final sub = p / 0.3;
        tube1Tilt = 1.15 * sub;
        tube1Lift = -18.0 * sub;
        tube1Fill = 0.8;
        tube2Fill = 0.2;
      } else if (p < 0.8) {
        // Pouring liquid
        final sub = (p - 0.3) / 0.5;
        tube1Tilt = 1.15;
        tube1Lift = -18.0;
        pouring1to2 = true;
        streamProgress = (sub * 1.5).clamp(0.0, 1.0);
        tube1Fill = 0.8 - (0.6 * sub);
        tube2Fill = 0.2 + (0.6 * sub);
      } else {
        // Un-tilt and settle
        final sub = (p - 0.8) / 0.2;
        tube1Tilt = 1.15 * (1.0 - sub);
        tube1Lift = -18.0 * (1.0 - sub);
        tube1Fill = 0.2;
        tube2Fill = 0.8;
      }
    } else if (progress < 0.55) {
      // Short pause
      tube1Fill = 0.2;
      tube2Fill = 0.8;
    } else {
      // Cycle 2: Tube 2 pours into Tube 1
      final p = (progress - 0.55) / 0.45;
      if (p < 0.3) {
        // Lift and tilt
        final sub = p / 0.3;
        tube2Tilt = -1.15 * sub;
        tube2Lift = -18.0 * sub;
        tube1Fill = 0.2;
        tube2Fill = 0.8;
      } else if (p < 0.8) {
        // Pouring liquid
        final sub = (p - 0.3) / 0.5;
        tube2Tilt = -1.15;
        tube2Lift = -18.0;
        pouring2to1 = true;
        streamProgress = (sub * 1.5).clamp(0.0, 1.0);
        tube2Fill = 0.8 - (0.6 * sub);
        tube1Fill = 0.2 + (0.6 * sub);
      } else {
        // Un-tilt and settle
        final sub = (p - 0.8) / 0.2;
        tube2Tilt = -1.15 * (1.0 - sub);
        tube2Lift = -18.0 * (1.0 - sub);
        tube1Fill = 0.8;
        tube2Fill = 0.2;
      }
    }

    // Color gradients
    const colorCyan = Color(0xFF06B6D4);
    const colorPurple = Color(0xFF8B5CF6);

    // 1. Draw Liquid Stream if pouring
    if (pouring1to2 && streamProgress > 0.05) {
      _drawPourStream(
        canvas: canvas,
        start: Offset(tube1Center.dx + 22, tube1Center.dy - 20 + tube1Lift),
        end: Offset(tube2Center.dx, tube2Center.dy - (tubeH * 0.4)),
        color: colorCyan,
        streamProgress: streamProgress,
      );
    } else if (pouring2to1 && streamProgress > 0.05) {
      _drawPourStream(
        canvas: canvas,
        start: Offset(tube2Center.dx - 22, tube2Center.dy - 20 + tube2Lift),
        end: Offset(tube1Center.dx, tube1Center.dy - (tubeH * 0.4)),
        color: colorPurple,
        streamProgress: streamProgress,
      );
    }

    // 2. Draw Left Tube
    _drawMiniTube(
      canvas: canvas,
      center: Offset(tube1Center.dx, tube1Center.dy + tube1Lift),
      width: tubeW,
      height: tubeH,
      tilt: tube1Tilt,
      fillRatio: tube1Fill,
      liquidColor: colorCyan,
    );

    // 3. Draw Right Tube
    _drawMiniTube(
      canvas: canvas,
      center: Offset(tube2Center.dx, tube2Center.dy + tube2Lift),
      width: tubeW,
      height: tubeH,
      tilt: tube2Tilt,
      fillRatio: tube2Fill,
      liquidColor: colorPurple,
    );
  }

  void _drawMiniTube({
    required Canvas canvas,
    required Offset center,
    required double width,
    required double height,
    required double tilt,
    required double fillRatio,
    required Color liquidColor,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(tilt);

    final double w = width;
    final double h = height;
    final double halfW = w / 2;
    final double halfH = h / 2;

    // Sculpted 3D Bottle Contour Path (Neck, Shoulders, Waist, Base)
    final Path bottlePath = Path();
    final double neckHalfW = w * 0.26;
    final double shoulderHalfW = w * 0.48;
    final double waistHalfW = w * 0.42;
    final double baseHalfW = w * 0.46;

    final double topY = -halfH + 4;
    final double neckBottomY = -halfH + 18;
    final double shoulderY = -halfH + 32;
    final double waistY = -halfH + 52;
    final double bottomY = halfH - 4;

    bottlePath.moveTo(-neckHalfW, topY);
    bottlePath.lineTo(-neckHalfW, neckBottomY);
    bottlePath.cubicTo(-neckHalfW * 1.1, neckBottomY + 6, -shoulderHalfW * 0.9, shoulderY - 5, -shoulderHalfW, shoulderY);
    bottlePath.cubicTo(-shoulderHalfW, (shoulderY + waistY) / 2, -waistHalfW, (shoulderY + waistY) / 2, -waistHalfW, waistY);
    bottlePath.cubicTo(-waistHalfW, (waistY + bottomY) / 2, -baseHalfW, (waistY + bottomY) / 2, -baseHalfW, bottomY - 6);
    bottlePath.cubicTo(-baseHalfW, bottomY, -baseHalfW * 0.5, bottomY, 0, bottomY);
    bottlePath.cubicTo(baseHalfW * 0.5, bottomY, baseHalfW, bottomY, baseHalfW, bottomY - 6);
    bottlePath.cubicTo(baseHalfW, (waistY + bottomY) / 2, waistHalfW, (waistY + bottomY) / 2, waistHalfW, waistY);
    bottlePath.cubicTo(waistHalfW, (shoulderY + waistY) / 2, shoulderHalfW, (shoulderY + waistY) / 2, shoulderHalfW, shoulderY);
    bottlePath.cubicTo(shoulderHalfW * 0.9, shoulderY - 5, neckHalfW * 1.1, neckBottomY + 6, neckHalfW, neckBottomY);
    bottlePath.lineTo(neckHalfW, topY);
    bottlePath.close();

    // 1. Back Glass Wall Depth
    final glassTint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.12),
          const Color(0xFF38BDF8).withValues(alpha: 0.05),
          Colors.black.withValues(alpha: 0.15),
        ],
      ).createShader(Rect.fromLTWH(-halfW, -halfH, w, h));
    canvas.drawPath(bottlePath, glassTint);

    // 2. Volumetric 3D Liquid Fill
    if (fillRatio > 0.03) {
      canvas.save();
      canvas.clipPath(bottlePath);

      final double liquidTopY = bottomY - ((bottomY - topY) * fillRatio.clamp(0.0, 1.0));
      final Rect liquidRect = Rect.fromLTRB(-halfW, liquidTopY, halfW, bottomY);

      final Color leftGleam = Color.lerp(liquidColor, Colors.white, 0.45)!;
      final Color coreColor = liquidColor;
      final Color rightShadow = Color.lerp(liquidColor, Colors.black, 0.35)!;

      final liquidPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: const [0.0, 0.25, 0.70, 1.0],
          colors: [
            leftGleam.withValues(alpha: 0.95),
            coreColor,
            coreColor.withValues(alpha: 0.9),
            rightShadow,
          ],
        ).createShader(liquidRect);

      canvas.drawRect(liquidRect, liquidPaint);

      // Meniscus 3D Oval Surface
      final meniscusRect = Rect.fromCenter(
        center: Offset(0, liquidTopY),
        width: w * 0.82,
        height: 5.0,
      );
      final meniscusPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.45)
        ..style = PaintingStyle.fill;
      canvas.drawOval(meniscusRect, meniscusPaint);

      canvas.restore();
    }

    // 3. Thick Crystal Base Caustic
    final crystalBaseRect = Rect.fromCenter(center: Offset(0, bottomY - 3), width: w * 0.7, height: 5);
    final crystalPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawOval(crystalBaseRect, crystalPaint);

    // 4. Double Wall Glass Outline
    final glassWall = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(bottlePath, glassWall);

    // 5. Specular 3D Highlight Strip down the left side
    final Path gleamPath = Path();
    gleamPath.moveTo(-w * 0.28, shoulderY);
    gleamPath.lineTo(-w * 0.24, bottomY - 8);
    final gleamPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(gleamPath, gleamPaint);

    // 6. 3D Opening Mouth Oval Rim
    final mouthRect = Rect.fromCenter(center: Offset(0, topY), width: w * 0.62, height: 6.0);
    final mouthRimPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawOval(mouthRect, mouthRimPaint);

    canvas.restore();
  }

  void _drawPourStream({
    required Canvas canvas,
    required Offset start,
    required Offset end,
    required Color color,
    required double streamProgress,
  }) {
    final currentEnd = Offset.lerp(start, end, streamProgress)!;
    final control = Offset(start.dx + (currentEnd.dx - start.dx) * 0.4, start.dy + 12);

    final path = Path();
    path.moveTo(start.dx, start.dy);
    path.quadraticBezierTo(control.dx, control.dy, currentEnd.dx, currentEnd.dy);

    // Outer Ambient Glow
    final auraPaint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, auraPaint);

    // Saturated 3D Core Stream
    final streamPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Color.lerp(color, Colors.white, 0.4)!,
          color,
          Color.lerp(color, Colors.black, 0.3)!,
        ],
      ).createShader(Rect.fromPoints(start, currentEnd))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, streamPaint);

    // White Spine Glint
    final shinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, shinePaint);

    // Destination 3D Splash & Ripples
    if (streamProgress > 0.3) {
      final rippleRect = Rect.fromCenter(center: currentEnd, width: 14.0, height: 5.0);
      final ripplePaint = Paint()
        ..color = color.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawOval(rippleRect, ripplePaint);

      // Micro Droplets
      final dropPaint = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(currentEnd.dx - 5, currentEnd.dy - 4), 1.6, dropPaint);
      canvas.drawCircle(Offset(currentEnd.dx + 6, currentEnd.dy - 6), 1.8, dropPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DualTubesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
