import 'tube_model.dart';

enum GameStatus {
  idle,
  selected,
  animating,
  won,
  gameOver,
}

class GameStateModel {
  final List<TubeModel> tubes;
  final String? selectedTubeId;
  final int moveCount;
  final GameStatus status;
  final int coins;
  final int currentLevel;
  final List<List<TubeModel>> historyStack;

  const GameStateModel({
    required this.tubes,
    this.selectedTubeId,
    this.moveCount = 0,
    this.status = GameStatus.idle,
    this.coins = 0,
    this.currentLevel = 1,
    this.historyStack = const [],
  });

  bool get canUndo => historyStack.isNotEmpty && status != GameStatus.animating;
  bool get isWon => status == GameStatus.won;
  bool get isGameOver => status == GameStatus.gameOver;
  bool get isAnimating => status == GameStatus.animating;

  GameStateModel copyWith({
    List<TubeModel>? tubes,
    String? selectedTubeId,
    bool clearSelection = false,
    int? moveCount,
    GameStatus? status,
    int? coins,
    int? currentLevel,
    List<List<TubeModel>>? historyStack,
  }) {
    return GameStateModel(
      tubes: tubes ?? this.tubes.map((t) => t.copyWith()).toList(),
      selectedTubeId: clearSelection ? null : (selectedTubeId ?? this.selectedTubeId),
      moveCount: moveCount ?? this.moveCount,
      status: status ?? this.status,
      coins: coins ?? this.coins,
      currentLevel: currentLevel ?? this.currentLevel,
      historyStack: historyStack ?? this.historyStack.map((h) => h.map((t) => t.copyWith()).toList()).toList(),
    );
  }
}
