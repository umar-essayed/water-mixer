// lib/presentation/pages/level_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:water_mixer_new/config/routes/app_routes.dart';
import 'package:water_mixer_new/core/local_storage/game_storage.dart';
import 'package:water_mixer_new/domain/entities/game_engine.dart';

class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({Key? key}) : super(key: key);

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _worlds = [
    {
      'title': 'مختبر الكيمياء',
      'icon': Icons.science,
      'range': [1, 25],
      'color': Colors.blue,
    },
    {
      'title': 'واحة الألوان',
      'icon': Icons.palette,
      'range': [26, 50],
      'color': Colors.orange,
    },
    {
      'title': 'مجرة النيون',
      'icon': Icons.flare,
      'range': [51, 75],
      'color': Colors.purple,
    },
    {
      'title': 'قصر الكريستال',
      'icon': Icons.diamond,
      'range': [76, 100],
      'color': Colors.cyan,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _worlds.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final highestUnlocked = GameStorage.getHighestUnlockedLevel();
    final totalStars = GameStorage.getTotalStars();
    final coins = GameStorage.getCoins();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Text(
          'خريطة المستويات',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          // عداد النجوم
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text(
                  '$totalStars',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // عداد العملات
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text(
                  '$coins',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.amber,
          tabs: _worlds.map((w) {
            return Tab(
              icon: Icon(w['icon'] as IconData, size: 20),
              text: w['title'] as String,
            );
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _worlds.map((world) {
          final range = world['range'] as List<int>;
          final start = range[0];
          final end = range[1];
          final worldColor = world['color'] as Color;

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: (end - start) + 1,
            itemBuilder: (context, index) {
              final levelNum = start + index;
              final isUnlocked = levelNum <= highestUnlocked;
              final isCurrent = levelNum == highestUnlocked;
              final stars = GameStorage.getLevelStars(levelNum);

              return GestureDetector(
                onTap: isUnlocked
                    ? () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.game,
                          arguments: {
                            'levelNumber': levelNum,
                            'mode': GameMode.classic,
                          },
                        ).then((_) => setState(() {}));
                      }
                    : null,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: isUnlocked
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isCurrent
                                ? [Colors.amber.shade600, Colors.amber.shade800]
                                : [
                                    worldColor.withOpacity(0.85),
                                    worldColor.withOpacity(0.55),
                                  ],
                          )
                        : null,
                    color: isUnlocked ? null : Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCurrent
                          ? Colors.amberAccent
                          : (isUnlocked
                              ? Colors.white.withOpacity(0.3)
                              : Colors.white12),
                      width: isCurrent ? 2.5 : 1.0,
                    ),
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!isUnlocked)
                        const Icon(Icons.lock, color: Colors.white30, size: 24)
                      else ...[
                        Text(
                          '$levelNum',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // عرض النجوم
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (starIdx) {
                            return Icon(
                              starIdx < stars ? Icons.star : Icons.star_border,
                              color: starIdx < stars ? Colors.amber : Colors.white30,
                              size: 14,
                            );
                          }),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
