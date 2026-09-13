import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/persistence_manager.dart';
import '../../providers/game_provider.dart';
import '../../widgets/svg_icon_button.dart';
import '../game/game_screen.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final maxUnlocked = game.maxUnlockedLevel;
    const totalLevels = 40;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.homeBackground),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back Button
                    SvgIconButton(
                      svgString: '''
<svg width="32" height="32" viewBox="0 0 32 32" fill="none">
  <path d="M 20 8 L 10 16 L 20 24" stroke="#FFFFFF" stroke-width="4.5" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''',
                      size: 46,
                      iconSize: 22,
                      baseColor: const Color(0xFF64748B),
                      shadowColor: const Color(0xFF334155),
                      onTap: () => Navigator.of(context).pop(),
                    ),

                    // Title
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF0284C7), width: 2.5),
                      ),
                      child: const Text(
                        'اختيار المستوى',
                        style: TextStyle(
                          color: Color(0xFF0369A1),
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),

                    // Total Stars Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.accentGold, width: 2.2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.string(AppAssets.starFilledSvg, width: 22, height: 22),
                          const SizedBox(width: 6),
                          Text(
                            '${PersistenceManager.getTotalEarnedStars()}',
                            style: const TextStyle(
                              color: Color(0xFFB45309),
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Level Grid (4 columns) with Chunky 2D Candy Tiles
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.88,
                  ),
                  itemCount: totalLevels,
                  itemBuilder: (context, index) {
                    final levelNum = index + 1;
                    final isUnlocked = levelNum <= maxUnlocked;
                    final isCompleted = levelNum < maxUnlocked;
                    final stars = PersistenceManager.getLevelStars(levelNum);

                    return GestureDetector(
                      onTap: isUnlocked
                          ? () {
                              game.loadLevel(levelNum);
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => const GameScreen()),
                              );
                            }
                          : null,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isUnlocked
                              ? (isCompleted
                                  ? const Color(0xFF00B4D8) // Cyan for completed
                                  : const Color(0xFF22C55E)) // Green for current
                              : const Color(0xFF94A3B8).withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white,
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isUnlocked
                                  ? (isCompleted ? const Color(0xFF0077B6) : const Color(0xFF15803D))
                                  : const Color(0xFF475569),
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!isUnlocked)
                              SvgPicture.string(AppAssets.lockSvg, width: 28, height: 28)
                            else ...[
                              Text(
                                '$levelNum',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black38,
                                      blurRadius: 2,
                                      offset: Offset(0, 1.5),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(3, (starIdx) {
                                  final earned = isCompleted || starIdx < stars;
                                  return SvgPicture.string(
                                    earned ? AppAssets.starFilledSvg : AppAssets.starEmptySvg,
                                    width: 14,
                                    height: 14,
                                  );
                                }),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
