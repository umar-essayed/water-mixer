import 'dart:math';
import 'package:flutter/material.dart';

/// Ultra-Realistic 3D Sculpted Glass Bottle & Volumetric Dynamic Fluid CustomPainter
/// Features:
/// 1. Dynamic undulating sine-wave liquid boundaries between all color layers with animated wave motion
/// 2. Fluid inertia & sloshing physics when lifted, moved, or tilted
/// 3. Completely soft, realistic diffused drop shadow with liquid caustics (zero harsh lines)
/// 4. Frosted Ice & Swirling Mystical Fog for hidden layers
/// 5. Multiple 3D bottle silhouettes (Lab tube, Magic potion, Soda bottle, Conical flask, etc.)
class Bottle3DPainter extends CustomPainter {
  final List<Color> layers;
  final int capacity;
  final int hiddenCount;
  final String skinId;
  final double surfaceWobble; // Dynamic wave oscillation phase
  final double bubblePhase;   // Continuous rising micro-bubbles
  final double tiltAngle;     // Dynamic liquid tilt angle when pouring (radians)
  final double drainUnits;    // Active liquid units draining out during pour (0.0 to N)
  final double incomingUnits; // Active liquid units pouring into this tube (0.0 to N)
  final Color? incomingColor; // Color of active incoming liquid
  final bool isSelected;
  final bool isSolved;

