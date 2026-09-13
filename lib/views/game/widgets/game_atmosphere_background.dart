import 'dart:math';
import 'package:flutter/material.dart';

/// Atmospheric Rich Game Environment Background
/// Replaces plain gradients with an immersive, cozy laboratory / alchemy setting:
/// - Perspective table countertop where tubes rest
/// - Subtle background glass shelves with out-of-focus bokeh flasks
/// - Gentle volumetric ambient light beams (God rays)
/// - Floating luminous dust motes & magical sparkles
enum GameTheme {
  neonLab,     // مختبر كيميائي حديث: زرقة ليلية، إضاءة سيان، وأنابيب خلفية مضيئة
  sunsetBeach, // شاطئ الغروب: شفق بنفسجي وأمواج دافئة مع إضاءة شمس هادئة
  cosmicNebula,// الفضاء السديمي: سماء أرجوانية مرصعة بالنجوم وشهب ناعمة
  mysticForest,// الغابة الساحرة: زمردي ليلي مع يراعات ضوئية وأغصان ساحرة
}

class GameAtmosphereBackground extends StatefulWidget {
  final Widget? child;
  final GameTheme? overrideTheme;
  final int? levelNumber;

  const GameAtmosphereBackground({
    super.key,
    this.child,
    this.overrideTheme,
    this.levelNumber,
  });

  static GameTheme getThemeForLevel(int level) {
    final cycle = ((level - 1) ~/ 10) % 4;
    switch (cycle) {
      case 0:
        return GameTheme.neonLab;
      case 1:
        return GameTheme.sunsetBeach;
      case 2:
        return GameTheme.cosmicNebula;
      case 3:
      default:
        return GameTheme.mysticForest;
    }
  }

  @override
  State<GameAtmosphereBackground> createState() => _GameAtmosphereBackgroundState();
}

class _GameAtmosphereBackgroundState extends State<GameAtmosphereBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.overrideTheme ??
        (widget.levelNumber != null
            ? GameAtmosphereBackground.getThemeForLevel(widget.levelNumber!)
            : GameTheme.neonLab);

    return Stack(
      children: [
        // 1. Rich Environment Scene Painting
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _particleController,
            builder: (context, _) {
              return CustomPaint(
                painter: _RichScenePainter(
                  theme: theme,
                  timePhase: _particleController.value,
                ),
              );
            },
          ),
        ),

        // 2. Foreground Content
        if (widget.child != null) Positioned.fill(child: widget.child!),
      ],
    );
  }
}

class _RichScenePainter extends CustomPainter {
  final GameTheme theme;
  final double timePhase;

  _RichScenePainter({
    required this.theme,
    required this.timePhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Palette per theme
    final Color topSky;
    final Color midWall;
    final Color bottomFloor;
    final Color tableTop;
    final Color beamColor;
    final Color accentGlow;

    switch (theme) {
      case GameTheme.neonLab:
        topSky = const Color(0xFF070E1E);
        midWall = const Color(0xFF0F1C36);
        bottomFloor = const Color(0xFF081224);
        tableTop = const Color(0xFF142442);
        beamColor = const Color(0xFF00F0FF);
        accentGlow = const Color(0xFF38BDF8);
        break;

      case GameTheme.sunsetBeach:
        topSky = const Color(0xFF1A0B2E);
        midWall = const Color(0xFF2D124D);
        bottomFloor = const Color(0xFF1C0928);
        tableTop = const Color(0xFF3B1854);
        beamColor = const Color(0xFFFF2A6D);
        accentGlow = const Color(0xFFFF9100);
        break;

      case GameTheme.cosmicNebula:
        topSky = const Color(0xFF09041A);
        midWall = const Color(0xFF180D3D);
        bottomFloor = const Color(0xFF070314);
        tableTop = const Color(0xFF22114F);
        beamColor = const Color(0xFF9D00FF);
        accentGlow = const Color(0xFF00E5FF);
        break;

      case GameTheme.mysticForest:
        topSky = const Color(0xFF051412);
        midWall = const Color(0xFF0A2B26);
        bottomFloor = const Color(0xFF041210);
        tableTop = const Color(0xFF113D36);
        beamColor = const Color(0xFF05FFA1);
        accentGlow = const Color(0xFFB4F800);
        break;
    }

    // 1. Base Wall Gradient
    final Rect fullRect = Rect.fromLTWH(0, 0, w, h);
    final Paint wallPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0.0, 0.45, 0.82, 1.0],
        colors: [topSky, midWall, bottomFloor, bottomFloor],
      ).createShader(fullRect);
    canvas.drawRect(fullRect, wallPaint);

    // 2. Soft Ambient Volumetric Light Beams (God rays streaming from top corner)
    _drawVolumetricLightBeams(canvas, w, h, beamColor);

    // 3. Background Laboratory Shelf with Out-of-Focus Bokeh Glassware
    _drawBackgroundGlassShelves(canvas, w, h, tableTop, accentGlow);

    // 4. Perspective Countertop / Laboratory Table Surface (Where the tubes rest)
    _drawPerspectiveTable(canvas, w, h, tableTop, accentGlow);

    // 5. Floating Dust Motes & Magical Sparkles (Animated)
    _drawFloatingAtmosphereMotes(canvas, w, h, accentGlow);

