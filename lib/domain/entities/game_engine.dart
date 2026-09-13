// lib/domain/entities/game_engine.dart

import 'dart:math';

/// 🎨 طبقة واحدة من السائل داخل الأنبوب
class TubeLayer {
  final String color; // 'red', 'blue', 'green', 'yellow', 'purple', 'orange', 'cyan', 'pink', 'rainbow', 'transparent'
  final bool isMystery; // هل السائل مجهول الهوية؟
  final bool isRevealed; // هل تم كشف السائل المجهول؟

  const TubeLayer({
    required this.color,
    this.isMystery = false,
    this.isRevealed = false,
  });

  /// اللون الفعلي المعروض للمستخدم
  String get displayColor {
    if (isMystery && !isRevealed) {
      return 'mystery';
    }
    return color;
  }

  TubeLayer copyWith({
    String? color,
    bool? isMystery,
    bool? isRevealed,
  }) {
    return TubeLayer(
      color: color ?? this.color,
      isMystery: isMystery ?? this.isMystery,
      isRevealed: isRevealed ?? this.isRevealed,
    );
  }

}

/// 🧪 نموذج الأنبوب المخبري (Test Tube)
class TestTube {
  final int id;
  final List<TubeLayer> layers; // [قاع الأنبوب ... قمة الأنبوب]
  final int maxCapacity;
  final bool isLocked; // هل الأنبوب مغلق بسلسلة وقفل؟
  final String? unlockCondition;
  final bool isBomb; // هل هو أنبوب قنبلة موقوتة؟
  final int? bombCountdown; // عدد الحركات المتبقية قبل الانفجار

  const TestTube({
    required this.id,
    required this.layers,
    this.maxCapacity = 4,
    this.isLocked = false,
    this.unlockCondition,
    this.isBomb = false,
    this.bombCountdown,
  });

  /// قائمة الألوان كنصوص للتوافق
  List<String> get colors => layers.map((l) => l.color).toList();

  /// الحصول على الطبقة العلوية غير الشفافة
  TubeLayer? getTopLayer() {
    for (int i = layers.length - 1; i >= 0; i--) {
      if (layers[i].color != 'transparent') {
        return layers[i];
      }
    }
    return null;
  }

  /// الحصول على لون الماء العلوي
  String? getTopColor() {
    return getTopLayer()?.color;
  }

  /// هل الطبقة العلوية ما زالت مجهولة؟
  bool isTopMystery() {
    final top = getTopLayer();
    return top != null && top.isMystery && !top.isRevealed;
  }

  /// عدد طبقات السائل الحالية
  int getColorCount() {
    return layers.where((l) => l.color != 'transparent').length;
  }

  /// المساحة الفارغة المتوفرة للصب
  int getAvailableSpace() {
    return maxCapacity - getColorCount();
  }

  /// هل الأنبوب ممتلئ تماماً؟
  bool isFull() => getColorCount() >= maxCapacity;

  /// هل الأنبوب فارغ تماماً؟
  bool isEmpty() => getColorCount() == 0;

  /// هل يحتوي الأنبوب على متسع؟
  bool hasSpace() => getAvailableSpace() > 0;

  /// التحقق من أن الأنبوب مفروز ومكتمل بنجاح (نفس اللون بالكامل ومكتمل السعة أو فارغ)
  bool isSorted() {
    final activeLayers = layers.where((l) => l.color != 'transparent').toList();
    if (activeLayers.isEmpty) return true; // الفارغ يعتبر مكتملاً

    // إذا لم يكتمل الأنبوب لكامل سعته لا يعتبر مفروزاً نهائياً
    if (activeLayers.length != maxCapacity) return false;

    // لا يجب أن يكون هناك أي سائل مجهول غير مكشوف
    if (activeLayers.any((l) => l.isMystery && !l.isRevealed)) return false;

    final firstColor = activeLayers.first.color;
    return activeLayers.every((l) => l.color == firstColor);
  }