  Bottle3DPainter({
    required this.layers,
    this.capacity = 4,
    this.hiddenCount = 0,
    this.skinId = 'classic',
    this.surfaceWobble = 0.0,
    this.bubblePhase = 0.0,
    this.tiltAngle = 0.0,
    this.drainUnits = 0.0,
    this.incomingUnits = 0.0,
    this.incomingColor,
    this.isSelected = false,
    this.isSolved = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;

    // 1. Ground Drop Shadow removed as requested (eliminates harsh/clipped dark lines)

    // 2. Compute Outer Glass Shell Path & Inner Fluid Chamber Path
    final Path outerPath = _createBottlePath(w, h, cx, inset: 0.0);
    final Path innerChamber = _createBottlePath(w, h, cx, inset: 3.6);

    // 3. Draw Back Glass Wall (Translucent Depth & Ambient Refraction)
    _drawBackGlassWall(canvas, outerPath, w, h);

    // 4. Draw Volumetric Liquid Layers with Moving Sine Waves & Sloshing
    if (layers.isNotEmpty || incomingUnits > 0.001) {
      canvas.save();
      canvas.clipPath(innerChamber);
      _drawVolumetricLiquid(canvas, size, innerChamber);
      canvas.restore();
    }

    // 5. Draw Front Glass Shading: Specular Beams, Fresnel Edge, Crystal Base Caustics
    _drawFrontGlassShading(canvas, outerPath, innerChamber, w, h, cx);

    // 6. Draw 3D Glass Mouth Rim
    _drawGlassMouthRim(canvas, cx, w);
  }

  /// Create bottle contour dynamically based on skinId
  Path _createBottlePath(double w, double h, double cx, {required double inset}) {
    switch (skinId) {
      case 'magic_potion':
        return _createMagicPotionPath(w, h, cx, inset);
      case 'juice_bottle':
        return _createJuiceBottlePath(w, h, cx, inset);
      case 'flask':
        return _createConicalFlaskPath(w, h, cx, inset);
      case 'classic':
      case 'neon':
      case 'crystal':
      default:
        return _createClassicLabTubePath(w, h, cx, inset);
    }
  }

  /// 1. Classic Sleek Laboratory Test Tube Contour
  Path _createClassicLabTubePath(double w, double h, double cx, double inset) {
    final Path p = Path();
    final double neckHalfW = (w * 0.24) - (inset * 0.4);
    final double bodyHalfW = (w * 0.45) - inset;
    final double lipY = 14.0 + inset;
    final double neckBottomY = 48.0;
    final double shoulderY = 76.0;
    final double baseTopY = h - 24.0 - inset;
    final double bottomY = h - 6.0 - inset;

    p.moveTo(cx - neckHalfW, lipY);
    p.lineTo(cx - neckHalfW, neckBottomY);
    p.cubicTo(
      cx - neckHalfW, neckBottomY + 14.0,
      cx - bodyHalfW, shoulderY - 10.0,
      cx - bodyHalfW, shoulderY,
    );
    p.lineTo(cx - bodyHalfW, baseTopY);
    p.cubicTo(
      cx - bodyHalfW, bottomY,
      cx - bodyHalfW * 0.65, bottomY,
      cx, bottomY,
    );
    p.cubicTo(
      cx + bodyHalfW * 0.65, bottomY,
      cx + bodyHalfW, bottomY,
      cx + bodyHalfW, baseTopY,
    );
    p.lineTo(cx + bodyHalfW, shoulderY);
    p.cubicTo(
      cx + bodyHalfW, shoulderY - 10.0,
      cx + neckHalfW, neckBottomY + 14.0,
      cx + neckHalfW, neckBottomY,
    );
    p.lineTo(cx + neckHalfW, lipY);
    p.close();
    return p;
  }

  /// 2. Magic Potion Flask Contour (Bulbous spherical belly)
  Path _createMagicPotionPath(double w, double h, double cx, double inset) {
    final Path p = Path();
    final double neckHalfW = (w * 0.20) - (inset * 0.4);
    final double bellyHalfW = (w * 0.49) - inset;
    final double lipY = 14.0 + inset;
    final double neckBottomY = 56.0;
    final double bellyCenterY = h * 0.58;
    final double bottomY = h - 6.0 - inset;

    p.moveTo(cx - neckHalfW, lipY);
    p.lineTo(cx - neckHalfW, neckBottomY);
    p.cubicTo(
      cx - neckHalfW, neckBottomY + 22.0,
      cx - bellyHalfW, bellyCenterY - 35.0,
      cx - bellyHalfW, bellyCenterY,
    );
    p.cubicTo(
      cx - bellyHalfW, bellyCenterY + 40.0,
      cx - bellyHalfW * 0.8, bottomY,
      cx, bottomY,
    );
    p.cubicTo(
      cx + bellyHalfW * 0.8, bottomY,
      cx + bellyHalfW, bellyCenterY + 40.0,
      cx + bellyHalfW, bellyCenterY,
    );
    p.cubicTo(
      cx + bellyHalfW, bellyCenterY - 35.0,
      cx + neckHalfW, neckBottomY + 22.0,
      cx + neckHalfW, neckBottomY,
    );
    p.lineTo(cx + neckHalfW, lipY);
    p.close();
    return p;
  }

  /// 3. Classic Soda & Juice Bottle Contour (Ribbed waist)
  Path _createJuiceBottlePath(double w, double h, double cx, double inset) {
    final Path p = Path();
    final double neckHalfW = (w * 0.22) - (inset * 0.4);
    final double shoulderHalfW = (w * 0.46) - inset;
    final double waistHalfW = (w * 0.38) - inset;
    final double baseHalfW = (w * 0.45) - inset;

    final double lipY = 14.0 + inset;
    final double neckBottomY = 46.0;
    final double shoulderY = 78.0;
    final double waistY = 135.0;
    final double baseTopY = h - 22.0 - inset;
    final double bottomY = h - 6.0 - inset;

    p.moveTo(cx - neckHalfW, lipY);
    p.lineTo(cx - neckHalfW, neckBottomY);
    p.cubicTo(
      cx - neckHalfW * 1.05, neckBottomY + 16.0,
      cx - shoulderHalfW * 0.95, shoulderY - 12.0,
      cx - shoulderHalfW, shoulderY,
    );
    p.cubicTo(
      cx - shoulderHalfW, (shoulderY + waistY) / 2,
      cx - waistHalfW, (shoulderY + waistY) / 2,
      cx - waistHalfW, waistY,
    );
    p.cubicTo(
      cx - waistHalfW, (waistY + baseTopY) / 2,
      cx - baseHalfW, (waistY + baseTopY) / 2,
      cx - baseHalfW, baseTopY,
    );
    p.cubicTo(
      cx - baseHalfW, bottomY,
      cx - baseHalfW * 0.7, bottomY,
      cx, bottomY,
    );
    p.cubicTo(
      cx + baseHalfW * 0.7, bottomY,
      cx + baseHalfW, bottomY,
      cx + baseHalfW, baseTopY,
    );
    p.cubicTo(
      cx + baseHalfW, (waistY + baseTopY) / 2,
      cx + waistHalfW, (waistY + baseTopY) / 2,
      cx + waistHalfW, waistY,
    );
    p.cubicTo(
      cx + waistHalfW, (shoulderY + waistY) / 2,
      cx + shoulderHalfW, (shoulderY + waistY) / 2,
      cx + shoulderHalfW, shoulderY,
    );
    p.cubicTo(
      cx + shoulderHalfW * 0.95, shoulderY - 12.0,
      cx + neckHalfW * 1.05, neckBottomY + 16.0,
      cx + neckHalfW, neckBottomY,
    );
    p.lineTo(cx + neckHalfW, lipY);
    p.close();
    return p;
  }

  /// 4. Conical Chemical Flask Contour
  Path _createConicalFlaskPath(double w, double h, double cx, double inset) {
    final Path p = Path();
    final double neckHalfW = (w * 0.22) - (inset * 0.4);
    final double baseHalfW = (w * 0.48) - inset;
    final double lipY = 14.0 + inset;
    final double neckBottomY = 58.0;
    final double bottomY = h - 6.0 - inset;

    p.moveTo(cx - neckHalfW, lipY);
    p.lineTo(cx - neckHalfW, neckBottomY);
    p.lineTo(cx - baseHalfW, bottomY - 14.0);
    p.cubicTo(
      cx - baseHalfW, bottomY,
      cx - baseHalfW * 0.6, bottomY,
      cx, bottomY,
    );
    p.cubicTo(
      cx + baseHalfW * 0.6, bottomY,
      cx + baseHalfW, bottomY,
      cx + baseHalfW, bottomY - 14.0,
    );
    p.lineTo(cx + neckHalfW, neckBottomY);
    p.lineTo(cx + neckHalfW, lipY);
    p.close();
    return p;
  }

  /// Ground drop shadow removed to prevent harsh clipped lines
  void _drawSoftNaturalShadow(Canvas canvas, double cx, double h, double w) {}

  /// Back wall glass depth with cylindrical Fresnel illumination
  void _drawBackGlassWall(Canvas canvas, Path outerPath, double w, double h) {
    final Paint backGlassPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        stops: const [0.0, 0.10, 0.30, 0.50, 0.70, 0.90, 1.0],
        colors: [
          Colors.white.withValues(alpha: 0.28),
          Colors.white.withValues(alpha: 0.08),
          const Color(0xFF00F0FF).withValues(alpha: 0.04),
          Colors.black.withValues(alpha: 0.12),
          const Color(0xFF00F0FF).withValues(alpha: 0.04),
          Colors.white.withValues(alpha: 0.08),
          Colors.white.withValues(alpha: 0.24),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(outerPath, backGlassPaint);
  }

  /// Volumetric 3D liquid layers with animated undulating sine waves and realistic sloshing
  void _drawVolumetricLiquid(Canvas canvas, Size size, Path chamberPath) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;

    final double bottomY = h - 14.0;
    final double topUsableY = 28.0;
    final double totalHeight = bottomY - topUsableY;
    final double layerH = totalHeight / capacity;

    final double effectiveCount = (layers.length - drainUnits).clamp(0.0, capacity.toDouble());
    final double overallLiquidTop = bottomY - (effectiveCount * layerH);

    // Fluid Sloshing Physics: Wobble amplitude increases when lifted, moving, or tilted (calm when solved)
    final double baseAmp = isSolved ? 0.6 : (isSelected ? 3.8 : (tiltAngle.abs() > 0.1 ? 4.5 : 1.6));

    // 1. Draw Each Liquid Layer with Dynamic Sine Wave Interfaces
    for (int i = 0; i < layers.length; i++) {
      final double layerBottom = bottomY - (i * layerH);
      final double layerTop = layerBottom - layerH;

      if (overallLiquidTop >= layerBottom) continue; // Drained

      final double actualTop = max(layerTop, overallLiquidTop);
      final isHidden = (i < hiddenCount) && (i < layers.length - 1);
      final Color baseColor = layers[i];

      final Rect layerRect = Rect.fromLTRB(2, actualTop, w - 2, layerBottom);

      if (isHidden) {
        // Frosted Ice & Swirling Mystical Fog
        _drawFrostedIceMysteryLayer(canvas, cx, actualTop, layerBottom, w, layerH);
      } else {
        // Glowing Saturated Liquid with 3D Cylindrical Shader
        final Color leftGleam = Color.lerp(baseColor, Colors.white, 0.46)!;
        final Color coreColor = baseColor;
        final Color rightShadow = Color.lerp(baseColor, Colors.black, 0.42)!;

        final Paint liquidPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: const [0.0, 0.20, 0.65, 1.0],
            colors: [
              leftGleam.withValues(alpha: 0.95),
              coreColor,
              coreColor.withValues(alpha: 0.92),
              rightShadow,
            ],
          ).createShader(layerRect);

        // Undulating Animated Sine-Wave Layer Boundary Path
        // The wave oscillates and moves continuously across the liquid surface
        final Path wavePath = Path();
        const int steps = 24;
        final double dx = w / steps;

        // Top wave boundary
        for (int s = 0; s <= steps; s++) {
          final double x = s * dx;
          final double normalizedX = s / steps;
          // Harmonic wave equation
          final double waveY = actualTop +
              sin((normalizedX * 2 * pi) + surfaceWobble + (i * 1.6)) * baseAmp +
              cos((normalizedX * pi) + surfaceWobble * 0.7) * (baseAmp * 0.35);

          if (s == 0) {
            wavePath.moveTo(x, waveY);
          } else {
            wavePath.lineTo(x, waveY);
          }
        }

        // Bottom wave boundary (connecting to next layer with slight phase shift)
        for (int s = steps; s >= 0; s--) {
          final double x = s * dx;
          final double normalizedX = s / steps;
          final double waveY = layerBottom +
              sin((normalizedX * 2 * pi) + surfaceWobble + ((i - 1) * 1.6)) * (baseAmp * 0.8);
          wavePath.lineTo(x, waveY);
        }
        wavePath.close();

        canvas.drawPath(wavePath, liquidPaint);

        // Soft fluid meniscus highlight line along the undulating boundary
        if (i < layers.length - 1) {
          final Path meniscusLine = Path();
          for (int s = 0; s <= steps; s++) {
            final double x = s * dx;
            final double normalizedX = s / steps;
            final double waveY = actualTop +
                sin((normalizedX * 2 * pi) + surfaceWobble + (i * 1.6)) * baseAmp;
            if (s == 0) {
              meniscusLine.moveTo(x, waveY);
            } else {
              meniscusLine.lineTo(x, waveY);
            }
          }
          final Paint gleamPaint = Paint()
            ..color = Colors.white.withValues(alpha: 0.30)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2;
          canvas.drawPath(meniscusLine, gleamPaint);
        }

        // Effervescent Micro-Bubbles
        _drawLayerBubbles(canvas, cx, actualTop, layerBottom, w, baseColor, i);
      }
    }

    // 2. Draw Incoming Liquid Stream (if receiving pour)
    if (incomingUnits > 0.001 && incomingColor != null) {
      final double existingLiquidTop = bottomY - (layers.length * layerH);
      final double incomingTop = (existingLiquidTop - (incomingUnits * layerH)).clamp(topUsableY, bottomY);
      final Rect incRect = Rect.fromLTRB(2, incomingTop, w - 2, existingLiquidTop);

      final Color leftGleam = Color.lerp(incomingColor!, Colors.white, 0.46)!;
      final Color rightShadow = Color.lerp(incomingColor!, Colors.black, 0.42)!;

      final Paint incPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: const [0.0, 0.20, 0.65, 1.0],
          colors: [
            leftGleam.withValues(alpha: 0.95),
            incomingColor!,
            incomingColor!.withValues(alpha: 0.92),
            rightShadow,
          ],
        ).createShader(incRect);

      final Path incWavePath = Path();
      const int steps = 24;
      final double dx = w / steps;

      for (int s = 0; s <= steps; s++) {
        final double x = s * dx;
        final double normalizedX = s / steps;
        final double waveY = incomingTop + sin((normalizedX * 2 * pi) + surfaceWobble) * (baseAmp * 1.2);
        if (s == 0) {
          incWavePath.moveTo(x, waveY);
        } else {
          incWavePath.lineTo(x, waveY);
        }
      }
      incWavePath.lineTo(w, existingLiquidTop + 2.0);
      incWavePath.lineTo(0, existingLiquidTop + 2.0);
      incWavePath.close();

      canvas.drawPath(incWavePath, incPaint);
      _drawLayerBubbles(canvas, cx, incomingTop, existingLiquidTop, w, incomingColor!, 88);
    }

