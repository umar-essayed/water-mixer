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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Action Bar (Coins, Shop, Settings)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Coin balance badge (Glass Gold Pill)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.accentGold, width: 2.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.string(AppAssets.coinSvg, width: 24, height: 24),
                          const SizedBox(width: 8),
                          Text(
                            '${game.coins}',
                            style: const TextStyle(
                              color: Color(0xFFFBBF24),
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Shop and Settings 2D Buttons
                    Row(
                      children: [
                        SvgIconButton(
                          svgString: AppAssets.shopSvg,
                          size: 48,
                          iconSize: 24,
                          baseColor: const Color(0xFF0284C7),
                          shadowColor: const Color(0xFF0369A1),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const ShopScreen()),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        SvgIconButton(
                          svgString: AppAssets.settingsSvg,
                          size: 48,
                          iconSize: 24,
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

                // Center Hero: Mascot & WATER MIXAR Glassmorphism Title Card
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Mascot with ambient glow
                    SvgPicture.string(
                      AppAssets.dropletLogoSvg,
                      width: 130,
                      height: 160,
                    ),
                    const SizedBox(height: 18),

                    // Harmonious Dark Glassmorphism Title Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.82),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.75),
                          width: 2.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 6),
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
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B).withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFF818CF8).withValues(alpha: 0.5),
                              ),
                            ),
                            child: const Text(
                              'COLOR SORT LAB',
                              style: TextStyle(
                                color: Color(0xFF38BDF8),
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Bottom Action Buttons: Wide, Chunky, Cheerful 2D Game Buttons
                Column(
                  children: [
                    // Big Play / Resume Button (Juicy Green/Cyan 2D Button)
                    CustomButton(
                      text: 'بدء اللعب (المستوى ${game.maxUnlockedLevel})',
                      icon: Icons.play_arrow_rounded,
                      height: 64,
                      fontSize: 22,
                      baseColor: const Color(0xFF22C55E),
                      shadowColor: const Color(0xFF15803D),
                      onPressed: () {
                        game.loadLevel(game.maxUnlockedLevel);
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const GameScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 14),

                    // Level Map Adventure Button (Wide Sunny Amber 2D Button)
                    CustomButton(
                      text: 'خريطة المغامرة 🗺️',
                      icon: Icons.map_rounded,
                      height: 54,
                      fontSize: 18,
                      baseColor: const Color(0xFFF59E0B),
                      shadowColor: const Color(0xFFB45309),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LevelMapScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Two-Column Actions: Endless Flood Survival & Lab Renovation
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'طور الطوفان 🌊',
                            height: 50,
                            fontSize: 15,
                            baseColor: const Color(0xFF0284C7),
                            shadowColor: const Color(0xFF0369A1),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const SurvivalScreen()),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            text: 'تطوير المعمل 🧪',
                            height: 50,
                            fontSize: 15,
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
                    const SizedBox(height: 10),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