  TestTube copyWith({
    int? id,
    List<TubeLayer>? layers,
    int? maxCapacity,
    bool? isLocked,
    String? unlockCondition,
    bool? isBomb,
    int? bombCountdown,
  }) {
    return TestTube(
      id: id ?? this.id,
      layers: layers ?? this.layers.map((l) => l.copyWith()).toList(),
      maxCapacity: maxCapacity ?? this.maxCapacity,
      isLocked: isLocked ?? this.isLocked,
      unlockCondition: unlockCondition ?? this.unlockCondition,
      isBomb: isBomb ?? this.isBomb,
      bombCountdown: bombCountdown ?? this.bombCountdown,
    );
  }

}

/// 🎯 أوضاع اللعبة المختلفة
enum GameMode {
  classic, // المستويات الكلاسيكية
  endless, // الوضع اللانهائي مع سلسلة الانتصارات
  timeRush, // سباق الوقت (90 ثانية)
  dailyChallenge, // التحدي اليومي
}

/// 🎮 مستوى اللعبة
class GameLevel {
  final int levelNumber;
  final GameMode mode;
  final String difficulty;
  final int minMoves;
  final int baseScore;
  final List<TestTube> initialTubes;
  final int timeLimit;
  final String worldName;
  final String? specialRule;

  const GameLevel({
    required this.levelNumber,
    this.mode = GameMode.classic,
    required this.difficulty,
    required this.minMoves,
    required this.baseScore,
    required this.initialTubes,
    required this.timeLimit,
    this.worldName = 'مختبر الكيمياء',
    this.specialRule,
  });

}

/// 🎮 حالة اللعبة الحية
class GameState {
  final List<TestTube> tubes;
  final int moves;
  final int elapsedTime;
  final bool isGameWon;
  final bool isGameOver;
  final String? gameOverReason; // 'out_of_moves', 'bomb_exploded', 'time_up'
  final List<(int, int)> moveHistory;
  final List<List<TestTube>> stateHistory;
  final int score;
  final int stars;
  final int streak;
  final int remainingTime;
  final (int, int)? hintMove; // أفضل حركة مقترحة (من، إلى)
  final int? pouringFromId;
  final int? pouringToId;

  const GameState({
    required this.tubes,
    required this.moves,
    required this.elapsedTime,
    required this.isGameWon,
    required this.isGameOver,
    this.gameOverReason,
    required this.moveHistory,
    required this.stateHistory,
    required this.score,
    this.stars = 0,
    this.streak = 0,
    this.remainingTime = 90,
    this.hintMove,
    this.pouringFromId,
    this.pouringToId,
  });

  GameState copyWith({
    List<TestTube>? tubes,
    int? moves,
    int? elapsedTime,
    bool? isGameWon,
    bool? isGameOver,
    String? gameOverReason,
    List<(int, int)>? moveHistory,
    List<List<TestTube>>? stateHistory,
    int? score,
    int? stars,
    int? streak,
    int? remainingTime,
    (int, int)? hintMove,
    int? pouringFromId,
    int? pouringToId,
    bool clearHint = false,
    bool clearPouring = false,
  }) {
    return GameState(
      tubes: tubes ?? this.tubes,
      moves: moves ?? this.moves,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      isGameWon: isGameWon ?? this.isGameWon,
      isGameOver: isGameOver ?? this.isGameOver,
      gameOverReason: gameOverReason ?? this.gameOverReason,
      moveHistory: moveHistory ?? this.moveHistory,
      stateHistory: stateHistory ?? this.stateHistory,
      score: score ?? this.score,
      stars: stars ?? this.stars,
      streak: streak ?? this.streak,
      remainingTime: remainingTime ?? this.remainingTime,
      hintMove: clearHint ? null : (hintMove ?? this.hintMove),
      pouringFromId: clearPouring ? null : (pouringFromId ?? this.pouringFromId),
      pouringToId: clearPouring ? null : (pouringToId ?? this.pouringToId),
    );
  }

}

/// 🎮 محرك اللعبة المتطور والذكي
class GameEngine {
  late GameState _currentState;
  late GameLevel _level;
  int _maxMoves = 50;

