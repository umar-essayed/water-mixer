import 'dart:math';
import 'package:flutter/material.dart';

/// 3D Realistic Wooden Cork Stopper with Pop Entrance Animation & Sparkling Confetti Burst
/// Accurately sits ON TOP of the bottle rim without ever falling inside!
class TubeSolvedVfx extends StatefulWidget {
  final bool isSolved;
  final double tubeWidth;
  final double tubeHeight;
  final Color fluidColor;

  const TubeSolvedVfx({
    super.key,
    required this.isSolved,
    required this.tubeWidth,
    required this.tubeHeight,
    required this.fluidColor,
  });

  @override
  State<TubeSolvedVfx> createState() => _TubeSolvedVfxState();
}

class _TubeSolvedVfxState extends State<TubeSolvedVfx> with TickerProviderStateMixin {
  late AnimationController _corkController;
  late Animation<double> _corkDropAnimation;

  late AnimationController _sparkleController;
  final List<_SparkleParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // 1. Cork stopper drop-in bounce animation
    _corkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _corkDropAnimation = CurvedAnimation(
      parent: _corkController,
      curve: Curves.bounceOut,
    );

    // 2. Confetti & Sparkles burst controller
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    _initParticles();

    if (widget.isSolved) {
      _corkController.forward();
      _sparkleController.forward();
    }
  }

  void _initParticles() {
    _particles.clear();
    for (int i = 0; i < 20; i++) {
      final angle = -pi * 0.15 - (_random.nextDouble() * pi * 0.70); // Upward cone
      final speed = 45.0 + _random.nextDouble() * 85.0;
      final size = 3.5 + _random.nextDouble() * 4.5;
      final isStar = i % 3 == 0;
      final color = i % 2 == 0
          ? const Color(0xFFFFD700)
          : (i % 4 == 1 ? widget.fluidColor : Colors.white);

      _particles.add(
        _SparkleParticle(
          vx: cos(angle) * speed,
          vy: sin(angle) * speed,
          size: size,
          isStar: isStar,
          color: color,
          rotationSpeed: (_random.nextDouble() - 0.5) * 8.0,
        ),
      );
    }
  }

  @override
  void didUpdateWidget(covariant TubeSolvedVfx oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSolved && !oldWidget.isSolved) {
      _initParticles();
      _corkController.forward(from: 0.0);
      _sparkleController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _corkController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isSolved) return const SizedBox.shrink();

    final cx = widget.tubeWidth / 2;
    // Cork width is wider than mouth opening to seal it from above
    final corkW = widget.tubeWidth * 0.44;
    final corkLeft = (widget.tubeWidth - corkW) / 2;

    return SizedBox(
      width: widget.tubeWidth,
      height: widget.tubeHeight,
      child: IgnorePointer(
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // 1. Confetti & Sparkles Eruption Canvas
            AnimatedBuilder(
              animation: _sparkleController,
              builder: (context, _) {
                if (_sparkleController.value <= 0.01 || _sparkleController.value >= 0.99) {
                  return const SizedBox.shrink();
                }
                return CustomPaint(
                  size: Size(widget.tubeWidth, widget.tubeHeight),
                  painter: _SparklesPainter(
                    particles: _particles,
                    progress: _sparkleController.value,
                    origin: Offset(cx, 10.0),
                  ),
                );
              },
            ),

            // 2. Realistic 3D Wooden Cork Stopper Plugging Mouth
            // Drops down from above and firmly rests permanently right on top of the rim!
            AnimatedBuilder(
              animation: _corkDropAnimation,
              builder: (context, _) {
                final double t = _corkDropAnimation.value;
                // Resting position: -2.0 places the cork cap shoulder precisely on top of the rim at y=8.0
                const double restingCorkY = -2.0;
                const double startCorkY = -48.0;
                final double corkY = startCorkY + (t * (restingCorkY - startCorkY));

                return Positioned(
                  top: corkY,
                  left: corkLeft,
                  width: corkW,
                  height: 22.0,
                  child: CustomPaint(
                    size: Size(corkW, 22.0),
                    painter: _CorkStopperPainter(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SparkleParticle {
  final double vx;
  final double vy;
  final double size;
  final bool isStar;
  final Color color;
  final double rotationSpeed;

  _SparkleParticle({
    required this.vx,
    required this.vy,
    required this.size,
    required this.isStar,
    required this.color,
    required this.rotationSpeed,
  });
}

class _SparklesPainter extends CustomPainter {
  final List<_SparkleParticle> particles;
  final double progress;
  final Offset origin;

  _SparklesPainter({
    required this.particles,
    required this.progress,
    required this.origin,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double alpha = (1.0 - progress).clamp(0.0, 1.0);
    final double gravity = progress * progress * 85.0;

    for (final p in particles) {
      final double x = origin.dx + p.vx * (progress * 0.85);
      final double y = origin.dy + (p.vy * progress) + gravity;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * p.rotationSpeed);

      final paint = Paint()
        ..color = p.color.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      if (p.isStar) {
        // Draw 4-point star sparkle
        final starPath = Path();
        final s = p.size * (1.0 - progress * 0.3);
        starPath.moveTo(0, -s);
        starPath.quadraticBezierTo(0, 0, s, 0);
        starPath.quadraticBezierTo(0, 0, 0, s);
        starPath.quadraticBezierTo(0, 0, -s, 0);
        starPath.quadraticBezierTo(0, 0, 0, -s);
        starPath.close();
        canvas.drawPath(starPath, paint);

        final gleam = Paint()..color = Colors.white.withValues(alpha: alpha);
        canvas.drawCircle(Offset.zero, s * 0.35, gleam);
      } else {
        canvas.drawCircle(Offset.zero, p.size * (1.0 - progress * 0.4), paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _SparklesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Realistic 3D Carved Wooden Cork Painter with Mushroom Crown Cap
class _CorkStopperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Cork shape:
    // 1. Upper Mushroom Crown (Cap): sits wide over the lip (y: 2 to 10)
    // 2. Lower Tapered Plug: inserts tightly into the neck cavity (y: 10 to 19)
    final Path corkPath = Path();
    // Top cap left
    corkPath.moveTo(0, 4.0);
    corkPath.quadraticBezierTo(w * 0.5, 0.0, w, 4.0);
    corkPath.lineTo(w * 0.98, 9.5);
    // Inset step to plug
    corkPath.lineTo(w * 0.82, 10.0);
    // Tapered plug down
    corkPath.lineTo(w * 0.76, h - 3.0);
    // Rounded bottom plug tip
    corkPath.quadraticBezierTo(w * 0.5, h + 1.0, w * 0.24, h - 3.0);
    corkPath.lineTo(w * 0.18, 10.0);
    // Step out to left cap edge
    corkPath.lineTo(w * 0.02, 9.5);
    corkPath.close();

    // 1. Warm natural cork / oak wood gradient
    final Rect corkRect = Rect.fromLTWH(0, 0, w, h);
    final Paint corkPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        stops: const [0.0, 0.20, 0.55, 0.85, 1.0],
        colors: [
          const Color(0xFF784518), // Deep wood shadow
          const Color(0xFFB87842), // Rich oak
          const Color(0xFFDF9E67), // Golden front highlight
          const Color(0xFFB87842), // Mid grain
          const Color(0xFF5E320D), // Edge rim shadow
        ],
      ).createShader(corkRect);
    canvas.drawPath(corkPath, corkPaint);

    // 2. Natural Wood Grain Texture Lines
    final Paint grainPaint = Paint()
      ..color = const Color(0xFF4A2508).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    canvas.drawLine(Offset(w * 0.08, 6.0), Offset(w * 0.92, 6.0), grainPaint);
    canvas.drawLine(Offset(w * 0.24, 12.5), Offset(w * 0.76, 12.5), grainPaint);
    canvas.drawLine(Offset(w * 0.28, 16.0), Offset(w * 0.72, 16.0), grainPaint);

    // 3. Top Head Lip Bevel (Elliptical Wooden Cap)
    final Rect topOval = Rect.fromCenter(center: Offset(w / 2, 4.0), width: w * 0.96, height: 6.0);
    final Paint topOvalPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFF2C296),
          const Color(0xFFB87842),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(topOval);
    canvas.drawOval(topOval, topOvalPaint);

    // 4. Overhang Shadow under the Cap (Where cap rests on bottle lip)
    final Rect overhangRect = Rect.fromLTWH(w * 0.14, 9.0, w * 0.72, 3.0);
    final Paint shadowPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.black.withValues(alpha: 0.40), Colors.transparent],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(overhangRect);
    canvas.drawRect(overhangRect, shadowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
