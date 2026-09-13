import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/audio_manager.dart';
import '../../core/utils/persistence_manager.dart';
import '../../providers/game_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/svg_icon_button.dart';
import '../game/widgets/game_atmosphere_background.dart';

class LabRenovationScreen extends StatefulWidget {
  const LabRenovationScreen({super.key});

  @override
  State<LabRenovationScreen> createState() => _LabRenovationScreenState();
}

class _LabRenovationScreenState extends State<LabRenovationScreen> {
  late int _microscopeLvl;
  late int _cryoLvl;
  late int _plasmaLvl;
  late int _distillerLvl;

  @override
  void initState() {
    super.initState();
    _loadUpgrades();
  }

  void _loadUpgrades() {
    _microscopeLvl = PersistenceManager.getLabUpgrade('microscope');
    _cryoLvl = PersistenceManager.getLabUpgrade('cryo');
    _plasmaLvl = PersistenceManager.getLabUpgrade('plasma');
    _distillerLvl = PersistenceManager.getLabUpgrade('distiller');
  }

  int _getUpgradeCost(int currentLvl) {
    return currentLvl * 120;
  }

  void _upgrade(String id, int currentLvl, Function(int) onUpdated) {
    final cost = _getUpgradeCost(currentLvl);
    final game = context.read<GameProvider>();
    if (game.coins >= cost && currentLvl < 5) {
      game.addCoins(-cost);
      final newLvl = currentLvl + 1;
      PersistenceManager.setLabUpgrade(id, newLvl);
      AudioManager().playBuy();
      setState(() {
        onUpdated(newLvl);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تمت ترقية المنشأة بنجاح إلى المستوى $newLvl! 🚀'),
          backgroundColor: const Color(0xFF10B981),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      AudioManager().playInvalid();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('عملات غير كافية للترقية! أكمل مستويات لجمع المزيد.'),
          backgroundColor: Color(0xFFEF4444),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final totalLabPoints = _microscopeLvl + _cryoLvl + _plasmaLvl + _distillerLvl;

    return Scaffold(
      body: GameAtmosphereBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SvgIconButton(
                      svgString: '''
<svg width="32" height="32" viewBox="0 0 32 32" fill="none">
  <path d="M 20 8 L 10 16 L 20 24" stroke="#FFFFFF" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''',
                      size: 44,
                      iconSize: 20,
                      baseColor: const Color(0xFF334155),
                      shadowColor: const Color(0xFF1E293B),
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF38BDF8), width: 1.6),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Flexible(
                              child: Text(
                                '🧪 معمل الكيمياء المتطور',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF38BDF8).withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Lvl $totalLabPoints',
                                style: const TextStyle(
                                  color: Color(0xFF38BDF8),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Coins Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.accentGold, width: 1.8),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.string(AppAssets.coinSvg, width: 20, height: 20),
                          const SizedBox(width: 6),
                          Text('${game.coins}',
                              style: const TextStyle(
                                  color: Color(0xFFFBBF24),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Lab Prestige Showcase Banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFF818CF8).withValues(alpha: 0.5), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF818CF8).withValues(alpha: 0.15),
                          border: Border.all(color: const Color(0xFF818CF8), width: 2),
                        ),
                        child: const Center(
                          child: Text('🔬', style: TextStyle(fontSize: 30)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'تطوير وتحديث المعمل',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 17),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'قم بترقية أجهزة المعمل لتكسب مكافآت دائمة، وتزيد وقت التحديات ومضاعفات النقاط!',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Upgrade Cards List
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    _buildUpgradeCard(
                      icon: '🔬',
                      title: 'المجهر الكمومي الذري',
                      description: 'يزيد العملات الذهبية المكتسبة بنسبة +15% لكل مستوى ترقية.',
                      level: _microscopeLvl,
                      accentColor: const Color(0xFF38BDF8),
                      onUpgrade: () => _upgrade('microscope', _microscopeLvl, (lvl) => _microscopeLvl = lvl),
                    ),
                    const SizedBox(height: 12),
                    _buildUpgradeCard(
                      icon: '❄️',
                      title: 'نظام التبريد الفائق (Cryo Cooler)',
                      description: 'يمنح +6 ثوانٍ إضافية في مستويات تحدي الوقت والاندفاع.',
                      level: _cryoLvl,
                      accentColor: const Color(0xFF06B6D4),
                      onUpgrade: () => _upgrade('cryo', _cryoLvl, (lvl) => _cryoLvl = lvl),
                    ),
                    const SizedBox(height: 12),
                    _buildUpgradeCard(
                      icon: '⚡',
                      title: 'مفاعل البلازما النيوني',
                      description: 'يمنح +2 حركات إضافية لتحييد السوائل المتفجرة قبل انطلاقها.',
                      level: _plasmaLvl,
                      accentColor: const Color(0xFFA855F7),
                      onUpgrade: () => _upgrade('plasma', _plasmaLvl, (lvl) => _plasmaLvl = lvl),
                    ),
                    const SizedBox(height: 12),
                    _buildUpgradeCard(
                      icon: '⚗️',
                      title: 'المقطرة الذهبية السحرية',
                      description: 'تزيد فرص ظهور هدايا ومفاتيح مجانية في خريطة المستويات.',
                      level: _distillerLvl,
                      accentColor: const Color(0xFFF59E0B),
                      onUpgrade: () => _upgrade('distiller', _distillerLvl, (lvl) => _distillerLvl = lvl),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpgradeCard({
    required String icon,
    required String title,
    required String description,
    required int level,
    required Color accentColor,
    required VoidCallback onUpgrade,
  }) {
    final isMax = level >= 5;
    final cost = _getUpgradeCost(level);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withValues(alpha: 0.4), width: 1.6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accentColor, width: 1.6),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 15),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isMax ? 'MAX' : 'Lvl $level/5',
                        style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 11),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 11),
                ),
                const SizedBox(height: 10),
                // Upgrade Button
                SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    onPressed: isMax ? null : onUpgrade,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isMax ? Colors.grey[700] : accentColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!isMax) ...[
                          SvgPicture.string(AppAssets.coinSvg, width: 16, height: 16),
                          const SizedBox(width: 6),
                          Text('$cost  -  ترقية للمستوى ${level + 1}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ] else ...[
                          const Text('أقصى مستوى متاح ⭐',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