  void initialize(GameLevel level, {int initialStreak = 0}) {
    _level = level;
    _maxMoves = level.minMoves + 15;

    final clonedTubes = _copyTubes(level.initialTubes);

    // كشف أي طبقة مجهولة عليا فوراً
    for (var tube in clonedTubes) {
      final topLayer = tube.getTopLayer();
      if (topLayer != null && topLayer.isMystery && !topLayer.isRevealed) {
        final topIdx = tube.layers.indexOf(topLayer);
        tube.layers[topIdx] = topLayer.copyWith(isRevealed: true);
      }
    }

    _currentState = GameState(
      tubes: clonedTubes,
      moves: 0,
      elapsedTime: 0,
      isGameWon: false,
      isGameOver: false,
      moveHistory: [],
      stateHistory: [_copyTubes(clonedTubes)],
      score: 0,
      stars: 0,
      streak: initialStreak,
      remainingTime: level.timeLimit,
    );
  }

  GameState get currentState => _currentState;
  GameLevel get level => _level;
  int get maxMoves => _maxMoves;

  /// نقل الماء بحساب كمية السوائل والمساحة ومنع الطفح
  bool moveWater(int fromTubeId, int toTubeId) {
    if (fromTubeId == toTubeId) return false;
    if (_currentState.isGameWon || _currentState.isGameOver) return false;

    final fromTube = _currentState.tubes.firstWhere((t) => t.id == fromTubeId);
    final toTube = _currentState.tubes.firstWhere((t) => t.id == toTubeId);

    // الأنبوب الهدف مقفل
    if (toTube.isLocked || fromTube.isLocked) return false;

    // التحقق من صلاحية النقل
    if (!_isValidMove(fromTube, toTube)) return false;

    // تنفيذ الحركة وحفظ لقطة التراجع
    _executeMove(fromTubeId, toTubeId);
    return true;
  }

  /// التحقق من قواعد الصب
  bool _isValidMove(TestTube from, TestTube to) {
    final fromLayer = from.getTopLayer();
    if (fromLayer == null) return false;

    if (!to.hasSpace()) return false;

    final toLayer = to.getTopLayer();
    if (toLayer == null) return true; // الصب في أنبوب فارغ مسموح دائماً

    // السائل الملون يطابق الهدف، أو أحدهما جوكر قوس قزح
    return fromLayer.color == toLayer.color ||
        fromLayer.color == 'rainbow' ||
        toLayer.color == 'rainbow';
  }

