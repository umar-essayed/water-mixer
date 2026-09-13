// lib/presentation/pages/menu_screen.dart

import 'package:flutter/material.dart';
import '../../config/routes/app_routes.dart';
import '../../core/local_storage/game_storage.dart';
import '../../domain/entities/game_engine.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    final highestLevel = GameStorage.getHighestUnlockedLevel();
    final totalStars = GameStorage.getTotalStars();
    final coins = GameStorage.getCoins();
    final endlessRecord = GameStorage.getEndlessBestStreak();
    final timeRushBest = GameStorage.getTimeRushHighScore();

    final now = DateTime.now();
    final dailyKey = '${now.year}_${now.month}_${now.day}';
    final isDailyDone = GameStorage.isDailyChallengeCompleted(dailyKey);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. الشريط العلوي: رصيد العملات والنجوم
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // النجوم
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          '$totalStars',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // الشعار
                  const Text(
                    '💧 Water Mixer',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),

                  // العملات
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.shop)
                          .then((_) => setState(() {}));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.amber),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            '$coins',
                            style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.add, color: Colors.amber, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 2. بطاقة الوضع الكلاسيكي (رحلة المستويات)
              _buildGameModeCard(
                title: 'رحلة المستويات (Classic Saga)',
                subtitle: 'المستوى الحالي: $highestLevel • 100+ لغز متدرج الصعوبة',
                badge: 'الوضع الأساسي',
                icon: Icons.map,
                gradient: const [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                buttonText: 'متابعة المستوى $highestLevel ▶️',
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.game,
                    arguments: {
                      'levelNumber': highestLevel,
                      'mode': GameMode.classic,
                    },
                  ).then((_) => setState(() {}));
                },
                secondaryButtonText: 'خريطة العوالم 🗺️',
                onSecondaryTap: () {
                  Navigator.pushNamed(context, AppRoutes.levelSelection)
                      .then((_) => setState(() {}));
                },
              ),

              const SizedBox(height: 16),

              // 3. بطاقة الوضع اللانهائي (Endless Streak)
              _buildGameModeCard(
                title: 'الوضع اللانهائي (Endless Zen 🔥)',
                subtitle: 'ألغاز تتولد خوارزمياً بلا نهاية • أطول سلسلة: $endlessRecord انتصار',
                badge: 'تشويق لانهائي',
                icon: Icons.all_inclusive,
                gradient: const [Color(0xFFD97706), Color(0xFFB45309)],
                buttonText: 'ابدأ التحدي اللانهائي 🔥',
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.game,
                    arguments: {
                      'levelNumber': 1,
                      'mode': GameMode.endless,
                      'streak': 0,
                    },
                  ).then((_) => setState(() {}));
                },
              ),

              const SizedBox(height: 16),

              // 4. بطاقة سباق الوقت السريع (Time Rush)
              _buildGameModeCard(
                title: 'سباق الوقت (Time Rush ⏱️)',
                subtitle: '90 ثانية لحل أكبر قدر من الأنابيب • رقمك القياسي: $timeRushBest',
                badge: 'سرعة وإثارة',
                icon: Icons.timer,
                gradient: const [Color(0xFFDC2626), Color(0xFF991B1B)],
                buttonText: 'ابدأ سباق السرعة ⏱️',
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.game,
                    arguments: {
                      'levelNumber': 1,
                      'mode': GameMode.timeRush,
                    },
                  ).then((_) => setState(() {}));
                },
              ),

              const SizedBox(height: 16),

              // 5. بطاقة التحدي اليومي (Daily Challenge)
              _buildGameModeCard(
                title: 'التحدي اليومي (Daily Puzzle 🏆)',
                subtitle: isDailyDone
                    ? '✅ أحسنت! تم إكمال لغز اليوم بنجاح وحصد المكافأة'
                    : 'لغز اليوم الفريد عالمياً • مكافأة 200 عملة وكأس خاص',
                badge: isDailyDone ? 'مكتمل اليوم' : 'جديد اليوم',
                icon: Icons.event,
                gradient: const [Color(0xFF7C3AED), Color(0xFF5B21B6)],
                buttonText: isDailyDone ? 'إعادة اللعب 🔄' : 'العب لغز اليوم 🏆',
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.game,
                    arguments: {
                      'levelNumber': now.day,
                      'mode': GameMode.dailyChallenge,
                    },
                  ).then((_) => setState(() {}));
                },
              ),

              const SizedBox(height: 24),

              // 6. أزرار الخدمات السريعة (المتجر، التصنيفات، الإعدادات)
              Row(
                children: [
                  Expanded(
                    child: _buildQuickButton(
                      icon: Icons.shopping_bag,
                      label: 'المتجر',
                      color: Colors.purpleAccent,
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.shop)
                            .then((_) => setState(() {}));
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickButton(
                      icon: Icons.leaderboard,
                      label: 'التصنيفات',
                      color: Colors.amberAccent,
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.leaderboard);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickButton(
                      icon: Icons.settings,
                      label: 'الإعدادات',
                      color: Colors.blueGrey,
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.settings)
                            .then((_) => setState(() {}));
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameModeCard({
    required String title,
    required String subtitle,
    required String badge,
    required IconData icon,
    required List<Color> gradient,
    required String buttonText,
    required VoidCallback onTap,
    String? secondaryButtonText,
    VoidCallback? onSecondaryTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: Colors.white, size: 26),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: gradient.first,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
                if (secondaryButtonText != null) ...[
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: onSecondaryTap,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(secondaryButtonText),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
