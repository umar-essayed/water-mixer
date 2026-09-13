import 'package:shared_preferences/shared_preferences.dart';

class PersistenceManager {
  static const String _keyCurrentLevel = 'wm_current_level';
  static const String _keyMaxUnlockedLevel = 'wm_max_unlocked_level';
  static const String _keyTotalCoins = 'wm_total_coins';
  static const String _keySoundEnabled = 'wm_sound_enabled';
  static const String _keyVibrationEnabled = 'wm_vibration_enabled';
  static const String _keyUnlockedThemes = 'wm_unlocked_themes';
  static const String _keyLevelStars = 'wm_level_stars_';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static int getCurrentLevel() {
    return _prefs?.getInt(_keyCurrentLevel) ?? 1;
  }

  static Future<void> saveCurrentLevel(int level) async {
    await _prefs?.setInt(_keyCurrentLevel, level);
  }

  static int getMaxUnlockedLevel() {
    return _prefs?.getInt(_keyMaxUnlockedLevel) ?? 1;
  }

  static Future<void> saveMaxUnlockedLevel(int level) async {
    final current = getMaxUnlockedLevel();
    if (level > current) {
      await _prefs?.setInt(_keyMaxUnlockedLevel, level);
    }
  }

  static int getTotalCoins() {
    return _prefs?.getInt(_keyTotalCoins) ?? 100;
  }

  static Future<void> saveTotalCoins(int coins) async {
    await _prefs?.setInt(_keyTotalCoins, coins);
  }

  static bool getSoundEnabled() {
    return _prefs?.getBool(_keySoundEnabled) ?? true;
  }

  static Future<void> saveSoundEnabled(bool enabled) async {
    await _prefs?.setBool(_keySoundEnabled, enabled);
  }

  static bool getVibrationEnabled() {
    return _prefs?.getBool(_keyVibrationEnabled) ?? true;
  }

  static Future<void> saveVibrationEnabled(bool enabled) async {
    await _prefs?.setBool(_keyVibrationEnabled, enabled);
  }

  static int getLevelStars(int level) {
    return _prefs?.getInt('$_keyLevelStars$level') ?? 0;
  }

  static int getTotalEarnedStars([int maxLevel = 50]) {
    int total = 0;
    for (int i = 1; i <= maxLevel; i++) {
      total += getLevelStars(i);
    }
    return total;
  }

  static Future<void> saveLevelStars(int level, int stars) async {
    final existing = getLevelStars(level);
    if (stars > existing) {
      await _prefs?.setInt('$_keyLevelStars$level', stars);
    }
  }

  static const String _keyActiveSkin = 'wm_active_skin';
  static const String _keyUnlockedSkins = 'wm_unlocked_skins';
  static const String _keyFreeUndos = 'wm_free_undos';
  static const String _keyUnlockKeys = 'wm_unlock_keys';
  static const String _keyDoubleCoins = 'wm_double_coins';

  static String getActiveTubeSkin() {
    return _prefs?.getString(_keyActiveSkin) ?? 'classic';
  }

  static Future<void> saveActiveTubeSkin(String skinId) async {
    await _prefs?.setString(_keyActiveSkin, skinId);
  }

  static List<String> getUnlockedSkins() {
    return _prefs?.getStringList(_keyUnlockedSkins) ?? ['classic'];
  }

  static Future<void> unlockSkin(String skinId) async {
    final current = getUnlockedSkins();
    if (!current.contains(skinId)) {
      final updated = List<String>.from(current)..add(skinId);
      await _prefs?.setStringList(_keyUnlockedSkins, updated);
    }
  }

  static int getFreeUndos() {
    return _prefs?.getInt(_keyFreeUndos) ?? 0;
  }

  static Future<void> addFreeUndos(int count) async {
    final current = getFreeUndos();
    await _prefs?.setInt(_keyFreeUndos, current + count);
  }

  static Future<bool> useFreeUndo() async {
    final current = getFreeUndos();
    if (current > 0) {
      await _prefs?.setInt(_keyFreeUndos, current - 1);
      return true;
    }
    return false;
  }

  static int getUnlockKeys() {
    return _prefs?.getInt(_keyUnlockKeys) ?? 0;
  }

  static Future<void> addUnlockKeys(int count) async {
    final current = getUnlockKeys();
    await _prefs?.setInt(_keyUnlockKeys, current + count);
  }

  static Future<bool> useUnlockKey() async {
    final current = getUnlockKeys();
    if (current > 0) {
      await _prefs?.setInt(_keyUnlockKeys, current - 1);
      return true;
    }
    return false;
  }

  static bool hasDoubleCoins() {
    return _prefs?.getBool(_keyDoubleCoins) ?? false;
  }

  static Future<void> enableDoubleCoins() async {
    await _prefs?.setBool(_keyDoubleCoins, true);
  }

