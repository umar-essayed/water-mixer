import 'dart:math';
import 'package:flutter/material.dart';

/// Ultra-Realistic Volumetric Fluid Pouring Jet with Parabolic Gravity Dynamics,
/// Variable Ribbon Thickness, Internal Caustics, and Ballistic Splash VFX.
class PouringStreamPainter extends CustomPainter {
  final Offset startOffset;
  final Offset endOffset;
  final Color streamColor;
  final double streamWidth;
  final double progress; // 0.0 to 1.0

  PouringStreamPainter({
    required this.startOffset,
    required this.endOffset,
    required this.streamColor,
    this.streamWidth = 20.0,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.02) return;

    final double effectiveProgress = (progress * 1.25).clamp(0.0, 1.0);
    final currentEnd = Offset.lerp(startOffset, endOffset, effectiveProgress)!;

    final bool isFlowingRight = endOffset.dx >= startOffset.dx;

    // 1. Natural Parabolic Gravity Trajectory
    // Water exits the tilted spout horizontally under velocity, then plunges downwards under gravity
    final double dy = currentEnd.dy - startOffset.dy;

    // Arc control points creating fluid arching trajectory
    final Offset control1 = Offset(
      startOffset.dx + (isFlowingRight ? 16.0 : -16.0),
      startOffset.dy + 4.0,
    );
    final Offset control2 = Offset(
      currentEnd.dx + (isFlowingRight ? -6.0 : 6.0),
      startOffset.dy + (dy * 0.45),
    );

    // 2. Build Volumetric Fluid Ribbon (Left edge and Right edge with natural thickness tapering)
    final Path ribbonPath = Path();
    const int segments = 28;
    final List<Offset> leftPoints = [];
    final List<Offset> rightPoints = [];

    for (int i = 0; i <= segments; i++) {
      final double t = (i / segments) * effectiveProgress;
      // Cubic bezier evaluation
      final double u = 1 - t;
      final double tt = t * t;
      final double uu = u * u;
      final double uuu = uu * u;
      final double ttt = tt * t;

      final double px = uuu * startOffset.dx +
          3 * uu * t * control1.dx +
          3 * u * tt * control2.dx +
          ttt * currentEnd.dx;
      final double py = uuu * startOffset.dy +
          3 * uu * t * control1.dy +
          3 * u * tt * control2.dy +
          ttt * currentEnd.dy;

      // Dynamic stream thickness: thick at spout (20px), slightly narrower in mid-air (14px), expands at plunge (22px)
      final double localWidth = (streamWidth * (0.85 - (sin(t * pi) * 0.22) + (t * 0.25)))
          .clamp(12.0, 24.0);

      // Normal vector perpendicular to trajectory
      final double tangentX = 3 * uu * (control1.dx - startOffset.dx) +
          6 * u * t * (control2.dx - control1.dx) +
          3 * tt * (currentEnd.dx - control2.dx);
      final double tangentY = 3 * uu * (control1.dy - startOffset.dy) +
          6 * u * t * (control2.dy - control1.dy) +
          3 * tt * (currentEnd.dy - control2.dy);

      final double len = sqrt(tangentX * tangentX + tangentY * tangentY);
      final double nx = len > 0.001 ? -tangentY / len : 0.0;
      final double ny = len > 0.001 ? tangentX / len : 1.0;

      final double halfW = localWidth / 2;
      leftPoints.add(Offset(px + nx * halfW, py + ny * halfW));
      rightPoints.add(Offset(px - nx * halfW, py - ny * halfW));
    }

    if (leftPoints.isNotEmpty) {
      ribbonPath.moveTo(leftPoints.first.dx, leftPoints.first.dy);
      for (int i = 1; i < leftPoints.length; i++) {
        ribbonPath.lineTo(leftPoints[i].dx, leftPoints[i].dy);
      }
      for (int i = rightPoints.length - 1; i >= 0; i--) {
        ribbonPath.lineTo(rightPoints[i].dx, rightPoints[i].dy);
      }
      ribbonPath.close();

      // A. Soft Luminous Ambient Fluid Glow
      final Paint glowPaint = Paint()
        ..color = streamColor.withValues(alpha: 0.32)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
      canvas.drawPath(ribbonPath, glowPaint);

      // B. Saturated Volumetric Liquid Ribbon Body (3D Cylindrical Water Gradient)
      final Rect streamBounds = Rect.fromPoints(startOffset, currentEnd);
      final Color lightEdge = Color.lerp(streamColor, Colors.white, 0.45)!;
      final Color darkEdge = Color.lerp(streamColor, Colors.black, 0.35)!;

      final Paint bodyPaint = Paint()
        ..shader = LinearGradient(
          begin: isFlowingRight ? Alignment.topLeft : Alignment.topRight,
          end: isFlowingRight ? Alignment.bottomRight : Alignment.bottomLeft,
          stops: const [0.0, 0.28, 0.70, 1.0],
          colors: [
            lightEdge.withValues(alpha: 0.98),
            streamColor,
            streamColor.withValues(alpha: 0.92),
            darkEdge,
          ],
        ).createShader(streamBounds)
        ..style = PaintingStyle.fill;
      canvas.drawPath(ribbonPath, bodyPaint);

      // C. Internal Glistening Water Highlight Spine (Specular Refraction Streak)
      final Path spinePath = Path();
      for (int i = 0; i < leftPoints.length; i++) {
        // Offset 30% from the upper/outer edge of the fluid jet
        final Offset p = Offset.lerp(leftPoints[i], rightPoints[i], 0.28)!;
        if (i == 0) {
          spinePath.moveTo(p.dx, p.dy);
        } else {
          spinePath.lineTo(p.dx, p.dy);
        }
      }
      final Paint spinePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(spinePath, spinePaint);

      // Secondary fine reflection streak
      final Path subSpine = Path();
      for (int i = 0; i < leftPoints.length; i++) {
        final Offset p = Offset.lerp(leftPoints[i], rightPoints[i], 0.75)!;
        if (i == 0) {
          subSpine.moveTo(p.dx, p.dy);
        } else {
          subSpine.lineTo(p.dx, p.dy);
        }
      }
      final Paint subPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(subSpine, subPaint);
    }

    // 3. Spout Fluid Drops (Droplets dripping naturally from the source lip)
    final double dripProgress = ((progress * 3.0) % 1.0);
    final double dripX = startOffset.dx + (isFlowingRight ? 3.0 : -3.0);
    final double dripY = startOffset.dy + (dripProgress * 16.0);
    final Paint dropPaint = Paint()
      ..color = streamColor.withValues(alpha: 0.90)
      ..style = PaintingStyle.fill;
    final Paint gleamPaint = Paint()..color = Colors.white;

    canvas.drawCircle(Offset(dripX, dripY), 2.2 * (1.0 - dripProgress * 0.3), dropPaint);
    canvas.drawCircle(Offset(dripX - 0.6, dripY - 0.6), 0.9, gleamPaint);

    // 4. Explosive 3D Splash Crown, Foam & Ballistic Droplets at Contact Point
    if (progress >= 0.28) {
      final double splashProgress = ((progress - 0.28) / 0.72).clamp(0.0, 1.0);

      // A. Multi-Tier Concentric 3D Expanding Ripples (Foreshortened)
      for (int tier = 0; tier < 3; tier++) {
        final tierProgress = ((splashProgress * 1.5) - (tier * 0.25)).clamp(0.0, 1.0);
        if (tierProgress > 0.05) {
          final double ripW = (streamWidth * (2.8 + tier * 1.8)) * tierProgress;
          final double ripH = ripW * 0.35;
          final Rect ripRect = Rect.fromCenter(center: endOffset, width: ripW, height: ripH);
          final Paint ripPaint = Paint()
            ..color = streamColor.withValues(alpha: ((1.0 - tierProgress) * 0.70).clamp(0.0, 1.0))
            ..style = PaintingStyle.stroke
            ..strokeWidth = (2.4 - tier * 0.4).clamp(1.0, 3.2);
          canvas.drawOval(ripRect, ripPaint);
        }
      }

      // B. Splash Corona Crown (Water spikes erupting around contact)
      final Path crownPath = Path();
      final double crownRadius = streamWidth * 1.8;
      const int crownSpikes = 8;
      final double crownH = 16.0 * sin(splashProgress * pi);

      for (int s = 0; s <= crownSpikes; s++) {
        final double angle = (s / crownSpikes) * pi;
        final double cxPoint = endOffset.dx + cos(angle) * crownRadius;
        final double cyPoint = endOffset.dy + sin(angle) * (crownRadius * 0.35);
        final double peakX = cxPoint + (cos(angle) * 3.0);
        final double peakY = cyPoint - crownH * (0.65 + 0.35 * sin(s * 2.8));

        if (s == 0) {
          crownPath.moveTo(cxPoint, cyPoint);
        } else {
          crownPath.quadraticBezierTo(peakX, peakY, cxPoint, cyPoint);
        }
      }
      final Paint crownPaint = Paint()
        ..color = streamColor.withValues(alpha: 0.90)
        ..style = PaintingStyle.fill;
      canvas.drawPath(crownPath, crownPaint);

      // C. Active Foamy Froth Core at Contact Center
      final Rect foamRect = Rect.fromCenter(
        center: endOffset,
        width: streamWidth * 1.6,
        height: streamWidth * 0.60,
      );
      final Paint foamPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.92)
        ..style = PaintingStyle.fill;
      canvas.drawOval(foamRect, foamPaint);

      // D. Ballistic Flying Droplets with Gravity Acceleration
      final dropletData = [
        [0.18, 28.0, 1.2, 3.4],
        [0.38, 38.0, 1.4, 4.2],
        [0.58, 44.0, 1.6, 3.8],
        [0.82, 48.0, 1.7, 4.4],
        [1.08, 42.0, 1.5, 4.0],
        [1.28, 46.0, 1.6, 4.5],
        [1.48, 36.0, 1.4, 3.6],
        [1.72, 32.0, 1.3, 3.8],
        [1.92, 24.0, 1.1, 3.0],
      ];

      for (int i = 0; i < dropletData.length; i++) {
        final dAngle = dropletData[i][0];
        final dDistMax = dropletData[i][1];
        final dSpeed = dropletData[i][2];
        final dRadius = dropletData[i][3];

        final double currentBurst = sin((splashProgress * dSpeed).clamp(0.0, 1.0) * pi);
        final double gravityDrop = pow(splashProgress, 1.8) * 18.0;

        final double px = endOffset.dx + cos(dAngle * pi) * (dDistMax * currentBurst);
        final double py = endOffset.dy - sin(dAngle * pi) * (dDistMax * 0.9 * currentBurst) + gravityDrop;

        final double r = dRadius * (1.0 - splashProgress * 0.30);
        if (r > 0.8) {
          canvas.drawCircle(Offset(px, py), r, dropPaint);
          canvas.drawCircle(Offset(px - r * 0.3, py - r * 0.3), r * 0.42, gleamPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant PouringStreamPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.startOffset != startOffset ||
        oldDelegate.endOffset != endOffset ||
        oldDelegate.streamColor != streamColor ||
        oldDelegate.streamWidth != streamWidth;
  }
}

class PouringStreamWidget extends StatelessWidget {
  final Offset start;
  final Offset end;
  final Color color;
  final double progress;
  final double streamWidth;

  const PouringStreamWidget({
    super.key,
    required this.start,
    required this.end,
    required this.color,
    required this.progress,
    this.streamWidth = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: PouringStreamPainter(
            startOffset: start,
            endOffset: end,
            streamColor: color,
            streamWidth: streamWidth,
            progress: progress,
          ),
        ),
      ),
    );
  }
}