  /// تنفيذ حركة الصب مع الكشف عن السوائل المجهولة والتحقق من القنابل
  void _executeMove(int fromId, int toId) {
    // حفظ لقطة من الحالة الحالية للتراجع
    final historySnapshot = _copyTubes(_currentState.tubes);

    final newTubes = _copyTubes(_currentState.tubes);
    final fromTube = newTubes.firstWhere((t) => t.id == fromId);
    final toTube = newTubes.firstWhere((t) => t.id == toId);

    final fromLayer = fromTube.getTopLayer()!;
    final colorToMove = fromLayer.color;

    // حساب عدد الطبقات المتطابقة المتتالية في الأعلى
    int consecutiveMatching = 0;
    for (int i = fromTube.layers.length - 1; i >= 0; i--) {
      final layer = fromTube.layers[i];
      if (layer.color == 'transparent') continue;
      if (layer.color == colorToMove) {
        consecutiveMatching++;
      } else {
        break;
      }
    }

    // الكمية المنقولة = الأقل بين المتتالي والمساحة المتوفرة في الهدف
    final availableSpace = toTube.getAvailableSpace();
    final amountToTransfer = min(consecutiveMatching, availableSpace);

    // 1. إزالة السائل من المصدر
    int removed = 0;
    for (int i = fromTube.layers.length - 1; i >= 0; i--) {
      if (fromTube.layers[i].color == colorToMove && removed < amountToTransfer) {
        fromTube.layers[i] = const TubeLayer(color: 'transparent');
        removed++;
      }
    }

    // كشف السائل المجهول الذي انكشف أسفله
    final newTop = fromTube.getTopLayer();
    if (newTop != null && newTop.isMystery && !newTop.isRevealed) {
      final topIdx = fromTube.layers.indexOf(newTop);
      fromTube.layers[topIdx] = newTop.copyWith(isRevealed: true);
    }

    // 2. إضافة السائل إلى الهدف
    int added = 0;
    for (int i = 0; i < toTube.layers.length; i++) {
      if (toTube.layers[i].color == 'transparent' && added < amountToTransfer) {
        toTube.layers[i] = TubeLayer(
          color: colorToMove,
          isMystery: false,
          isRevealed: true,
        );
        added++;
      }
    }

    // 3. تحديث عدادات القنابل الموقوتة إن وجدت
    bool bombExploded = false;
    for (int i = 0; i < newTubes.length; i++) {
      final t = newTubes[i];
      if (t.isBomb && t.bombCountdown != null) {
        if (t.isSorted()) {
          // تم إبطال مفعول القنبلة بفرز الأنبوب!
          newTubes[i] = t.copyWith(isBomb: false, bombCountdown: null);
        } else {
          final nextCount = t.bombCountdown! - 1;
          if (nextCount <= 0) {
            bombExploded = true;
            newTubes[i] = t.copyWith(bombCountdown: 0);
          } else {
            newTubes[i] = t.copyWith(bombCountdown: nextCount);
          }
        }
      }
    }

    // 4. فتح الأنابيب المقفلة إذا تم إكمال أي أنبوب
    final anySorted = newTubes.any((t) => t.isSorted() && !t.isEmpty());
    if (anySorted) {
      for (int i = 0; i < newTubes.length; i++) {
        if (newTubes[i].isLocked) {
          newTubes[i] = newTubes[i].copyWith(isLocked: false);
        }
      }
    }

    final newMoves = _currentState.moves + 1;
    final isWon = _checkIfWon(newTubes);
    final isGameOver = bombExploded ||
        (newMoves >= _maxMoves && !isWon && _level.mode == GameMode.classic);

    final stars = isWon ? _calculateStars(newMoves, _currentState.elapsedTime) : 0;
    final score = isWon ? calculateScore(_currentState.elapsedTime) : _currentState.score;

    _currentState = _currentState.copyWith(
      tubes: newTubes,
      moves: newMoves,
      moveHistory: [..._currentState.moveHistory, (fromId, toId)],
      stateHistory: [..._currentState.stateHistory, historySnapshot],
      isGameWon: isWon,
      isGameOver: isGameOver,
      gameOverReason: bombExploded ? 'bomb_exploded' : (isGameOver ? 'out_of_moves' : null),
      stars: stars,
      score: score,
      clearHint: true,
      pouringFromId: fromId,
      pouringToId: toId,
    );
  }

  /// التحقق من الفوز
  bool _checkIfWon(List<TestTube> tubes) {
    return tubes.every((tube) => tube.isSorted());
  }

  /// حساب عدد النجوم المستحقة
  int _calculateStars(int moves, int time) {
    if (moves <= _level.minMoves + 2 && time <= 60) {
      return 3;
    } else if (moves <= _level.minMoves + 7) {
      return 2;
    }
    return 1;
  }

  /// حساب النقاط
  int calculateScore(int timeSpent) {
    int baseScore = _level.baseScore;
    int movesPenalty = (_currentState.moves - _level.minMoves).abs() * 15;
    int timePenalty = timeSpent > 90 ? (timeSpent - 90) * 3 : 0;
    int finalScore = baseScore - movesPenalty - timePenalty;
    if (_currentState.stars == 3) finalScore += 150;
    if (_currentState.streak > 0) finalScore += _currentState.streak * 50;
    return max(finalScore, 100);
  }

  /// التراجع الدقيق عن الحركة
  bool undo() {
    if (_currentState.stateHistory.length <= 1) return false;

    final history = [..._currentState.stateHistory];
    final previousTubes = history.removeLast();

    final moveHist = [..._currentState.moveHistory];
    if (moveHist.isNotEmpty) moveHist.removeLast();

    _currentState = _currentState.copyWith(
      tubes: previousTubes,
      moves: max(0, _currentState.moves - 1),
      stateHistory: history,
      moveHistory: moveHist,
      isGameWon: false,
      isGameOver: false,
      clearHint: true,
      clearPouring: true,
    );
    return true;
  }