  static const String _keyIsPro = 'wm_is_pro';
  static const String _keyPermanentExtraTube = 'wm_permanent_extra_tube';
  static const String _keyColorRadar = 'wm_color_radar';
  static const String _keyTimeFreeze = 'wm_time_freeze';

  static bool isPro() {
    return _prefs?.getBool(_keyIsPro) ?? false;
  }

  static Future<void> enablePro() async {
    await _prefs?.setBool(_keyIsPro, true);
    await enableDoubleCoins();
  }

  static bool hasPermanentExtraTube() {
    return _prefs?.getBool(_keyPermanentExtraTube) ?? false;
  }

  static Future<void> enablePermanentExtraTube() async {
    await _prefs?.setBool(_keyPermanentExtraTube, true);
  }

  static int getColorRadarCount() {
    return _prefs?.getInt(_keyColorRadar) ?? 0;
  }

  static Future<void> addColorRadar(int count) async {
    final current = getColorRadarCount();
    await _prefs?.setInt(_keyColorRadar, current + count);
  }

  static Future<bool> useColorRadar() async {
    final current = getColorRadarCount();
    if (current > 0) {
      await _prefs?.setInt(_keyColorRadar, current - 1);
      return true;
    }
    return false;
  }

  static int getTimeFreezeCount() {
    return _prefs?.getInt(_keyTimeFreeze) ?? 0;
  }

  static Future<void> addTimeFreeze(int count) async {
    final current = getTimeFreezeCount();
    await _prefs?.setInt(_keyTimeFreeze, current + count);
  }

  static Future<bool> useTimeFreeze() async {
    final current = getTimeFreezeCount();
    if (current > 0) {
      await _prefs?.setInt(_keyTimeFreeze, current - 1);
      return true;
    }
    return false;
  }

  static List<String> getUnlockedThemes() {
    return _prefs?.getStringList(_keyUnlockedThemes) ?? ['default'];
  }

  static Future<void> unlockTheme(String themeId) async {
    final current = getUnlockedThemes();
    if (!current.contains(themeId)) {
      current.add(themeId);
      await _prefs?.setStringList(_keyUnlockedThemes, current);
    }
  }

  // ===================== Lab Upgrades =====================
  static int getLabUpgrade(String upgradeId) {
    return _prefs?.getInt('wm_lab_$upgradeId') ?? 1;
  }

  static Future<void> setLabUpgrade(String upgradeId, int level) async {
    await _prefs?.setInt('wm_lab_$upgradeId', level);
  }

  // ===================== Survival Mode =====================
  static const String _keySurvivalHighScore = 'wm_survival_high_score';
  static const String _keySurvivalBestWave = 'wm_survival_best_wave';

  static int getSurvivalHighScore() {
    return _prefs?.getInt(_keySurvivalHighScore) ?? 0;
  }

  static Future<void> saveSurvivalHighScore(int score) async {
    final current = getSurvivalHighScore();
    if (score > current) {
      await _prefs?.setInt(_keySurvivalHighScore, score);
    }
  }

  static int getSurvivalBestWave() {
    return _prefs?.getInt(_keySurvivalBestWave) ?? 1;
  }

  static Future<void> saveSurvivalBestWave(int wave) async {
    final current = getSurvivalBestWave();
    if (wave > current) {
      await _prefs?.setInt(_keySurvivalBestWave, wave);
    }
  }

  // ===================== New Tactical Shop Perks =====================
  static const String _keyBombDefusers = 'wm_bomb_defusers';
  static const String _keyFloodSiphons = 'wm_flood_siphons';
  static const String _keyFortuneElixir = 'wm_fortune_elixir';

  static int getBombDefusers() => _prefs?.getInt(_keyBombDefusers) ?? 1;
  static Future<void> addBombDefusers(int count) async {
    final current = getBombDefusers();
    await _prefs?.setInt(_keyBombDefusers, current + count);
  }
  static Future<bool> useBombDefuser() async {
    final current = getBombDefusers();
    if (current > 0) {
      await _prefs?.setInt(_keyBombDefusers, current - 1);
      return true;
    }
    return false;
  }

  static int getFloodSiphons() => _prefs?.getInt(_keyFloodSiphons) ?? 2;
  static Future<void> addFloodSiphons(int count) async {
    final current = getFloodSiphons();
    await _prefs?.setInt(_keyFloodSiphons, current + count);
  }
  static Future<bool> useFloodSiphon() async {
    final current = getFloodSiphons();
    if (current > 0) {
      await _prefs?.setInt(_keyFloodSiphons, current - 1);
      return true;
    }
    return false;
  }

  static int getFortuneElixir() => _prefs?.getInt(_keyFortuneElixir) ?? 0;
  static Future<void> addFortuneElixir(int count) async {
    final current = getFortuneElixir();
    await _prefs?.setInt(_keyFortuneElixir, current + count);
  }
}
