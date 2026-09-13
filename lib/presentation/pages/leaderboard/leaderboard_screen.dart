// lib/presentation/pages/leaderboard/leaderboard_screen.dart

import 'package:flutter/material.dart';
import 'package:water_mixer_new/core/local_storage/game_storage.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalStars = GameStorage.getTotalStars();
    final endlessStreak = GameStorage.getEndlessBestStreak();
    final playerScore = totalStars * 150 + endlessStreak * 200;

    final List<Map<String, dynamic>> mockPlayers = [
      {'name': 'أحمد المهندس', 'score': 18450, 'stars': 98, 'streak': 24},
      {'name': 'سارة محمد', 'score': 15200, 'stars': 85, 'streak': 19},
      {'name': 'عمر الصياد (أنت)', 'score': playerScore, 'stars': totalStars, 'streak': endlessStreak, 'isUser': true},
      {'name': 'خالد التميمي', 'score': 12100, 'stars': 74, 'streak': 15},
      {'name': 'فاطمة الزهراء', 'score': 10500, 'stars': 68, 'streak': 12},
      {'name': 'يوسف كمال', 'score': 8900, 'stars': 55, 'streak': 10},
      {'name': 'نور الهدى', 'score': 7400, 'stars': 46, 'streak': 8},
      {'name': 'طارق العلي', 'score': 6200, 'stars': 38, 'streak': 6},
    ];

    // ترتيب حسب النقاط
    mockPlayers.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('لوحة المتصدرين 🏆', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockPlayers.length,
        itemBuilder: (context, index) {
          final player = mockPlayers[index];
          final rank = index + 1;
          final isUser = player['isUser'] == true;

          Widget rankBadge;
          if (rank == 1) {
            rankBadge = const Text('🥇', style: TextStyle(fontSize: 26));
          } else if (rank == 2) {
            rankBadge = const Text('🥈', style: TextStyle(fontSize: 26));
          } else if (rank == 3) {
            rankBadge = const Text('🥉', style: TextStyle(fontSize: 26));
          } else {
            rankBadge = Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isUser
                  ? Colors.amber.withOpacity(0.18)
                  : Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isUser ? Colors.amber : Colors.white12,
                width: isUser ? 2.0 : 1.0,
              ),
            ),
            child: Row(
              children: [
                rankBadge,
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player['name'] as String,
                        style: TextStyle(
                          color: isUser ? Colors.amber : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${player['stars']} نجمة',
                            style: const TextStyle(color: Colors.white60, fontSize: 12),
                          ),
                          const SizedBox(width: 10),
                          const Text('🔥', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 2),
                          Text(
                            '${player['streak']} انتصار',
                            style: const TextStyle(color: Colors.orangeAccent, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  '${player['score']} نقطة',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
