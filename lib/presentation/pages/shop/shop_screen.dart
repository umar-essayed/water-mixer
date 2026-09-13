// lib/presentation/pages/shop/shop_screen.dart

import 'package:flutter/material.dart';
import '../../core/local_storage/game_storage.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({Key? key}) : super(key: key);

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _buyBooster(String type, String title, int count, int cost) async {
    final success = await GameStorage.spendCoins(cost);
    if (success) {
      await GameStorage.addBooster(type, count);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 تم شراء $title بنجاح! (-$cost عملة)'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ لا تملك عملات كافية، أكمل مستويات لكسب المزيد!'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _buySkin(String key, int cost) async {
    final isUnlocked = GameStorage.isItemUnlocked(key);
    if (isUnlocked) {
      await GameStorage.setSelectedTubeSkin(key);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ تم تفعيل المظهر بنجاح!')),
      );
      return;
    }

    final success = await GameStorage.spendCoins(cost);
    if (success) {
      await GameStorage.unlockItem(key);
      await GameStorage.setSelectedTubeSkin(key);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('🎉 تم فتح وتفعيل المظهر! (-$cost عملة)')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ رصيد العملات غير كافٍ')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final coins = GameStorage.getCoins();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('متجر اللعبة', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                const SizedBox(width: 6),
                Text(
                  '$coins',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          tabs: const [
            Tab(icon: Icon(Icons.flash_on), text: 'المساعدات'),
            Tab(icon: Icon(Icons.science), text: 'الأنابيب'),
            Tab(icon: Icon(Icons.wallpaper), text: 'الخلفيات'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. تبويب المساعدات
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildBoosterItem(
                icon: Icons.undo,
                title: 'حزمة التراجع (5 حركات)',
                description: 'التراجع عن أي خطوة صب خاطئة',
                ownedCount: GameStorage.getUndosCount(),
                cost: 60,
                color: Colors.amber,
                onBuy: () => _buyBooster('undos', '5 تراجعات', 5, 60),
              ),
              const SizedBox(height: 12),
              _buildBoosterItem(
                icon: Icons.lightbulb,
                title: 'حزمة التلميحات (5 تلميحات)',
                description: 'كشف أفضل خطوة تالية بالذكاء الاصطناعي',
                ownedCount: GameStorage.getHintsCount(),
                cost: 75,
                color: Colors.cyanAccent,
                onBuy: () => _buyBooster('hints', '5 تلميحات', 5, 75),
              ),
              const SizedBox(height: 12),
              _buildBoosterItem(
                icon: Icons.add_circle,
                title: 'حزمة الأنابيب الإضافية (3 أنابيب)',
                description: 'إضافة أنبوب فارغ لتسهيل الألغاز المستعصية',
                ownedCount: GameStorage.getExtraTubesCount(),
                cost: 120,
                color: Colors.greenAccent,
                onBuy: () => _buyBooster('extra_tubes', '3 أنابيب', 3, 120),
              ),
              const SizedBox(height: 12),
              _buildBoosterItem(
                icon: Icons.shuffle,
                title: 'حزمة إعادة الخلط (5 مرات)',
                description: 'إعادة توزيع السوائل العالقة مع بقائها قابلة للحل',
                ownedCount: GameStorage.getShufflesCount(),
                cost: 50,
                color: Colors.purpleAccent,
                onBuy: () => _buyBooster('shuffles', '5 خلطات', 5, 50),
              ),
            ],
          ),

          // 2. تبويب أشكال الأنابيب
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSkinItem(
                keyName: 'classic',
                title: 'الأنبوب الزجاجي الكلاسيكي',
                subtitle: 'المظهر الأصلي البسيط والأنيق',
                cost: 0,
                icon: Icons.science,
                isFree: true,
              ),
              const SizedBox(height: 12),
              _buildSkinItem(
                keyName: 'crystal',
                title: 'القارورة الكريستالية اللامعة',
                subtitle: 'زجاج كريستالي مقطوع بحواف مضيئة',
                cost: 150,
                icon: Icons.diamond,
              ),
              const SizedBox(height: 12),
              _buildSkinItem(
                keyName: 'neon',
                title: 'أنبوب النيون السايبر',
                subtitle: 'حواف مضيئة بأسلوب السايبربانك',
                cost: 250,
                icon: Icons.flare,
              ),
              const SizedBox(height: 12),
              _buildSkinItem(
                keyName: 'potion',
                title: 'زجاجة الجرعات السحرية',
                subtitle: 'تصميم قوارير السحر القديمة',
                cost: 400,
                icon: Icons.auto_awesome,
              ),
            ],
          ),

          // 3. تبويب الخلفيات
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildThemeItem(
                keyName: 'gradient',
                title: 'التدرج الليلي الفخم',
                subtitle: 'الخلفية الافتراضية المريحة للعين',
                cost: 0,
                color: Colors.indigo,
                isFree: true,
              ),
              const SizedBox(height: 12),
              _buildThemeItem(
                keyName: 'lab',
                title: 'المختبر الكيميائي السري',
                subtitle: 'أجواء تجارب علمية وغازات فوارة',
                cost: 100,
                color: Colors.teal,
              ),
              const SizedBox(height: 12),
              _buildThemeItem(
                keyName: 'ocean',
                title: 'أعماق المحيط الهادئ',
                subtitle: 'زرقة البحر العميقة وفقاعات الماء',
                cost: 200,
                color: Colors.blueAccent,
              ),
              const SizedBox(height: 12),
              _buildThemeItem(
                keyName: 'space',
                title: 'مجرة الفضاء الكونية',
                subtitle: 'نجوم مضيئة وسدم ملونة',
                cost: 350,
                color: Colors.deepPurple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBoosterItem({
    required IconData icon,
    required String title,
    required String description,
    required int ownedCount,
    required int cost,
    required Color color,
    required VoidCallback onBuy,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  'المتوفر لديك: $ownedCount',
                  style: const TextStyle(
                    color: Colors.amberAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onBuy,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('$cost 🪙'),
          ),
        ],
      ),
    );
  }

  Widget _buildSkinItem({
    required String keyName,
    required String title,
    required String subtitle,
    required int cost,
    required IconData icon,
    bool isFree = false,
  }) {
    final isSelected = GameStorage.getSelectedTubeSkin() == keyName;
    final isUnlocked = isFree || GameStorage.isItemUnlocked(keyName);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? Colors.amber : Colors.white12,
          width: isSelected ? 2.0 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: isSelected ? Colors.amber : Colors.white70, size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.amber : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _buySkin(keyName, cost),
            style: ElevatedButton.styleFrom(
              backgroundColor: isSelected
                  ? Colors.green
                  : (isUnlocked ? Colors.blue : Colors.amber.shade800),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              isSelected
                  ? 'مفعّل ✅'
                  : (isUnlocked ? 'استخدام' : '$cost 🪙'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeItem({
    required String keyName,
    required String title,
    required String subtitle,
    required int cost,
    required Color color,
    bool isFree = false,
  }) {
    final isSelected = GameStorage.getSelectedTheme() == keyName;
    final isUnlocked = isFree || GameStorage.isItemUnlocked('theme_$keyName');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? Colors.amber : Colors.white12,
          width: isSelected ? 2.0 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.amber : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (isUnlocked) {
                await GameStorage.setSelectedTheme(keyName);
                setState(() {});
              } else {
                final success = await GameStorage.spendCoins(cost);
                if (success) {
                  await GameStorage.unlockItem('theme_$keyName');
                  await GameStorage.setSelectedTheme(keyName);
                  setState(() {});
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isSelected
                  ? Colors.green
                  : (isUnlocked ? Colors.blue : Colors.amber.shade800),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              isSelected
                  ? 'مفعّل ✅'
                  : (isUnlocked ? 'استخدام' : '$cost 🪙'),
            ),
          ),
        ],
      ),
    );
  }
}
