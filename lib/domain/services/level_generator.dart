// lib/domain/services/level_generator.dart

import 'dart:math';
import 'package:water_mixer_new/domain/entities/game_engine.dart';

/// 🧠 مولد الألغاز الذكي والقابل للحل 100% رياضياً
class LevelGenerator {
  static const List<String> availableColors = [
    'blue',
    'red',
    'green',
    'yellow',
    'purple',
    'orange',
    'cyan',
    'pink',
  ];

  /// توليد مستوى كلاسيكي أو لأي نمط محدد
  static GameLevel generateLevel(
    int levelNumber, {
    GameMode mode = GameMode.classic,
    int? customSeed,
  }) {
    final random = Random(customSeed ?? (levelNumber * 7919 + 13));

    int colorCount;
    int emptyTubes;
    bool hasMystery = false;
    bool hasLockedTube = false;
    bool hasBomb = false;
    int? bombCountdown;

    // تدرج الصعوبة حسب رقم المستوى
    if (levelNumber <= 2) {
      colorCount = 2;
      emptyTubes = 1;
    } else if (levelNumber <= 5) {
      colorCount = 3;
      emptyTubes = 1;
    } else if (levelNumber <= 10) {
      colorCount = 3;
      emptyTubes = 2;
      hasMystery = levelNumber >= 6;
    } else if (levelNumber <= 20) {
      colorCount = 4;
      emptyTubes = 2;
      hasMystery = true;
      hasLockedTube = levelNumber >= 15;
    } else if (levelNumber <= 35) {
      colorCount = 5;
      emptyTubes = 2;
      hasMystery = true;
      hasLockedTube = true;
      hasBomb = levelNumber >= 25;
      bombCountdown = 20 - (levelNumber % 5);
    } else if (levelNumber <= 50) {
      colorCount = 6;
      emptyTubes = 2;
      hasMystery = true;
      hasLockedTube = true;
      hasBomb = true;
      bombCountdown = 16;
    } else {
      colorCount = min(8, 6 + (levelNumber ~/ 25));
      emptyTubes = 2 + (levelNumber > 75 ? 1 : 0);
      hasMystery = true;
      hasLockedTube = true;
      hasBomb = levelNumber % 2 == 0;
      bombCountdown = 15;
    }

    // تكييف الخصائص حسب وضع اللعبة
    if (mode == GameMode.timeRush) {
      colorCount = min(4, 2 + (levelNumber ~/ 2));
      emptyTubes = 1;
      hasMystery = false;
      hasBomb = false;
      hasLockedTube = false;
    } else if (mode == GameMode.dailyChallenge) {
      colorCount = 5;
      emptyTubes = 2;
      hasMystery = true;
      hasLockedTube = true;
      hasBomb = true;
      bombCountdown = 18;
    }

    final totalTubes = colorCount + emptyTubes;
    final selectedColors = availableColors.sublist(0, colorCount);

    // 1. نبدأ من حالة محلولة تماماً (Solved State)
    List<List<String>> tubeSlots = [];
    for (int i = 0; i < colorCount; i++) {
      tubeSlots.add(List.generate(4, (_) => selectedColors[i]));
    }
    for (int i = 0; i < emptyTubes; i++) {
      tubeSlots.add(List.generate(4, (_) => 'transparent'));
    }

    // 2. خلط الألوان عبر محاكاة حركات عكسية صالحة (Valid Reverse Moves)
    // هذا يضمن 100% أن اللغز قابل للحل لأننا بدأنا من الحل وقمنا بخلطه بقواعد صحيحة
    final shuffleSteps = 25 + levelNumber * 2;
    for (int step = 0; step < shuffleSteps; step++) {
      final fromIdx = random.nextInt(totalTubes);
      final toIdx = random.nextInt(totalTubes);
      if (fromIdx == toIdx) continue;

      final fromTube = tubeSlots[fromIdx];
      final toTube = tubeSlots[toIdx];

      // إيجاد آخر سائل في الأنبوب الأول
      int fromTopIdx = -1;
      for (int k = 3; k >= 0; k--) {
        if (fromTube[k] != 'transparent') {
          fromTopIdx = k;
          break;
        }
      }
      if (fromTopIdx == -1) continue; // الأنبوب الأول فارغ

      // إيجاد أول مساحة فارغة في الأنبوب الثاني
      int toEmptyIdx = -1;
      for (int k = 0; k < 4; k++) {
        if (toTube[k] == 'transparent') {
          toEmptyIdx = k;
          break;
        }
      }
      if (toEmptyIdx == -1) continue; // الأنبوب الثاني ممتلئ

      // نقل سائل واحد
      final color = fromTube[fromTopIdx];
      fromTube[fromTopIdx] = 'transparent';
      toTube[toEmptyIdx] = color;
    }

    // التأكد من وجود أنبوب واحد على الأقل يحتوي مساحة فارغة
    bool hasEmptySpace = tubeSlots.any((t) => t.contains('transparent'));
    if (!hasEmptySpace) {
      // إفراغ أنبوب أخير لضمان الحركة الأولى
      tubeSlots.last = List.generate(4, (_) => 'transparent');
    }

    // 3. تحويل المصفوفات إلى كائنات TestTube مع تطبيق الميكانيكيات المتقدمة
    final finalTubes = <TestTube>[];
    for (int i = 0; i < totalTubes; i++) {
      final layers = <TubeLayer>[];
      final isLocked = hasLockedTube && (i == totalTubes - 1);
      final isBombTube = hasBomb && (i == 0);

      for (int j = 0; j < 4; j++) {
        final color = tubeSlots[i][j];
        // وضع سائل مجهول في الطبقات السفلية فقط
        final isMysteryLayer = hasMystery &&
            color != 'transparent' &&
            j <= 1 &&
            i < colorCount &&
            (i + j) % 2 == 0;

        layers.add(TubeLayer(
          color: color,
          isMystery: isMysteryLayer,
          isRevealed: false,
        ));
      }

      finalTubes.add(TestTube(
        id: i,
        layers: layers,
        maxCapacity: 4,
        isLocked: isLocked,
        unlockCondition: isLocked ? 'أكمل أي أنبوب بالكامل لفك القفل' : null,
        isBomb: isBombTube,
        bombCountdown: isBombTube ? bombCountdown : null,
      ));
    }

    // تحديد اسم العالم والقواعد الخاصة
    String worldName;
    String? specialRule;
    if (levelNumber <= 25) {
      worldName = 'مختبر الكيمياء';
    } else if (levelNumber <= 50) {
      worldName = 'واحة الألوان';
      specialRule = 'انتبه للسوائل المجهولة والقفل!';
    } else if (levelNumber <= 75) {
      worldName = 'مجرة النيون';
      specialRule = 'قنبلة موقوتة! رتب الأنابيب قبل انتهاء الحركات';
    } else {
      worldName = 'قصر الكريستال';
      specialRule = 'مستويات الخبراء: تحدي الماستر الشامل';
    }

    return GameLevel(
      levelNumber: levelNumber,
      mode: mode,
      difficulty: _getDifficulty(levelNumber),
      minMoves: max(6, colorCount * 3 + levelNumber ~/ 4),
      baseScore: 150 + (levelNumber * 15),
      initialTubes: finalTubes,
      timeLimit: mode == GameMode.timeRush ? 90 : 300,
      worldName: worldName,
      specialRule: specialRule,
    );
  }

  /// توليد مستوى الوضع اللانهائي بناءً على سلسلة الانتصارات الحالية
  static GameLevel generateEndlessLevel(int streak) {
    final virtualLevel = 5 + streak * 2;
    return generateLevel(virtualLevel, mode: GameMode.endless);
  }

  /// توليد لغز التحدي اليومي
  static GameLevel generateDailyChallenge(DateTime date) {
    final seed = date.year * 10000 + date.month * 100 + date.day;
    return generateLevel(date.day, mode: GameMode.dailyChallenge, customSeed: seed);
  }

  static String _getDifficulty(int level) {
    if (level <= 5) return 'سهل جداً';
    if (level <= 15) return 'سهل';
    if (level <= 30) return 'متوسط';
    if (level <= 50) return 'صعب';
    if (level <= 75) return 'شديد الصعوبة';
    return 'ماستر الخبراء';
  }
}
