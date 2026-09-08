// lib/core/local_storage/hive_setup.dart

import 'package:hive_flutter/hive_flutter.dart';

class HiveSetup {
  static const String gameResultsBox = 'game_results';
  static const String userDataBox = 'user_data';
  static const String settingsBox = 'settings';
  static const String levelProgressBox = 'level_progress';

  /// Register all Hive Adapters
  static Future<void> registerAdapters() async {
    // Register adapters for custom objects here
    // Example: Hive.registerAdapter(GameResultAdapter());
  }

  /// Open all Hive Boxes
  static Future<void> openBoxes() async {
    await Hive.openBox<dynamic>(gameResultsBox);
    await Hive.openBox<dynamic>(userDataBox);
    await Hive.openBox<dynamic>(settingsBox);
    await Hive.openBox<dynamic>(levelProgressBox);

    print('✅ All Hive boxes opened successfully');
  }

  /// Save game result locally
  static Future<void> saveGameResultLocally(Map<String, dynamic> data) async {
    final box = Hive.box(gameResultsBox);
    final key = 'result_${DateTime.now().millisecondsSinceEpoch}';
    await box.put(key, data);
  }

  /// Get all local game results
  static List<Map<String, dynamic>> getLocalGameResults() {
    final box = Hive.box(gameResultsBox);
    return box.values.cast<Map<String, dynamic>>().toList();
  }

  /// Save user data locally
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final box = Hive.box(userDataBox);
    await box.put('user_data', userData);
  }

  /// Get user data from local storage
  static Map<String, dynamic>? getUserData() {
    final box = Hive.box(userDataBox);
    final data = box.get('user_data');
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  /// Save app settings
  static Future<void> saveSetting(String key, dynamic value) async {
    final box = Hive.box(settingsBox);
    await box.put(key, value);
  }

  /// Get app setting
  static dynamic getSetting(String key, {dynamic defaultValue}) {
    final box = Hive.box(settingsBox);
    return box.get(key, defaultValue: defaultValue);
  }

  /// Save level progress
  static Future<void> saveLevelProgress({
    required int levelNumber,
    required int score,
    required int moves,
    required bool completed,
  }) async {
    final box = Hive.box(levelProgressBox);
    await box.put('level_$levelNumber', {
      'levelNumber': levelNumber,
      'score': score,
      'moves': moves,
      'completed': completed,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Get level progress
  static Map<String, dynamic>? getLevelProgress(int levelNumber) {
    final box = Hive.box(levelProgressBox);
    final data = box.get('level_$levelNumber');
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  /// Get all level progress
  static List<Map<String, dynamic>> getAllLevelProgress() {
    final box = Hive.box(levelProgressBox);
    return box.values.cast<Map<String, dynamic>>().toList();
  }

  /// Clear all local data
  static Future<void> clearAllData() async {
    await Hive.deleteBoxFromDisk(gameResultsBox);
    await Hive.deleteBoxFromDisk(userDataBox);
    await Hive.deleteBoxFromDisk(settingsBox);
    await Hive.deleteBoxFromDisk(levelProgressBox);
    await openBoxes();
  }

  /// Sync local data to Firebase
  static Future<void> syncLocalDataToFirebase() async {
    // Get all local game results
    final localResults = getLocalGameResults();
    
    if (localResults.isEmpty) return;

    // Upload to Firebase
    // This would typically be done in a service layer
    print('📤 Syncing ${localResults.length} local results to Firebase...');
  }
}