    // 3. Dynamic Sine-Wave Meniscus Surface at Top of Liquid Column
    final double activeTop = (incomingUnits > 0.001 && incomingColor != null)
        ? (bottomY - (layers.length * layerH) - (incomingUnits * layerH)).clamp(topUsableY, bottomY)
        : overallLiquidTop;

    if (activeTop < bottomY - 2.0) {
      final Color topColor = (incomingUnits > 0.001 && incomingColor != null)
          ? incomingColor!
          : (layers.isNotEmpty ? layers[min(layers.length - 1, max(0, effectiveCount.ceil() - 1))] : Colors.white);

      final double meniscusHalfW = _getChamberHalfWidthAtY(w, activeTop) - 2.0;
      final double waveOffset = sin(surfaceWobble) * baseAmp;

      canvas.save();
      // Fluid Slosh Horizon: Liquid stays level with gravity when tilted
      if (tiltAngle.abs() > 0.05) {
        canvas.translate(cx, activeTop + waveOffset);
        canvas.rotate(-tiltAngle * 0.55);
        canvas.translate(-cx, -(activeTop + waveOffset));
      }

      final Rect meniscusRect = Rect.fromCenter(
        center: Offset(cx, activeTop + waveOffset),
        width: meniscusHalfW * 2.0,
        height: 9.0,
      );

      final Paint meniscusFill = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.65),
            topColor.withValues(alpha: 0.50),
            Colors.white.withValues(alpha: 0.28),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(meniscusRect);

