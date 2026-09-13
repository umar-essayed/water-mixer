import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/audio_manager.dart';
import '../../providers/game_provider.dart';
import '../../widgets/svg_icon_button.dart';
import '../game/widgets/bottle_3d_painter.dart';
import '../game/widgets/game_atmosphere_background.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    final skins = [
      {
        'id': 'classic',
        'name': 'الأنبوب المعملي',
        'cost': 0,
        'desc': 'زجاج معملي نقي مع لمعات وانعكاسات ضوئية شفافة',
        'svg': AppAssets.tubeFrameSvg,
      },
      {
        'id': 'magic_potion',
        'name': 'القارورة السحرية',
        'cost': 180,
        'desc': 'قارورة جرعات كروية ببطن مستدير ونجمة ذهبية براقة',
        'svg': AppAssets.tubeFrameSvg,
      },
      {
        'id': 'juice_bottle',
        'name': 'زجاجة العصير والصودا',
        'cost': 260,
        'desc': 'زجاجة مشروبات مضلعة مع خصر منحوت وتجاويف كلاسيكية',
        'svg': AppAssets.tubeFrameSvg,
      },
      {
        'id': 'flask',
        'name': 'دورق المعمل المدرج',
        'cost': 350,
        'desc': 'تصميم هرمي كيميائي مع تدريجات قياس دقيقة',
        'svg': AppAssets.tubeFrameFlaskSvg,
      },
      {
        'id': 'neon',
        'name': 'السايبر نيون',
        'cost': 450,
        'desc': 'كبسولة متوهجة بحلقات طاقة نيون فيروزية وبنفسجية',
        'svg': AppAssets.tubeFrameNeonSvg,
      },
      {
        'id': 'crystal',
        'name': 'الماس الكريستالي',
        'cost': 600,
        'desc': 'قطع ألماس منشورى يعكس ألوان الطيف البنفسجية',
        'svg': AppAssets.tubeFrameCrystalSvg,
      },
    ];

    final perks = [
      {
        'id': 'pro_pass',
        'title': 'عضوية PRO الملكية',
        'desc': 'مضاعفة الجوائز 2X دائماً، وفتح زر مضاعفة المكافأة، وتأثيرات ذهبية، و5 حركات تراجع ومفتاحين سحريين!',
        'cost': 350,
        'icon': Icons.workspace_premium_rounded,
        'iconColor': const Color(0xFFFFD700),
        'ownedText': game.isPro ? 'مفعل للأبد (عضوية PRO نشطة)' : 'غير مشترك',
      },
      {
        'id': 'extra_tube_permanent',
        'title': 'أنبوب إضافي دائم',
        'desc': 'يضيف أنبوباً فارغاً إضافياً في جميع المستويات بلا استثناء لتسهيل أصعب الألغاز المعقدة للأبد!',
        'cost': 400,
        'icon': Icons.science_rounded,
        'iconColor': const Color(0xFF00E5FF),
        'ownedText': game.hasPermanentExtraTube ? 'مفعل دائماً في كل المستويات' : 'غير مفعل',
      },
      {
        'id': 'color_radar',
        'title': 'رادار كشف الطبقات (5 شحنات)',
        'desc': 'يكشف الطبقات المخفية في مستويات الغموض الصعبة ويوجهك للحل الذكي',
        'cost': 120,
        'icon': Icons.radar_rounded,
        'iconColor': const Color(0xFFA855F7),
        'ownedText': 'المتبقي لديك: ${game.colorRadarCharges} شحنة',
      },
      {
        'id': 'time_freeze',
        'title': 'تجميد الوقت (3 مرات)',
        'desc': 'يمنحك +45 ثانية إضافية في مستويات التحدي لتفادي انتهاء الوقت',
        'cost': 90,
        'icon': Icons.ac_unit_rounded,
        'iconColor': const Color(0xFF38BDF8),
        'ownedText': 'المتبقي لديك: ${game.timeFreezes} تجميد',
      },
      {
        'id': 'undo_pack',
        'title': 'حزمة التراجع (5 حركات)',
        'desc': 'تمنحك 5 حركات تراجع مجانية إضافية للخروج من أي مأزق',
        'cost': 50,
        'icon': Icons.replay_rounded,
        'iconColor': const Color(0xFF0284C7),
        'ownedText': 'المتبقي لديك: ${game.freeUndos} تراجع',
      },
      {
        'id': 'tube_key',
        'title': 'المفتاح السحري (مفتاح واحد)',
        'desc': 'يفك قفل أي أنبوب مغلق فوراً بدون أي شروط لتسهيل الفوز',
        'cost': 80,
        'icon': Icons.key_rounded,
        'iconColor': const Color(0xFFF59E0B),
        'ownedText': 'المتبقي لديك: ${game.unlockKeys} مفتاح',
      },
    ];

    return Scaffold(
      body: GameAtmosphereBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Responsive Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    // Back button
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

                    // Title
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
                            'المتجر والترقيات 🛍️',
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

                    // Coins Counter
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
                          SvgPicture.string(AppAssets.coinSvg, width: 20, height: 20),
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
                  ],
                ),
              ),

              // Glass Tabs Selector
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFF334155), width: 1.4),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF94A3B8),
                  labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: '🎨 مظاهر الأنابيب'),
                    Tab(text: '⚡ ميزات المعمل'),
                  ],
                ),
              ),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Tube Skins Grid
                    GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.65,
                      ),
                      itemCount: skins.length,
                      itemBuilder: (context, index) {
                        final skin = skins[index];
                        final String id = skin['id'] as String;
                        final String name = skin['name'] as String;
                        final int cost = skin['cost'] as int;
                        final String desc = skin['desc'] as String;

                        final isUnlocked = game.unlockedSkins.contains(id);
                        final isEquipped = game.activeTubeSkin == id;

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B).withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isEquipped
                                  ? const Color(0xFF10B981)
                                  : (isUnlocked ? const Color(0xFF38BDF8) : const Color(0xFF475569)),
                              width: isEquipped ? 2.5 : 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isEquipped ? const Color(0xFF10B981) : Colors.black)
                                    .withValues(alpha: isEquipped ? 0.3 : 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Live 3D Bottle Model Preview
                              SizedBox(
                                height: 110,
                                width: 50,
                                child: CustomPaint(
                                  painter: Bottle3DPainter(
                                    layers: const [
                                      AppColors.gemRuby,
                                      AppColors.gemCyan,
                                      AppColors.gemGold,
                                    ],
                                    capacity: 3,
                                    skinId: id,
                                    bubblePhase: 0.5,
                                    surfaceWobble: 0.4,
                                  ),
                                ),
                              ),

                              Column(
                                children: [
                                  Text(
                                    name,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    desc,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    style: const TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),

                              // Buy / Equip Button
                              SizedBox(
                                width: double.infinity,
                                height: 38,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isEquipped
                                        ? const Color(0xFF10B981)
                                        : (isUnlocked
                                            ? const Color(0xFF0284C7)
                                            : const Color(0xFFF59E0B)),
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (isEquipped) return;
                                    if (isUnlocked) {
                                      game.equipSkin(id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('تم تجهيز $name بنجاح!')),
                                      );
                                    } else {
                                      final success = game.buyAndEquipSkin(id, cost);
                                      if (success) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('مبروك! تم شراء وتجهيز $name 🧪')),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('عملاتك غير كافية لشراء هذا المظهر!')),
                                        );
                                      }
                                    }
                                  },
                                  child: Text(
                                    isEquipped
                                        ? 'مُجهز ✓'
                                        : (isUnlocked ? 'تجهيز' : '$cost 🪙'),
                                    style: TextStyle(
                                      color: isUnlocked ? Colors.white : Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // Tab 2: Lab Boosters List
                    ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: perks.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final perk = perks[index];
                        final String id = perk['id'] as String;
                        final String title = perk['title'] as String;
                        final String desc = perk['desc'] as String;
                        final int cost = perk['cost'] as int;
                        final IconData icon = perk['icon'] as IconData;
                        final Color iconColor = perk['iconColor'] as Color;
                        final String ownedText = perk['ownedText'] as String;

                        final bool isMaxed = (id == 'double_coins' && game.doubleCoins) ||
                            (id == 'pro_pass' && game.isPro) ||
                            (id == 'extra_tube_permanent' && game.hasPermanentExtraTube);

                        return Directionality(
                          textDirection: TextDirection.rtl,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B).withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: isMaxed ? const Color(0xFF10B981).withValues(alpha: 0.5) : const Color(0xFF334155),
                                width: 1.6,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Perk Icon with Theme Glow
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: iconColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: iconColor.withValues(alpha: 0.4), width: 1.5),
                                  ),
                                  child: Icon(icon, color: iconColor, size: 28),
                                ),
                                const SizedBox(width: 14),

                                // Title, Description & Status Badge
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        desc,
                                        style: const TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 12,
                                          height: 1.35,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: iconColor.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: iconColor.withValues(alpha: 0.25), width: 1.0),
                                        ),
                                        child: Text(
                                          ownedText,
                                          style: TextStyle(
                                            color: iconColor,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Action / Buy Button
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isMaxed
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFF59E0B),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 2,
                                  ),
                                  onPressed: isMaxed
                                      ? null
                                      : () {
                                          final success = game.buyPerk(id, cost);
                                          if (success) {
                                            AudioManager().playBuy();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('تم شراء $title بنجاح!')),
                                            );
                                          } else {
                                            AudioManager().playInvalid();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('عملاتك غير كافية لإتمام الشراء!')),
                                            );
                                          }
                                        },
                                  child: Text(
                                    isMaxed ? 'مفعّل ✓' : '$cost 🪙',
                                    style: TextStyle(
                                      color: isMaxed ? Colors.white : Colors.black,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
