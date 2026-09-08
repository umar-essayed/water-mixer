// lib/domain/entities/game_engine.dart

import 'package:equatable/equatable.dart';

/// 🎮 نموذج الأنبوب الاختبار (Test Tube)
class TestTube extends Equatable {
  final int id;
  final List<String> colors; // [bottom, ..., top]
  final int maxCapacity;

  const TestTube({
    required this.id,
    required this.colors,
    this.maxCapacity = 4,
  });

  /// الحصول على لون الماء العلوي
  String? getTopColor() {
    if (colors.isEmpty) return null;
    for (int i = colors.length - 1; i >= 0; i--) {
      if (colors[i] != 'transparent') return colors[i];
    }
    return null;
  }

  /// التحقق من امتلاء الأنبوب
  bool isFull() => colors.where((c) => c != 'transparent').length >= maxCapacity;

  /// التحقق من عدم امتلاء الأنبوب
  bool hasSpace() => !isFull();

  /// الحصول على عدد الألوان في الأنبوب
  int getColorCount() => colors.where((c) => c != 'transparent').length;

  /// التحقق من أن جميع الألوان متطابقة
  bool isSorted() {
    final nonTransparent = colors.where((c) => c != 'transparent').toList();
    if (nonTransparent.isEmpty) return true;
    return nonTransparent.every((color) => color == nonTransparent.first);
  }

  /// نسخ الأنبوب بتعديلات
  TestTube copyWith({
    int? id,
    List<String>? colors,
    int? maxCapacity,
  }) {
    return TestTube(
      id: id ?? this.id,
      colors: colors ?? [...this.colors],
      maxCapacity: maxCapacity ?? this.maxCapacity,
    );
  }

  @override
  List<Object?> get props => [id, colors, maxCapacity];
}

/// 🎮 مستوى اللعبة (Level)
class GameLevel extends Equatable {
  final int levelNumber;
  final String difficulty; // easy, medium, hard, very_hard, impossible
  final int minMoves;
  final int baseScore;
  final List<TestTube> initialTubes;
  final int timeLimit; // بالثواني

  const GameLevel({
    required this.levelNumber,
    required this.difficulty,
    required this.minMoves,
    required this.baseScore,
    required this.initialTubes,
    required this.timeLimit,
  });

  @override
  List<Object?> get props => [
    levelNumber,
    difficulty,
    minMoves,
    baseScore,
    initialTubes,
    timeLimit,
  ];
}

/// 🎮 حالة اللعبة (Game State)
class GameState extends Equatable {
  final List<TestTube> tubes;
  final int moves;
  final int elapsedTime; // بالثواني
  final bool isGameWon;
  final bool isGameOver;
  final List<(int, int)> moveHistory; // (from, to)
  final int score;

  const GameState({
    required this.tubes,
    required this.moves,
    required this.elapsedTime,
    required this.isGameWon,
    required this.isGameOver,
    required this.moveHistory,
    required this.score,
  });

  GameState copyWith({
    List<TestTube>? tubes,
    int? moves,
    int? elapsedTime,
    bool? isGameWon,
    bool? isGameOver,
    List<(int, int)>? moveHistory,
    int? score,
  }) {
    return GameState(
      tubes: tubes ?? this.tubes,
      moves: moves ?? this.moves,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      isGameWon: isGameWon ?? this.isGameWon,
      isGameOver: isGameOver ?? this.isGameOver,
      moveHistory: moveHistory ?? this.moveHistory,
      score: score ?? this.score,
    );
  }

  @override
  List<Object?> get props => [
    tubes,
    moves,
    elapsedTime,
    isGameWon,
    isGameOver,
    moveHistory,
    score,
  ];
}

/// 🎮 محرك اللعبة الأساسي
class GameEngine {
  late GameState _currentState;
  late GameLevel _level;
  
  int _maxMoves = 50;
  bool _canMove = true;

  /// تهيئة محرك اللعبة
  void initialize(GameLevel level) {
    _level = level;
    _maxMoves = level.minMoves + 10;
    _currentState = GameState(
      tubes: _copyTubes(level.initialTubes),
      moves: 0,
      elapsedTime: 0,
      isGameWon: false,
      isGameOver: false,
      moveHistory: [],
      score: 0,
    );
  }

  /// الحصول على الحالة الحالية
  GameState get currentState => _currentState;

