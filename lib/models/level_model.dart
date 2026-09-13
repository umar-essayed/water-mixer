import 'tube_model.dart';

class LevelModel {
  final int levelNumber;
  final List<TubeModel> initialTubes;
  final int minMoves;
  final int? maxMoves;          // Limited Moves Mode (null for unlimited casual mode)
  final int? timeLimitSeconds;  // Timer Mode (null for unlimited casual mode)
  final int starsEarned;
  final bool isCompleted;
  final bool isUnlocked;
  final bool isBossLevel;

  const LevelModel({
    required this.levelNumber,
    required this.initialTubes,
    this.minMoves = 12,
    this.maxMoves,
    this.timeLimitSeconds,
    this.starsEarned = 0,
    this.isCompleted = false,
    this.isUnlocked = false,
    this.isBossLevel = false,
  });

  bool get hasTimer => timeLimitSeconds != null && timeLimitSeconds! > 0;
  bool get hasMoveLimit => maxMoves != null && maxMoves! > 0;

  LevelModel copyWith({
    int? levelNumber,
    List<TubeModel>? initialTubes,
    int? minMoves,
    int? maxMoves,
    int? timeLimitSeconds,
    int? starsEarned,
    bool? isCompleted,
    bool? isUnlocked,
    bool? isBossLevel,
  }) {
    return LevelModel(
      levelNumber: levelNumber ?? this.levelNumber,
      initialTubes: initialTubes ?? this.initialTubes.map((t) => t.copyWith()).toList(),
      minMoves: minMoves ?? this.minMoves,
      maxMoves: maxMoves ?? this.maxMoves,
      timeLimitSeconds: timeLimitSeconds ?? this.timeLimitSeconds,
      starsEarned: starsEarned ?? this.starsEarned,
      isCompleted: isCompleted ?? this.isCompleted,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isBossLevel: isBossLevel ?? this.isBossLevel,
    );
  }

  List<TubeModel> cloneInitialTubes() {
    return initialTubes.map((t) => t.copyWith()).toList();
  }
}