    // 6. Deep Vignette & Ambient Occlusion (Focusing the player's view onto the center puzzle)
    final Paint vignettePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.98,
        stops: const [0.45, 0.78, 1.0],
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.35),
          Colors.black.withValues(alpha: 0.82),
        ],
      ).createShader(fullRect);
    canvas.drawRect(fullRect, vignettePaint);
  }

  /// Volumetric soft light rays coming gently from top
  void _drawVolumetricLightBeams(Canvas canvas, double w, double h, Color beamColor) {
    final Path beam1 = Path()
      ..moveTo(w * 0.10, 0)
      ..lineTo(w * 0.35, 0)
      ..lineTo(w * 0.75, h)
      ..lineTo(w * 0.35, h)
      ..close();

    final Paint beamPaint1 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          beamColor.withValues(alpha: 0.08),
          beamColor.withValues(alpha: 0.02),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(beam1, beamPaint1);

    final Path beam2 = Path()
      ..moveTo(w * 0.65, 0)
      ..lineTo(w * 0.90, 0)
      ..lineTo(w, h * 0.75)
      ..lineTo(w * 0.80, h * 0.75)
      ..close();

    final Paint beamPaint2 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          beamColor.withValues(alpha: 0.06),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(beam2, beamPaint2);
  }

  /// Stylized distant background glass shelf with soft bokeh bottles
  void _drawBackgroundGlassShelves(Canvas canvas, double w, double h, Color wood, Color glow) {
    // Upper Shelf line
    final double shelfY = h * 0.22;
    final Paint shelfPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          wood.withValues(alpha: 0.60),
          Colors.white.withValues(alpha: 0.15),
          wood.withValues(alpha: 0.60),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, shelfY, w, 4))
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(w * 0.08, shelfY), Offset(w * 0.92, shelfY), shelfPaint);

    // Distant Bokeh Bottles on shelf (Soft blurred silhouettes)
    final bottles = [
      {'x': w * 0.16, 'w': 18.0, 'h': 36.0, 'color': const Color(0xFF00F0FF)},
      {'x': w * 0.24, 'w': 22.0, 'h': 42.0, 'color': const Color(0xFFFF2A6D)},
      {'x': w * 0.76, 'w': 24.0, 'h': 44.0, 'color': const Color(0xFF05FFA1)},
      {'x': w * 0.84, 'w': 16.0, 'h': 32.0, 'color': const Color(0xFFFFEA00)},
    ];

    for (final b in bottles) {
      final bx = b['x'] as double;
      final bw = b['w'] as double;
      final bh = b['h'] as double;
      final bColor = b['color'] as Color;
      final by = shelfY - bh;

      // Soft bottle body
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(bx - bw / 2, by, bw, bh),
        const Radius.circular(6),
      );

      final Paint bgBottlePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.07)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
      canvas.drawRRect(rrect, bgBottlePaint);

      // Liquid inside bokeh bottle
      final liquidRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(bx - (bw * 0.8) / 2, by + bh * 0.45, bw * 0.8, bh * 0.52),
        const Radius.circular(4),
      );
      final Paint bgLiquid = Paint()
        ..color = bColor.withValues(alpha: 0.14)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
      canvas.drawRRect(liquidRRect, bgLiquid);
    }
  }

  /// Perspective laboratory table surface where the player's tubes rest
  void _drawPerspectiveTable(Canvas canvas, double w, double h, Color tableColor, Color accent) {
    final double tableTopY = h * 0.84;

    // Tabletop surface perspective polygon
    final Path tablePath = Path()
      ..moveTo(0, tableTopY)
      ..lineTo(w, tableTopY)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    final Paint tableSurfacePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0.0, 0.35, 1.0],
        colors: [
          tableColor.withValues(alpha: 0.85),
          tableColor.withValues(alpha: 0.60),
          Colors.black.withValues(alpha: 0.90),
        ],
      ).createShader(Rect.fromLTWH(0, tableTopY, w, h - tableTopY));
    canvas.drawPath(tablePath, tableSurfacePaint);

    // Polished edge reflection line along table front
    final Paint edgeGlint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          accent.withValues(alpha: 0.40),
          Colors.white.withValues(alpha: 0.60),
          accent.withValues(alpha: 0.40),
          Colors.transparent,
        ],
        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
      ).createShader(Rect.fromLTWH(0, tableTopY, w, 2.0))
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(w * 0.04, tableTopY), Offset(w * 0.96, tableTopY), edgeGlint);

    // Soft reflective bloom beneath the tubes area
    final Rect bloomRect = Rect.fromCenter(
      center: Offset(w / 2, tableTopY + 12.0),
      width: w * 0.75,
      height: 24.0,
    );
    final Paint bloomPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          accent.withValues(alpha: 0.12),
          Colors.transparent,
        ],
      ).createShader(bloomRect);
    canvas.drawOval(bloomRect, bloomPaint);
  }

  /// Floating animated luminous dust particles / magical fireflies
  void _drawFloatingAtmosphereMotes(Canvas canvas, double w, double h, Color glowColor) {
    final Paint motePaint = Paint()..style = PaintingStyle.fill;
    final Paint glowPaint = Paint()..style = PaintingStyle.fill;

    // 14 deterministic particles moving smoothly with timePhase
    for (int i = 0; i < 14; i++) {
      final double seed = (i * 0.14159);
      final double progress = (timePhase + seed) % 1.0;

      // Gently float upwards and drift with sine sway
      final double px = (w * ((i * 0.23 + 0.1) % 0.85)) + sin(progress * 2 * pi + i) * 18.0;
      final double py = (h * 0.82) - (progress * (h * 0.68));

      final double alpha = sin(progress * pi); // Fade in then fade out
      final double radius = 1.4 + (i % 3) * 0.7;

      glowPaint.color = glowColor.withValues(alpha: alpha * 0.25);
      canvas.drawCircle(Offset(px, py), radius * 3.2, glowPaint);

      motePaint.color = Colors.white.withValues(alpha: alpha * 0.75);
      canvas.drawCircle(Offset(px, py), radius, motePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RichScenePainter oldDelegate) {
    return oldDelegate.timePhase != timePhase || oldDelegate.theme != theme;
  }
}
