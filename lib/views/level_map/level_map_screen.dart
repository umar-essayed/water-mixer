import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_assets.dart';
import '../../core/utils/persistence_manager.dart';
import '../../providers/game_provider.dart';
import '../../widgets/svg_icon_button.dart';
import '../game/game_screen.dart';
import '../game/widgets/game_atmosphere_background.dart';

class LevelMapScreen extends StatefulWidget {
  const LevelMapScreen({super.key});

  @override
  State<LevelMapScreen> createState() => _LevelMapScreenState();
}

class _LevelMapScreenState extends State<LevelMapScreen> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _pulseController;
  late Animation<double> _pulseScale;

  static const int totalLevels = 50;
  static const double nodeSpacing = 110.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 0.94, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Auto-scroll to current active level after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final current = context.read<GameProvider>().maxUnlockedLevel;
      final targetOffset = ((current - 1) * nodeSpacing) - 200;
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final maxUnlocked = game.maxUnlockedLevel;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: GameAtmosphereBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    // Back Button
                    SvgIconButton(
                      svgString: '''
<svg width="32" height="32" viewBox="0 0 32 32" fill="none">
  <path d="M 20 8 L 10 16 L 20 24" stroke="#FFFFFF" stroke-width="4.5" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''',
                      size: 44,
                      iconSize: 22,
                      baseColor: const Color(0xFF334155),
                      shadowColor: const Color(0xFF1E293B),
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 10),

                    // Map Title Banner
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF38BDF8), width: 1.6),
                        ),
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'خريطة المغامرة 🗺️',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Total Stars Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFF59E0B), width: 1.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.string(AppAssets.starFilledSvg, width: 20, height: 20),
                          const SizedBox(width: 6),
                          Text(
                            '${PersistenceManager.getTotalEarnedStars()} / 150',
                            style: const TextStyle(
                              color: Color(0xFFFBBF24),
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Winding Adventure Map Scrollable View
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: SizedBox(
                    width: screenWidth,
                    height: totalLevels * nodeSpacing + 120,
                    child: Stack(
                      children: [
                        // 1. Winding Road Path Painter
                        CustomPaint(
                          size: Size(screenWidth, totalLevels * nodeSpacing + 120),
                          painter: _MapPathPainter(
                            totalLevels: totalLevels,
                            nodeSpacing: nodeSpacing,
                            maxUnlocked: maxUnlocked,
                          ),
                        ),

                        // 2. Interactive Level Stepping Nodes
                        for (int i = 0; i < totalLevels; i++) ...[
                          _buildLevelNode(
                            levelNum: i + 1,
                            index: i,
                            screenWidth: screenWidth,
                            maxUnlocked: maxUnlocked,
                            game: game,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelNode({
    required int levelNum,
    required int index,
    required double screenWidth,
    required int maxUnlocked,
    required GameProvider game,
  }) {
    final bool isCompleted = levelNum < maxUnlocked;
    final bool isCurrent = levelNum == maxUnlocked;
    final bool isLocked = levelNum > maxUnlocked;
    final int stars = PersistenceManager.getLevelStars(levelNum);

    // Calculate position along winding sine curve
    final double midX = screenWidth / 2;
    final double xOffset = sin(index * 0.75) * (screenWidth * 0.28);
    final double nodeX = midX + xOffset - 36;
    final double nodeY = index * nodeSpacing + 20;

    return Positioned(
      left: nodeX,
      top: nodeY,
      child: GestureDetector(
        onTap: !isLocked
            ? () {
                game.loadLevel(levelNum);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const GameScreen()),
                );
              }
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Current Level "العب الآن" Pin
            if (isCurrent)
              ScaleTransition(
                scale: _pulseScale,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Text(
                    'العب هنا! 🎯',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),

            // Stepping Stone Button
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? const Color(0xFF22C55E) // Green for completed
                    : (isCurrent
                        ? const Color(0xFF00B4D8) // Cyan for current
                        : const Color(0xFF94A3B8)), // Slate for locked
                border: Border.all(
                  color: Colors.white,
                  width: isCurrent ? 3.5 : 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isCompleted
                        ? const Color(0xFF15803D)
                        : (isCurrent ? const Color(0xFF0077B6) : const Color(0xFF475569)),
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Top Shine
                  Positioned(
                    top: 4,
                    child: Container(
                      width: 44,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  // Node Icon / Level Number
                  if (isLocked)
                    SvgPicture.string(AppAssets.lockSvg, width: 28, height: 28)
                  else
                    Text(
                      '$levelNum',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          Shadow(color: Colors.black38, blurRadius: 2, offset: Offset(0, 1.5)),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // 3 Stars Under Node
            if (isCompleted || isCurrent)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (starIdx) {
                    final earned = isCompleted || starIdx < stars;
                    return SvgPicture.string(
                      earned ? AppAssets.starFilledSvg : AppAssets.starEmptySvg,
                      width: 14,
                      height: 14,
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// CustomPainter drawing the winding paved trail between level nodes
class _MapPathPainter extends CustomPainter {
  final int totalLevels;
  final double nodeSpacing;
  final int maxUnlocked;

  _MapPathPainter({
    required this.totalLevels,
    required this.nodeSpacing,
    required this.maxUnlocked,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double midX = size.width / 2;

    // Build the serpentine path
    final path = Path();
    for (int i = 0; i < totalLevels; i++) {
      final double xOffset = sin(i * 0.75) * (size.width * 0.28);
      final double nodeCenterX = midX + xOffset;
      final double nodeCenterY = i * nodeSpacing + 56;

      if (i == 0) {
        path.moveTo(nodeCenterX, nodeCenterY);
      } else {
        final double prevXOffset = sin((i - 1) * 0.75) * (size.width * 0.28);
        final double prevX = midX + prevXOffset;
        final double prevY = (i - 1) * nodeSpacing + 56;

        final double controlX = (prevX + nodeCenterX) / 2;
        final double controlY = (prevY + nodeCenterY) / 2;

        path.quadraticBezierTo(controlX, controlY, nodeCenterX, nodeCenterY);
      }
    }

    // Outer stone road border
    final roadBorderPaint = Paint()
      ..color = const Color(0xFFD97706).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, roadBorderPaint);

    // Inner bright stepping stone trail
    final roadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, roadPaint);

    // Dashed center line
    final dashPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Draw little stepping dots
    for (int i = 0; i < totalLevels * 4; i++) {
      final double t = i / (totalLevels * 4);
      final double y = t * (totalLevels * nodeSpacing);
      final double x = midX + sin((y / nodeSpacing) * 0.75) * (size.width * 0.28);
      canvas.drawCircle(Offset(x, y + 56), 2.5, dashPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MapPathPainter oldDelegate) {
    return oldDelegate.maxUnlocked != maxUnlocked;
  }
}
