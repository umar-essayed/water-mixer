// lib/presentation/providers/game_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/game_engine.dart';
import '../../domain/services/level_generator.dart';
import '../../core/local_storage/game_storage.dart';

// 🎮 Game Engine Provider
final gameEngineProvider =
    StateNotifierProvider<GameEngineNotifier, GameState>((ref) {
  return GameEngineNotifier(ref);
});

class GameEngineNotifier extends StateNotifier<GameState> {
  final Ref _ref;
  late GameEngine _engine;

  GameEngineNotifier(this._ref)
      : super(const GameState(
          tubes: [],
          moves: 0,
          elapsedTime: 0,
          isGameWon: false,
          isGameOver: false,
          moveHistory: [],
          stateHistory: [],
          score: 0,
        )) {
    _engine = GameEngine();
  }

  /// تهيئة اللعبة بمستوى محدد
  void initializeGame(GameLevel level, {int streak = 0}) {
    _engine.initialize(level, initialStreak: streak);
    state = _engine.currentState;
  }

  /// نقل الماء بين أنبوبين
  bool moveWater(int fromTubeId, int toTubeId) {
    final success = _engine.moveWater(fromTubeId, toTubeId);
    if (success) {
      state = _engine.currentState;

      // إذا فاز اللاعب، حفظ النتائج في التخزين المحلي فوراً
      if (state.isGameWon) {
        _handleGameWon();
      }
    }
    return success;
  }

  void _handleGameWon() async {
    final level = _engine.level;
    final stars = state.stars;
    final score = state.score;
    final coinsAward = 50 + (stars * 25) + (state.streak * 20);

    await GameStorage.addCoins(coinsAward);
    _ref.read(playerCoinsProvider.notifier).state = GameStorage.getCoins();

    if (level.mode == GameMode.classic) {
      await GameStorage.saveLevelResult(
        level: level.levelNumber,
        stars: stars,
        score: score,
      );
    } else if (level.mode == GameMode.endless) {
      await GameStorage.saveEndlessResult(score, state.streak + 1);
    } else if (level.mode == GameMode.timeRush) {
      await GameStorage.saveTimeRushScore(score);
    } else if (level.mode == GameMode.dailyChallenge) {
      final now = DateTime.now();
      final dateKey = '${now.year}_${now.month}_${now.day}';
      await GameStorage.completeDailyChallenge(dateKey);
    }
  }

  /// التراجع عن آخر حركة
  bool undo() {
    final success = _engine.undo();
    if (success) {
      state = _engine.currentState;
    }
    return success;
  }

  /// إضافة أنبوب إضافي (+1 Tube)
  bool addExtraTube() {
    final success = _engine.addExtraTube();
    if (success) {
      state = _engine.currentState;
    }
    return success;
  }

  /// إعادة خلط السوائل المتبقية
  bool shuffleRemaining() {
    final success = _engine.shuffleRemaining();
    if (success) {
      state = _engine.currentState;
    }
    return success;
  }

  /// طلب تلميح ذكي من الذكاء الاصطناعي
  (int, int)? getSmartHint() {
    final hint = _engine.getSmartHint();
    if (hint != null) {
      state = _engine.currentState;
    }
    return hint;
  }

  /// عداد الثواني
  void tickTimer() {
    if (state.isGameWon || state.isGameOver) return;

    if (_engine.level.mode == GameMode.timeRush) {
      _engine.tickTimeRush();
      state = _engine.currentState;
    } else {
      state = state.copyWith(elapsedTime: state.elapsedTime + 1);
    }
  }

  /// إعادة تعيين المستوى
  void reset() {
    _engine.reset();
    state = _engine.currentState;
  }

  GameEngine get engine => _engine;
  int getMaxMoves() => _engine.maxMoves;
  GameLevel getLevel() => _engine.level;
}

// 💰 مزود عملات اللاعب
final playerCoinsProvider = StateProvider<int>((ref) => GameStorage.getCoins());

// 🗺️ مزود المستويات المتاحة
final availableLevelsProvider =
    Provider.family<GameLevel, int>((ref, levelNumber) {
  return LevelGenerator.generateLevel(levelNumber);
});