      canvas.drawOval(meniscusRect, meniscusFill);

      // Bright meniscus crest specular ring
      final Paint meniscusStroke = Paint()
        ..color = Colors.white.withValues(alpha: 0.80)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3;
      canvas.drawOval(meniscusRect, meniscusStroke);
      canvas.restore();
    }
  }

  /// Frosted Ice & Swirling Mystical Fog for hidden '?' blocks
  void _drawFrostedIceMysteryLayer(
    Canvas canvas,
    double cx,
    double topY,
    double bottomY,
    double w,
    double layerH,
  ) {
    final Rect fogRect = Rect.fromLTRB(2, topY, w - 2, bottomY);

    final Paint fogPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: const [
          Color(0xFF334155),
          Color(0xFF1E293B),
          Color(0xFF0F172A),
        ],
      ).createShader(fogRect);

    final Path layerPath = Path();
    layerPath.moveTo(0, topY);
    layerPath.quadraticBezierTo(cx, topY + 1.5, w, topY);
    layerPath.lineTo(w, bottomY + 1.0);
    layerPath.quadraticBezierTo(cx, bottomY + 2.5, 0, bottomY + 1.0);
    layerPath.close();
    canvas.drawPath(layerPath, fogPaint);

    final Paint frostStreak = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(cx - 16, topY + 6), Offset(cx + 14, bottomY - 6), frostStreak);
    canvas.drawLine(Offset(cx - 22, bottomY - 8), Offset(cx - 8, topY + 10), frostStreak);

    final textSpan = TextSpan(
      text: '?',
      style: TextStyle(
        color: const Color(0xFF38BDF8).withValues(alpha: 0.90),
        fontSize: (layerH * 0.52).clamp(13.0, 21.0),
        fontWeight: FontWeight.w900,
        shadows: [
          Shadow(
            color: const Color(0xFF00F0FF).withValues(alpha: 0.75),
            blurRadius: 10,
          ),
        ],
      ),
    );
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(cx - (textPainter.width / 2), (topY + bottomY) / 2 - (textPainter.height / 2)),
    );
  }

  /// Animated fizzy micro-bubbles inside the liquid
  void _drawLayerBubbles(Canvas canvas, double cx, double topY, double bottomY, double w, Color color, int seed) {
    final double layerH = bottomY - topY;
    if (layerH < 10) return;

    final Paint bubblePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;
    final Paint bubbleGleam = Paint()
      ..color = Colors.white.withValues(alpha: 0.80)
      ..style = PaintingStyle.fill;

    for (int b = 0; b < 3; b++) {
      final double progress = (bubblePhase * 0.75 + seed * 0.31 + b * 0.33) % 1.0;
      final double by = bottomY - (progress * layerH);
      final double bx = cx + sin((bubblePhase * 3.2) + b * 2.1 + seed) * (w * 0.18);
      final double radius = 1.8 + (b % 2) * 0.8;

      canvas.drawCircle(Offset(bx, by), radius, bubblePaint);
      canvas.drawCircle(Offset(bx - radius * 0.35, by - radius * 0.35), radius * 0.35, bubbleGleam);
    }
  }

  /// Front glass shading: soft specular highlight strip, Fresnel rim light, and thick crystal base caustics
  void _drawFrontGlassShading(Canvas canvas, Path outerPath, Path innerPath, double w, double h, double cx) {
    // 1. Double glass wall contour (Glass thickness refraction)
    final Paint glassWallOutline = Paint()
      ..color = _getSkinGlassColor().withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(outerPath, glassWallOutline);

    final Paint innerWallOutline = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(innerPath, innerWallOutline);

    // 2. 3D Cylindrical Surface Gloss
    final Paint cylinderShine = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        stops: const [0.0, 0.12, 0.35, 0.65, 0.88, 1.0],
        colors: [
          Colors.white.withValues(alpha: 0.35),
          Colors.white.withValues(alpha: 0.10),
          Colors.transparent,
          Colors.transparent,
          Colors.white.withValues(alpha: 0.08),
          Colors.white.withValues(alpha: 0.28),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(outerPath, cylinderShine);

    // 3. Thick Crystal Base Refraction (Solid glass bottom without harsh lines)
    final Path crystalBase = Path();
    crystalBase.moveTo(w * 0.08, h - 22);
    crystalBase.cubicTo(w * 0.15, h - 8, w * 0.35, h - 6, cx, h - 6);
    crystalBase.cubicTo(w * 0.65, h - 6, w * 0.85, h - 8, w * 0.92, h - 22);
    crystalBase.lineTo(w * 0.88, h - 14);
    crystalBase.cubicTo(w * 0.65, h - 11, w * 0.35, h - 11, cx, h - 11);
    crystalBase.cubicTo(w * 0.25, h - 11, w * 0.12, h - 14, w * 0.08, h - 22);
    crystalBase.close();

    final Paint crystalPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.65),
          _getSkinAccentColor().withValues(alpha: 0.35),
          Colors.white.withValues(alpha: 0.15),
        ],
      ).createShader(Rect.fromLTWH(0, h - 24, w, 20));
    canvas.drawPath(crystalBase, crystalPaint);

    // Internal punt arch glint
    final Path puntArch = Path();
    puntArch.moveTo(w * 0.25, h - 9);
    puntArch.quadraticBezierTo(cx, h - 16, w * 0.75, h - 9);
    final Paint puntPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawPath(puntArch, puntPaint);

    // 4. Primary 3D Specular Light Stream (Curvaceous left highlight)
    final Path specularBeam = Path();
    specularBeam.moveTo(w * 0.32, 20.0);
    specularBeam.lineTo(w * 0.32, 46.0);
    specularBeam.cubicTo(w * 0.30, 56.0, w * 0.18, 68.0, w * 0.16, 84.0);
    specularBeam.cubicTo(w * 0.15, 120.0, w * 0.19, 145.0, w * 0.16, 175.0);
    specularBeam.lineTo(w * 0.15, h - 22.0);

    final Paint specularPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0.0, 0.15, 0.70, 1.0],
        colors: [
          Colors.white.withValues(alpha: 0.95),
          Colors.white.withValues(alpha: 0.90),
          Colors.white.withValues(alpha: 0.60),
          Colors.white.withValues(alpha: 0.18),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(specularBeam, specularPaint);

    // 5. Secondary Right Fresnel Rim Light
    final Path fresnelBeam = Path();
    fresnelBeam.moveTo(w * 0.84, 86.0);
    fresnelBeam.cubicTo(w * 0.82, 120.0, w * 0.79, 150.0, w * 0.83, h - 26.0);

    final Paint fresnelPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(fresnelBeam, fresnelPaint);

    // 6. Skin-Specific Decorative Overlays
    _drawSkinDecorations(canvas, w, h, cx);
  }

  /// Distinctive 3D themes and skin markings
  void _drawSkinDecorations(Canvas canvas, double w, double h, double cx) {
    if (skinId == 'flask') {
      final Paint markPaint = Paint()
        ..color = const Color(0xFF00F0FF).withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      final Paint subMark = Paint()
        ..color = Colors.white.withValues(alpha: 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4;

      final marksY = [90.0, 115.0, 140.0, 165.0, 190.0];
      for (int i = 0; i < marksY.length; i++) {
        final double y = marksY[i];
        final bool major = i % 2 == 0;
        final double lineW = major ? 12.0 : 8.0;
        canvas.drawLine(Offset(w * 0.78 - lineW, y), Offset(w * 0.78, y), major ? markPaint : subMark);
      }
    } else if (skinId == 'neon') {
      final Paint neonRing = Paint()
        ..color = const Color(0xFF00E5FF).withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3.0);
      canvas.drawOval(Rect.fromCenter(center: Offset(cx, 85), width: w * 0.75, height: 10), neonRing);
      canvas.drawOval(Rect.fromCenter(center: Offset(cx, 160), width: w * 0.72, height: 10), neonRing);
    } else if (skinId == 'magic_potion') {
      final starPaint = Paint()
        ..color = const Color(0xFFFFD700).withValues(alpha: 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      final double sy = h * 0.58;
      canvas.drawCircle(Offset(cx, sy), 8.0, starPaint);
      canvas.drawLine(Offset(cx - 12, sy), Offset(cx + 12, sy), starPaint);
      canvas.drawLine(Offset(cx, sy - 12), Offset(cx, sy + 12), starPaint);
    } else if (skinId == 'juice_bottle') {
      final ridgePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4;
      canvas.drawLine(Offset(cx - 10, 85), Offset(cx - 10, h - 30), ridgePaint);
      canvas.drawLine(Offset(cx + 10, 85), Offset(cx + 10, h - 30), ridgePaint);
    } else if (skinId == 'crystal') {
      final Paint facetPaint = Paint()
        ..color = const Color(0xFFE879F9).withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawLine(Offset(w * 0.16, 95), Offset(cx, 115), facetPaint);
      canvas.drawLine(Offset(w * 0.84, 95), Offset(cx, 115), facetPaint);
      canvas.drawLine(Offset(w * 0.16, 165), Offset(cx, 185), facetPaint);
      canvas.drawLine(Offset(w * 0.84, 165), Offset(cx, 185), facetPaint);
    }
  }

  /// Draw 3D sculpted glass mouth rim with inner hollow depth
  void _drawGlassMouthRim(Canvas canvas, double cx, double w) {
    final double rimW = w * 0.54;
    final double rimH = 11.0;
    final Rect rimOuter = Rect.fromCenter(center: Offset(cx, 13.5), width: rimW, height: rimH);
    final Rect rimInner = Rect.fromCenter(center: Offset(cx, 12.8), width: rimW * 0.70, height: rimH * 0.60);

    final Paint rimBevel = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.95),
          _getSkinAccentColor().withValues(alpha: 0.50),
          Colors.white.withValues(alpha: 0.65),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rimOuter);
    canvas.drawOval(rimOuter, rimBevel);

    final Paint mouthHole = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.black.withValues(alpha: 0.70),
          const Color(0xFF0F172A).withValues(alpha: 0.30),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rimInner);
    canvas.drawOval(rimInner, mouthHole);

    final Path frontGlint = Path();
    frontGlint.arcTo(rimOuter, 0.15 * pi, 0.70 * pi, false);
    final Paint frontGlintPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(frontGlint, frontGlintPaint);

    final Paint innerRimGleam = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawOval(rimInner, innerRimGleam);
  }

  Color _getSkinGlassColor() {
    switch (skinId) {
      case 'neon':
        return const Color(0xFF00F0FF);
      case 'magic_potion':
        return const Color(0xFFFFD700);
      case 'juice_bottle':
        return const Color(0xFF38BDF8);
      case 'flask':
        return const Color(0xFF00F0FF);
      case 'crystal':
        return const Color(0xFFA855F7);
      case 'classic':
      default:
        return Colors.white;
    }
  }

  Color _getSkinAccentColor() {
    switch (skinId) {
      case 'neon':
        return const Color(0xFF818CF8);
      case 'magic_potion':
        return const Color(0xFFF59E0B);
      case 'juice_bottle':
        return const Color(0xFF0284C7);
      case 'flask':
        return const Color(0xFF00F0FF);
      case 'crystal':
        return const Color(0xFFE879F9);
      case 'classic':
      default:
        return const Color(0xFF00F0FF);
    }
  }

  double _getChamberHalfWidthAtY(double w, double y) {
    if (skinId == 'magic_potion') {
      if (y < 56.0) return w * 0.19;
      final double progress = ((y - 56.0) / 100.0).clamp(0.0, 1.0);
      return w * (0.19 + (sin(progress * pi) * 0.28));
    } else if (skinId == 'conical_flask' || skinId == 'flask') {
      if (y < 58.0) return w * 0.20;
      final t = ((y - 58.0) / 110.0).clamp(0.0, 1.0);
      return lerpDouble(w * 0.20, w * 0.46, t)!;
    } else {
      if (y < 46.0) {
        return w * 0.22;
      } else if (y < 78.0) {
        final t = (y - 46.0) / 32.0;
        return lerpDouble(w * 0.22, w * 0.44, t)!;
      } else if (y < 140.0) {
        final t = (y - 78.0) / 62.0;
        return lerpDouble(w * 0.44, w * 0.40, t)!;
      } else {
        return w * 0.44;
      }
    }
  }

  double? lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }

  @override
  bool shouldRepaint(covariant Bottle3DPainter oldDelegate) {
    return oldDelegate.bubblePhase != bubblePhase ||
        oldDelegate.surfaceWobble != surfaceWobble ||
        oldDelegate.tiltAngle != tiltAngle ||
        oldDelegate.drainUnits != drainUnits ||
        oldDelegate.incomingUnits != incomingUnits ||
        oldDelegate.incomingColor != incomingColor ||
        oldDelegate.isSelected != isSelected ||
        oldDelegate.isSolved != isSolved ||
        oldDelegate.skinId != skinId ||
        oldDelegate.layers != layers ||
        oldDelegate.hiddenCount != hiddenCount;
  }
}
