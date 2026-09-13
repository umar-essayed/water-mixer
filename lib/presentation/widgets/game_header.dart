// lib/presentation/widgets/game_header.dart

import 'package:flutter/material.dart';
import '../../domain/entities/game_engine.dart';
import '../../core/local_storage/game_storage.dart';

class GameHeader extends StatelessWidget {
  final int levelNumber;
  final GameMode mode;
  final int moves;
  final int maxMoves;
  final int elapsedTime;
  final int remainingTime;
  final int streak;
  final String worldName;
  final String? specialRule;

  const GameHeader({
    Key? key,
    required this.levelNumber,
    this.mode = GameMode.classic,
    required this.moves,
    required this.maxMoves,
    required this.elapsedTime,
    this.remainingTime = 90,
    this.streak = 0,
    this.worldName = 'مختبر الكيمياء',
    this.specialRule,
  }) : super(key: key);

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isCriticalMoves = (maxMoves - moves) <= 3 && mode == GameMode.classic;
    final isCriticalTime = remainingTime <= 15 && mode == GameMode.timeRush;
    final coins = GameStorage.getCoins();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // الشريط العلوي: معلومات المستوى والعملات
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // رقم المستوى والعالم
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.3),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blueAccent),
                    ),
                    child: Text(
                      '$levelNumber',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getModeTitle(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        worldName,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // سلسلة الانتصارات إن وجدت
              if (streak > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orangeAccent),
                  ),
                  child: Row(
                    children: [
                      const Text('🔥 ', style: TextStyle(fontSize: 12)),
                      Text(
                        'x$streak',
                        style: const TextStyle(
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

              // رصيد العملات
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '$coins',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // شريط الحركات والوقت
          Row(
            children: [
              // الحركات
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCriticalMoves
                        ? Colors.red.withOpacity(0.35)
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isCriticalMoves ? Colors.redAccent : Colors.white24,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'الحركات:',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        mode == GameMode.classic
                            ? '${maxMoves - moves} متبقية'
                            : '$moves حركة',
                        style: TextStyle(
                          color: isCriticalMoves ? Colors.redAccent : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // الوقت
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCriticalTime
                        ? Colors.red.withOpacity(0.35)
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isCriticalTime ? Colors.redAccent : Colors.white24,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        mode == GameMode.timeRush ? 'المتبقي:' : 'الوقت:',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        mode == GameMode.timeRush
                            ? _formatTime(remainingTime)
                            : _formatTime(elapsedTime),
                        style: TextStyle(
                          color: isCriticalTime ? Colors.redAccent : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // تنبيه بالقواعد الخاصة إن وجدت
          if (specialRule != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        specialRule!,
                        style: const TextStyle(
                          color: Colors.amberAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getModeTitle() {
    switch (mode) {
      case GameMode.classic:
        return 'المستوى $levelNumber';
      case GameMode.endless:
        return 'الوضع اللانهائي';
      case GameMode.timeRush:
        return 'سباق الوقت';
      case GameMode.dailyChallenge:
        return 'التحدي اليومي';
    }
  }
}
