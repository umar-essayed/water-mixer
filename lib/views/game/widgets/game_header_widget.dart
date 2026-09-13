import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_assets.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/svg_icon_button.dart';

class GameHeaderWidget extends StatelessWidget {
  final VoidCallback onSettingsTap;
  final VoidCallback onBackTap;

  const GameHeaderWidget({
    super.key,
    required this.onSettingsTap,
    required this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    final hasTimer = game.timeRemaining != null;
    final hasMoves = game.movesRemaining != null;

    String formatTime(int seconds) {
      final m = (seconds ~/ 60).toString().padLeft(2, '0');
      final s = (seconds % 60).toString().padLeft(2, '0');
      return '$m:$s';
    }

    final isBoss = game.currentLevelModel?.isBossLevel == true;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // Back Button
                SvgIconButton(
                  svgString: '''
<svg width="32" height="32" viewBox="0 0 32 32" fill="none">
  <path d="M 20 8 L 10 16 L 20 24" stroke="#FFFFFF" stroke-width="4.5" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''',
                  size: 40,
                  iconSize: 20,
                  baseColor: const Color(0xFF334155),
                  shadowColor: const Color(0xFF1E293B),
                  onTap: onBackTap,
                ),
                const SizedBox(width: 8),

                // Level Badge (Flexible Center Pill)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isBoss
                            ? const [Color(0xFFDC2626), Color(0xFFB45309)]
                            : const [Color(0xFF0284C7), Color(0xFF0369A1)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isBoss ? const Color(0xFFFBBF24) : const Color(0xFF38BDF8),
                        width: isBoss ? 2.0 : 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isBoss
                              ? const Color(0xFFDC2626).withValues(alpha: 0.5)
                              : const Color(0xFF0284C7).withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        isBoss ? '👑 زعيم ${game.currentLevel}' : 'المستوى ${game.currentLevel}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Coins Counter (Glass Gold Badge)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withValues(alpha: 0.90),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.string(AppAssets.coinSvg, width: 20, height: 20),
                      const SizedBox(width: 5),
                      Text(
                        '${game.coins}',
                        style: const TextStyle(
                          color: Color(0xFFFBBF24),
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Settings Button
                SvgIconButton(
                  svgString: AppAssets.settingsSvg,
                  size: 40,
                  iconSize: 20,
                  baseColor: const Color(0xFF475569),
                  shadowColor: const Color(0xFF334155),
                  onTap: onSettingsTap,
                ),
              ],
            ),

            // Challenge Mode Indicators (Timer & Moves Limit)
            if (hasTimer || hasMoves) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (hasTimer) ...[
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: game.bonusTimePulse
                            ? const Color(0xFF065F46).withValues(alpha: 0.85)
                            : (game.timeRemaining! <= 15
                                ? const Color(0xFFEF4444).withValues(alpha: 0.25)
                                : const Color(0xFF0F172A).withValues(alpha: 0.75)),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: game.bonusTimePulse
                              ? const Color(0xFF34D399)
                              : (game.timeRemaining! <= 15
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF38BDF8).withValues(alpha: 0.6)),
                          width: game.bonusTimePulse ? 2.0 : 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 16,
                            color: game.bonusTimePulse
                                ? const Color(0xFF34D399)
                                : (game.timeRemaining! <= 15 ? const Color(0xFFEF4444) : const Color(0xFF38BDF8)),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            formatTime(game.timeRemaining!),
                            style: TextStyle(
                              color: game.bonusTimePulse
                                  ? const Color(0xFF34D399)
                                  : (game.timeRemaining! <= 15 ? const Color(0xFFEF4444) : Colors.white),
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          if (game.bonusTimePulse) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                '+12s',
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                          if (game.timeFreezes > 0) ...[
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () {
                                game.useTimeFreeze();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('تم تجميد الوقت وإضافة +45 ثانية! ❄️')),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00E5FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '+45s (${game.timeFreezes}❄️)',
                                  style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  if (hasTimer && hasMoves) const SizedBox(width: 12),
                  if (hasMoves) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: game.movesRemaining! <= 5
                            ? const Color(0xFFEF4444).withValues(alpha: 0.25)
                            : const Color(0xFF0F172A).withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: game.movesRemaining! <= 5
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF818CF8).withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.ads_click_rounded,
                            size: 16,
                            color: game.movesRemaining! <= 5 ? const Color(0xFFEF4444) : const Color(0xFF818CF8),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'الحركات: ${game.movesRemaining}',
                            style: TextStyle(
                              color: game.movesRemaining! <= 5 ? const Color(0xFFEF4444) : Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