  /// نقل الماء من أنبوب لآخر
  bool moveWater(int fromTubeId, int toTubeId) {
    if (!_canMove) return false;
    if (fromTubeId == toTubeId) return false;
    if (_currentState.isGameWon || _currentState.isGameOver) return false;

    final fromTube = _currentState.tubes[fromTubeId];
    final toTube = _currentState.tubes[toTubeId];

    // التحقق من صحة الحركة
    if (!_isValidMove(fromTube, toTube)) {
      return false;
    }

    // تنفيذ الحركة
    _executeMove(fromTubeId, toTubeId);

    return true;
  }

  /// التحقق من صحة الحركة
  bool _isValidMove(TestTube from, TestTube to) {
    // ✅ يجب أن يكون في الأنبوب المصدر ماء
    final fromColor = from.getTopColor();
    if (fromColor == null) return false;

    // ✅ الأنبوب الهدف إما فارغ أو نفس اللون
    final toColor = to.getTopColor();
    if (toColor != null && toColor != fromColor) return false;

    // ✅ الأنبوب الهدف لديه مساحة
    if (!to.hasSpace()) return false;

    return true;
  }

  /// تنفيذ الحركة
  void _executeMove(int fromId, int toId) {
    final newTubes = _copyTubes(_currentState.tubes);
    final fromTube = newTubes[fromId];
    final toTube = newTubes[toId];

    // البحث عن آخر ماء ملون في الأنبوب المصدر
    final fromColor = fromTube.getTopColor();
    if (fromColor == null) return;

    // نسخ جميع الألوان المتتالية من نفس النوع
    final colorsToMove = _getConsecutiveColors(fromTube, fromColor);

    // إزالة من المصدر
    for (int i = 0; i < colorsToMove; i++) {
      fromTube.colors[fromTube.colors.length - 1 - i] = 'transparent';
    }

    // إضافة للهدف
    int addIndex = 0;
    for (int i = 0; i < toTube.colors.length; i++) {
      if (toTube.colors[i] == 'transparent') {
        addIndex = i;
        break;
      }
    }

    for (int i = 0; i < colorsToMove; i++) {
      toTube.colors[addIndex + i] = fromColor;
    }

    // تحديث الحالة
    final newMoveHistory = [..._currentState.moveHistory, (fromId, toId)];
    int newMoves = _currentState.moves + 1;

    _currentState = _currentState.copyWith(
      tubes: newTubes,
      moves: newMoves,
      moveHistory: newMoveHistory,
      isGameWon: _checkIfWon(newTubes),
      isGameOver: newMoves >= _maxMoves && !_checkIfWon(newTubes),
    );
  }

  /// الحصول على عدد الألوان المتتالية
  int _getConsecutiveColors(TestTube tube, String color) {
    int count = 0;
    for (int i = tube.colors.length - 1; i >= 0; i--) {
      if (tube.colors[i] == color) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  /// التحقق من الفوز
  bool _checkIfWon(List<TestTube> tubes) {
    return tubes.every((tube) => tube.isSorted());
  }

  /// حساب النقاط
  int calculateScore(int timeSpent) {
    if (!_currentState.isGameWon) return 0;

    int baseScore = _level.baseScore;
    int movesPenalty = (_currentState.moves - _level.minMoves).abs() * 10;
    int timeBound = timeSpent > 120 ? (timeSpent - 120) * 5 : 0;

    // مكافأة الأداء المثالي
    int bonusMultiplier = 100;
    if (_currentState.moves <= _level.minMoves) {
      bonusMultiplier = 150; // Perfect
    } else if (_currentState.moves <= _level.minMoves + 5) {
      bonusMultiplier = 125; // Good
    }

    int finalScore = ((baseScore - movesPenalty - timeBound) * bonusMultiplier) ~/ 100;
    return finalScore > 0 ? finalScore : 100;
  }

  /// التراجع عن آخر حركة
  bool undo() {
    if (_currentState.moveHistory.isEmpty) return false;

    final lastMove = _currentState.moveHistory.last;
    final fromId = lastMove.$1;
    final toId = lastMove.$2;

    // العكس: نقل من toId إلى fromId
    _executeMove(toId, fromId);

    // إزالة من السجل
    final newHistory = [..._currentState.moveHistory];
    newHistory.removeLast();
    _currentState = _currentState.copyWith(
      moveHistory: newHistory,
      moves: _currentState.moves - 1,
    );

    return true;
  }

  /// نسخ الأنابيب
  List<TestTube> _copyTubes(List<TestTube> tubes) {
    return tubes.map((t) => t.copyWith()).toList();
  }

  /// إعادة تعيين اللعبة
  void reset() {
    initialize(_level);
  }

  /// الحصول على حد الحركات الأقصى
  int get maxMoves => _maxMoves;

  /// الحصول على المستوى الحالي
  GameLevel get level => _level;
}
