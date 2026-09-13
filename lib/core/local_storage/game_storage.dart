// lib/core/local_storage/game_storage.dart

import 'package:hive_flutter/hive_flutter.dart';

class GameStorage {
  static const String _playerBoxName = 'player_storage';
  static const String _levelsBoxName = 'levels_storage';

  static Box<dynamic>? _playerBox;
  static Box<dynamic>? _levelsBox;

  /// تهيئة صناديق Hive
  static Future<void> init() async {
    _playerBox = await Hive.openBox<dynamic>(_playerBoxName);
    _levelsBox = await Hive.openBox<dynamic>(_levelsBoxName);

    // منح رصيد ترحيبي للاعب الجديد
    if (_playerBox?.get('has_welcomed') != true) {
      await _playerBox?.put('has_welcomed', true);
      await _playerBox?.put('coins', 300);
      await _playerBox?.put('highest_unlocked_level', 1);
      await _playerBox?.put('undos_count', 5);
      await _playerBox?.put('hints_count', 5);
      await _playerBox?.put('extra_tubes_count', 3);
      await _playerBox?.put('shuffles_count', 3);
      await _playerBox?.put('selected_tube_skin', 'classic');
      await _playerBox?.put('selected_theme', 'gradient');
      await _playerBox?.put('sound_enabled', true);
      await _playerBox?.put('haptic_enabled', true);
    }
  }

  // ========== العملات ==========
  static int getCoins() => _playerBox?.get('coins', defaultValue: 300) ?? 300;

  static Future<void> addCoins(int amount) async {
    final current = getCoins();
    await _playerBox?.put('coins', current + amount);
  }

  static Future<bool> spendCoins(int amount) async {
    final current = getCoins();
    if (current >= amount) {
      await _playerBox?.put('coins', current - amount);
      return true;
    }
    return false;
  }

  // ========== تقدم المستويات ==========
  static int getHighestUnlockedLevel() =>
      _playerBox?.get('highest_unlocked_level', defaultValue: 1) ?? 1;

  static Future<void> unlockLevel(int level) async {
    final current = getHighestUnlockedLevel();
    if (level > current) {
      await _playerBox?.put('highest_unlocked_level', level);
    }
  }

  static int getLevelStars(int level) =>
      _levelsBox?.get('stars_$level', defaultValue: 0) ?? 0;

  static int getLevelHighScore(int level) =>
      _levelsBox?.get('score_$level', defaultValue: 0) ?? 0;

  static Future<void> saveLevelResult({
    required int level,
    required int stars,
    required int score,
  }) async {
    final oldStars = getLevelStars(level);
    if (stars > oldStars) {
      await _levelsBox?.put('stars_$level', stars);
    }
    final oldScore = getLevelHighScore(level);
    if (score > oldScore) {
      await _levelsBox?.put('score_$level', score);
    }
    await unlockLevel(level + 1);
  }

  static int getTotalStars() {
    int total = 0;
    final highest = getHighestUnlockedLevel();
    for (int i = 1; i <= highest; i++) {
      total += getLevelStars(i);
    }
    return total;
  }

  // ========== الوضع اللانهائي وسباق الوقت ==========
  static int getEndlessHighScore() =>
      _playerBox?.get('endless_high_score', defaultValue: 0) ?? 0;

  static int getEndlessBestStreak() =>
      _playerBox?.get('endless_best_streak', defaultValue: 0) ?? 0;

  static Future<void> saveEndlessResult(int score, int streak) async {
    if (score > getEndlessHighScore()) {
      await _playerBox?.put('endless_high_score', score);
    }
    if (streak > getEndlessBestStreak()) {
      await _playerBox?.put('endless_best_streak', streak);
    }
  }

  static int getTimeRushHighScore() =>
      _playerBox?.get('time_rush_high_score', defaultValue: 0) ?? 0;

  static Future<void> saveTimeRushScore(int score) async {
    if (score > getTimeRushHighScore()) {
      await _playerBox?.put('time_rush_high_score', score);
    }
  }

  // ========== التحدي اليومي ==========
  static bool isDailyChallengeCompleted(String dateKey) =>
      _playerBox?.get('daily_$dateKey', defaultValue: false) ?? false;

  static Future<void> completeDailyChallenge(String dateKey) async {
    await _playerBox?.put('daily_$dateKey', true);
  }

  // ========== أدوات المساعدة (Boosters) ==========
  static int getUndosCount() =>
      _playerBox?.get('undos_count', defaultValue: 5) ?? 5;
  static int getHintsCount() =>
      _playerBox?.get('hints_count', defaultValue: 5) ?? 5;
  static int getExtraTubesCount() =>
      _playerBox?.get('extra_tubes_count', defaultValue: 3) ?? 3;
  static int getShufflesCount() =>
      _playerBox?.get('shuffles_count', defaultValue: 3) ?? 3;

  static Future<void> addBooster(String boosterType, int count) async {
    final current = _playerBox?.get('${boosterType}_count', defaultValue: 0) ?? 0;
    await _playerBox?.put('${boosterType}_count', current + count);
  }

  static Future<bool> useBooster(String boosterType) async {
    final current = _playerBox?.get('${boosterType}_count', defaultValue: 0) ?? 0;
    if (current > 0) {
      await _playerBox?.put('${boosterType}_count', current - 1);
      return true;
    }
    return false;
  }

  // ========== المظاهر والثيمات ==========
  static String getSelectedTubeSkin() =>
      _playerBox?.get('selected_tube_skin', defaultValue: 'classic') ?? 'classic';

  static Future<void> setSelectedTubeSkin(String skin) async =>
      await _playerBox?.put('selected_tube_skin', skin);

  static String getSelectedTheme() =>
      _playerBox?.get('selected_theme', defaultValue: 'gradient') ?? 'gradient';

  static Future<void> setSelectedTheme(String theme) async =>
      await _playerBox?.put('selected_theme', theme);

  static bool isItemUnlocked(String itemKey) =>
      _playerBox?.get('unlocked_$itemKey', defaultValue: false) ?? false;

  static Future<void> unlockItem(String itemKey) async =>
      await _playerBox?.put('unlocked_$itemKey', true);

  // ========== الإعدادات العامة ==========
  static bool isSoundEnabled() =>
      _playerBox?.get('sound_enabled', defaultValue: true) ?? true;

  static Future<void> setSoundEnabled(bool val) async =>
      await _playerBox?.put('sound_enabled', val);

  static bool isHapticEnabled() =>
      _playerBox?.get('haptic_enabled', defaultValue: true) ?? true;

  static Future<void> setHapticEnabled(bool val) async =>
      await _playerBox?.put('haptic_enabled', val);

  /// إعادة تعيين كافة البيانات
  static Future<void> resetAllData() async {
    await _playerBox?.clear();
    await _levelsBox?.clear();
    await init();
  }
}
