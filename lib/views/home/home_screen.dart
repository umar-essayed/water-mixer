import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/game_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/svg_icon_button.dart';
import '../game/game_screen.dart';
import '../level_map/level_map_screen.dart';
import '../settings/settings_dialog.dart';
import '../../core/utils/audio_manager.dart';
import '../shop/shop_screen.dart';
import '../game/widgets/game_atmosphere_background.dart';
import '../survival/survival_screen.dart';
import '../lab/lab_renovation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    AudioManager().startBgm();
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    return Scaffold(
      body: GameAtmosphereBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Top Action Bar (Coins, Shop, Settings)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Coin balance badge (Glass Gold Pill)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A).withValues(alpha: 0.90),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: AppColors.accentGold, width: 1.8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.string(AppAssets.coinSvg, width: 22, height: 22),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${game.coins}',
                                    style: const TextStyle(
                                      color: Color(0xFFFBBF24),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Shop and Settings Buttons
                            Row(
                              children: [
                                SvgIconButton(
                                  svgString: AppAssets.shopSvg,
                                  size: 42,
                                  iconSize: 22,
                                  baseColor: const Color(0xFF0284C7),
                                  shadowColor: const Color(0xFF0369A1),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => const ShopScreen()),
                                    );
                                  },
                                ),
                                const SizedBox(width: 10),
                                SvgIconButton(
                                  svgString: AppAssets.settingsSvg,
                                  size: 42,
                                  iconSize: 22,
                                  baseColor: const Color(0xFF475569),
                                  shadowColor: const Color(0xFF334155),
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => const SettingsDialog(),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Center Hero: Mascot & WATER MIXER Glassmorphism Title Card
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.string(
                                AppAssets.dropletLogoSvg,
                                width: 105,
                                height: 125,
                              ),
                              const SizedBox(height: 12),

                              // Harmonious Dark Glassmorphism Title Card
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: const Color(0xFF38BDF8).withValues(alpha: 0.70),
                                    width: 1.8,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0284C7).withValues(alpha: 0.30),
                                      blurRadius: 16,
                                      spreadRadius: 1,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    ShaderMask(
                                      shaderCallback: (bounds) => const LinearGradient(
                                        colors: [Color(0xFF38BDF8), Color(0xFF818CF8), Color(0xFFF43F5E)],
                                      ).createShader(bounds),
                                      child: const Text(
                                        'WATER MIXER',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 2.0,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1E293B).withValues(alpha: 0.8),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(0xFF818CF8).withValues(alpha: 0.4),
                                        ),
                                      ),
                                      child: const Text(
                                        'COLOR SORT LAB',
                                        style: TextStyle(
                                          color: Color(0xFF38BDF8),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.8,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Bottom Action Buttons
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Big Play / Resume Button
                            CustomButton(
                              text: 'بدء اللعب (المستوى ${game.maxUnlockedLevel})',
                              icon: Icons.play_arrow_rounded,
                              height: 58,
                              fontSize: 19,
                              baseColor: const Color(0xFF22C55E),
                              shadowColor: const Color(0xFF15803D),
                              onPressed: () {
                                game.loadLevel(game.maxUnlockedLevel);
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const GameScreen()),
                                );
                              },
                            ),
                            const SizedBox(height: 10),

                            // Level Map Adventure Button
                            CustomButton(
                              text: 'خريطة المغامرة 🗺️',
                              icon: Icons.map_rounded,
                              height: 48,
                              fontSize: 16,
                              baseColor: const Color(0xFFF59E0B),
                              shadowColor: const Color(0xFFB45309),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const LevelMapScreen()),
                                );
                              },
                            ),
                            const SizedBox(height: 10),

                            // Two-Column Actions: Endless Flood Survival & Lab Renovation
                            Row(
                              children: [
                                Expanded(
                                  child: CustomButton(
                                    text: 'طور الطوفان 🌊',
                                    height: 46,
                                    fontSize: 14,
                                    baseColor: const Color(0xFF0284C7),
                                    shadowColor: const Color(0xFF0369A1),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (_) => const SurvivalScreen()),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: CustomButton(
                                    text: 'تطوير المعمل 🧪',
                                    height: 46,
                                    fontSize: 14,
                                    baseColor: const Color(0xFF8B5CF6),
                                    shadowColor: const Color(0xFF6D28D9),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (_) => const LabRenovationScreen()),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
