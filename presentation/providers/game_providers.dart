// lib/presentation/providers/game_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/entities/game_engine.dart';
import '../../config/firebase_config.dart';

// 🎮 Game Engine Provider
final gameEngineProvider = StateNotifierProvider<GameEngineNotifier, GameState>((ref) {
  return GameEngineNotifier();
});

class GameEngineNotifier extends StateNotifier<GameState> {
  late GameEngine _engine;

  GameEngineNotifier()
      : super(GameState(
          tubes: [],
          moves: 0,
          elapsedTime: 0,
          isGameWon: false,
          isGameOver: false,
          moveHistory: [],
          score: 0,
        )) {
    _engine = GameEngine();
  }

  /// Initialize game with a level
  void initializeGame(GameLevel level) {
    _engine.initialize(level);
    state = _engine.currentState;
  }

  /// Move water from one tube to another
  bool moveWater(int fromTubeId, int toTubeId) {
    final success = _engine.moveWater(fromTubeId, toTubeId);
    if (success) {
      state = _engine.currentState;
    }
    return success;
  }

  /// Undo last move
  bool undo() {
    final success = _engine.undo();
    if (success) {
      state = _engine.currentState;
    }
    return success;
  }

  /// Reset game
  void reset() {
    _engine.reset();
    state = _engine.currentState;
  }

  /// Get current engine
  GameEngine get engine => _engine;

  /// Calculate final score
  int calculateFinalScore(int timeSpent) {
    return _engine.calculateScore(timeSpent);
  }

  /// Get max moves
  int getMaxMoves() => _engine.maxMoves;

  /// Get level
  GameLevel getLevel() => _engine.level;
}

// 🎮 Current Level Provider
final currentLevelProvider = StateProvider<GameLevel?>((ref) => null);

// 🎮 Available Levels Provider
final availableLevelsProvider = FutureProvider<List<GameLevel>>((ref) async {
  // Mock levels - replace with actual data from Firebase/local
  return _generateMockLevels();
});

/// Generate mock levels for testing
List<GameLevel> _generateMockLevels() {
  final levels = <GameLevel>[];

  // Level 1 - Easy
  levels.add(GameLevel(
    levelNumber: 1,
    difficulty: 'easy',
    minMoves: 3,
    baseScore: 100,
    initialTubes: [
      TestTube(
        id: 0,
        colors: ['red', 'red', 'blue', 'transparent'],
      ),
      TestTube(
        id: 1,
        colors: ['blue', 'red', 'transparent', 'transparent'],
      ),
      TestTube(
        id: 2,
        colors: ['transparent', 'transparent', 'transparent', 'transparent'],
      ),
    ],
    timeLimit: 300,
  ));

  // Level 2 - Easy
  levels.add(GameLevel(
    levelNumber: 2,
    difficulty: 'easy',
    minMoves: 4,
    baseScore: 120,
    initialTubes: [
      TestTube(
        id: 0,
        colors: ['red', 'blue', 'green', 'transparent'],
      ),
      TestTube(
        id: 1,
        colors: ['green', 'red', 'transparent', 'transparent'],
      ),
      TestTube(
        id: 2,
        colors: ['blue', 'transparent', 'transparent', 'transparent'],
      ),
      TestTube(
        id: 3,
        colors: ['transparent', 'transparent', 'transparent', 'transparent'],
      ),
    ],
    timeLimit: 300,
  ));

  // Add more levels as needed...
  for (int i = 3; i <= 50; i++) {
    levels.add(_generateRandomLevel(i));
  }

  return levels;
}

/// Generate a random level
GameLevel _generateRandomLevel(int levelNumber) {
  final colors = ['red', 'blue', 'green', 'yellow', 'purple', 'orange'];
  final difficulty = _getDifficultyByLevel(levelNumber);
  final tubeCount = 3 + (levelNumber ~/ 10);
  final colorCount = 3 + (levelNumber ~/ 15);

  final tubes = <TestTube>[];
  for (int i = 0; i < tubeCount; i++) {
    final tubeColors = <String>[];
    for (int j = 0; j < 4; j++) {
      if (i < colorCount && j < 4 - (tubeCount - colorCount)) {
        tubeColors.add(colors[i % colors.length]);
      } else {
        tubeColors.add('transparent');
      }
    }
    tubes.add(TestTube(id: i, colors: tubeColors));
  }

  return GameLevel(
    levelNumber: levelNumber,
    difficulty: difficulty,
    minMoves: 5 + (levelNumber ~/ 5),
    baseScore: 100 + (levelNumber * 10),
    initialTubes: tubes,
    timeLimit: 300 + (levelNumber * 10),
  );
}

String _getDifficultyByLevel(int levelNumber) {
  if (levelNumber <= 15) return 'easy';
  if (levelNumber <= 30) return 'medium';
  if (levelNumber <= 45) return 'hard';
  if (levelNumber <= 60) return 'very_hard';
  return 'impossible';
}

// 💰 User Coins Provider
final userCoinsProvider = StateProvider<int>((ref) => 0);

// 🏆 User Score Provider
final userScoreProvider = StateProvider<int>((ref) => 0);

// ⏱️ Timer Provider
final timerProvider = StateProvider<int>((ref) => 0);

// 📊 Game Stats Provider
final gameStatsProvider = FutureProvider((ref) async {
  final auth = FirebaseConfig.instance.auth;
  final currentUser = auth.currentUser;
  
  if (currentUser == null) return null;
  
  // Fetch user stats from Firebase
  return await FirebaseConfig.instance.firestore
      .collection('users')
      .doc(currentUser.uid)
      .get();
});

// 🏅 Leaderboard Provider
final leaderboardProvider = FutureProvider((ref) async {
  try {
    final result = await FirebaseConfig.instance.getMonthlyLeaderboard();
    return result.docs;
  } catch (e) {
    print('❌ Error fetching leaderboard: $e');
    return [];
  }
});