  /// ميزة القوة: إضافة أنبوب فارغ إضافي (+1 Tube)
  bool addExtraTube() {
    if (_currentState.isGameWon || _currentState.isGameOver) return false;

    final currentTubes = [..._currentState.tubes];
    final newId = currentTubes.map((t) => t.id).reduce(max) + 1;

    final emptyLayers = List.generate(
      4,
      (_) => const TubeLayer(color: 'transparent'),
    );

    currentTubes.add(TestTube(id: newId, layers: emptyLayers));

    _currentState = _currentState.copyWith(
      tubes: currentTubes,
      clearHint: true,
    );
    return true;
  }

  /// ميزة القوة: إعادة خلط ذكية للسوائل غير المفروزة
  bool shuffleRemaining() {
    if (_currentState.isGameWon || _currentState.isGameOver) return false;

    final newTubes = _copyTubes(_currentState.tubes);
    final colorsToShuffle = <String>[];

    // جمع ألوان الأنابيب غير المكتملة
    for (var tube in newTubes) {
      if (!tube.isSorted()) {
        for (var layer in tube.layers) {
          if (layer.color != 'transparent') {
            colorsToShuffle.add(layer.color);
          }
        }
      }
    }

    if (colorsToShuffle.isEmpty) return false;
    colorsToShuffle.shuffle();

    // إعادة توزيعها
    int colorIdx = 0;
    for (var tube in newTubes) {
      if (!tube.isSorted()) {
        for (int i = 0; i < tube.layers.length; i++) {
          if (tube.layers[i].color != 'transparent' && colorIdx < colorsToShuffle.length) {
            tube.layers[i] = tube.layers[i].copyWith(
              color: colorsToShuffle[colorIdx++],
            );
          }
        }
      }
    }

    _currentState = _currentState.copyWith(
      tubes: newTubes,
      clearHint: true,
    );
    return true;
  }

  /// الذكاء الاصطناعي لاقتراح الحركة المثالية التالية (Smart AI Hint)
  (int, int)? getSmartHint() {
    final tubes = _currentState.tubes;

    // 1. أولوية قصوى: صب نحو أنبوب غير مكتمل لإنهاء فرزه
    for (var from in tubes) {
      if (from.isLocked || from.isEmpty()) continue;
      final fromTop = from.getTopLayer();
      if (fromTop == null) continue;

      for (var to in tubes) {
        if (to.id == from.id || to.isLocked || to.isFull()) continue;
        final toTop = to.getTopLayer();

        if (toTop != null && toTop.color == fromTop.color) {
          // نقل ممتاز يجمع ألواناً متطابقة
          _currentState = _currentState.copyWith(hintMove: (from.id, to.id));
          return (from.id, to.id);
        }
      }
    }

    // 2. صب نحو أنبوب فارغ لتفريغ سائل وكشف سائل مجهول
    for (var from in tubes) {
      if (from.isLocked || from.isEmpty() || from.isSorted()) continue;
      for (var to in tubes) {
        if (to.id == from.id || to.isLocked) continue;
        if (to.isEmpty()) {
          _currentState = _currentState.copyWith(hintMove: (from.id, to.id));
          return (from.id, to.id);
        }
      }
    }

    return null;
  }

  void reset() {
    initialize(_level, initialStreak: _currentState.streak);
  }

  void tickTimeRush() {
    if (_currentState.isGameWon || _currentState.isGameOver) return;
    final nextTime = _currentState.remainingTime - 1;
    if (nextTime <= 0) {
      _currentState = _currentState.copyWith(
        remainingTime: 0,
        isGameOver: true,
        gameOverReason: 'time_up',
      );
    } else {
      _currentState = _currentState.copyWith(
        remainingTime: nextTime,
        elapsedTime: _currentState.elapsedTime + 1,
      );
    }
  }

  List<TestTube> _copyTubes(List<TestTube> tubes) {
    return tubes.map((t) => t.copyWith()).toList();
  }
}
