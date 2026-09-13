import 'dart:async';
import 'package:flutter/material.dart';
import '../models/tube_model.dart';
import '../models/game_state_model.dart';
import '../models/level_model.dart';
import '../core/utils/level_generator.dart';
import '../core/utils/persistence_manager.dart';
import '../core/utils/audio_manager.dart';

class GameProvider extends ChangeNotifier {
  late GameStateModel _state;
  LevelModel? _currentLevelModel;
  int _maxUnlockedLevel = 1;

  // Timer Challenge Mode
  Timer? _levelTimer;
  int? _timeRemaining;

  // Skin & Perk inventory
  String _activeTubeSkin = 'classic';
  List<String> _unlockedSkins = ['classic'];
  int _freeUndos = 0;
  int _unlockKeys = 0;
  bool _doubleCoins = false;
  bool _isPro = false;
  bool _hasPermanentExtraTube = false;
  int _colorRadarCharges = 0;
  int _timeFreezes = 0;

  // Fever & Combo Mode
  int _comboCount = 0;
  bool _isFeverMode = false;
  DateTime? _lastMoveTime;
  Timer? _comboResetTimer;

  // Animation transfer callback data for synchronized physical animations
  String? _animatingSourceId;
  String? _animatingTargetId;
  Color? _animatingColor;
  int _animatingUnits = 0;

  GameProvider() {
    _maxUnlockedLevel = PersistenceManager.getMaxUnlockedLevel();
    final savedLevel = PersistenceManager.getCurrentLevel();
    final savedCoins = PersistenceManager.getTotalCoins();
    _activeTubeSkin = PersistenceManager.getActiveTubeSkin();
    _unlockedSkins = PersistenceManager.getUnlockedSkins();
    _freeUndos = PersistenceManager.getFreeUndos();
    _unlockKeys = PersistenceManager.getUnlockKeys();
    _isPro = PersistenceManager.isPro();
    _hasPermanentExtraTube = PersistenceManager.hasPermanentExtraTube();
    _colorRadarCharges = PersistenceManager.getColorRadarCount();
    _timeFreezes = PersistenceManager.getTimeFreezeCount();
    _doubleCoins = _isPro || PersistenceManager.hasDoubleCoins();

    _state = GameStateModel(
      tubes: const [],
      coins: savedCoins,
      currentLevel: savedLevel,
    );
    loadLevel(savedLevel);
  }

  // Getters
  GameStateModel get state => _state;
  LevelModel? get currentLevelModel => _currentLevelModel;
  List<TubeModel> get tubes => _state.tubes;
  String? get selectedTubeId => _state.selectedTubeId;
  int get moveCount => _state.moveCount;
  GameStatus get status => _state.status;
  int get coins => _state.coins;
  int get currentLevel => _state.currentLevel;
  int get maxUnlockedLevel => _maxUnlockedLevel;
  bool get canUndo => _state.canUndo;
  bool get isWon => _state.isWon;
  bool get isGameOver => _state.isGameOver;
  bool get isAnimating => _state.isAnimating;

  int get comboCount => _comboCount;
  bool get isFeverMode => _isFeverMode;

  String get activeTubeSkin => _activeTubeSkin;
  List<String> get unlockedSkins => _unlockedSkins;
  int get freeUndos => _freeUndos;
  int get unlockKeys => _unlockKeys;
  bool get doubleCoins => _doubleCoins;
  bool get hasDoubleCoins => _doubleCoins;
  bool get isPro => _isPro;
  bool get hasPermanentExtraTube => _hasPermanentExtraTube;
  int get colorRadarCharges => _colorRadarCharges;
  int get timeFreezes => _timeFreezes;

  int? get timeRemaining => _timeRemaining;
  bool _bonusTimePulse = false;
  bool get bonusTimePulse => _bonusTimePulse;
  int? get movesRemaining => (_currentLevelModel != null && _currentLevelModel!.hasMoveLimit)
      ? (_currentLevelModel!.maxMoves! - _state.moveCount).clamp(0, 9999)
      : null;

  String? get animatingSourceId => _animatingSourceId;
  String? get animatingTargetId => _animatingTargetId;
  Color? get animatingColor => _animatingColor;
  int get animatingUnits => _animatingUnits;

  void _startTimer() {
    _stopTimer();
    if (_timeRemaining == null || _timeRemaining! <= 0) return;
    _levelTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining != null && _timeRemaining! > 0) {
        _timeRemaining = _timeRemaining! - 1;
        if (_timeRemaining! <= 0) {
          _stopTimer();
          if (_state.status != GameStatus.won) {
            _state = _state.copyWith(status: GameStatus.gameOver);
            AudioManager().playInvalid();
          }
        }
        notifyListeners();
      } else {
        _stopTimer();
      }
    });
  }

  void _stopTimer() {
    _levelTimer?.cancel();
    _levelTimer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  /// Load level by number
  void loadLevel(int levelNumber) {
    _stopTimer();
    _currentLevelModel = LevelGenerator.generateLevel(levelNumber);
    _timeRemaining = _currentLevelModel?.timeLimitSeconds;

    final initialTubes = _currentLevelModel!.cloneInitialTubes();
    if (_hasPermanentExtraTube) {
      final extraId = 'extra_perm_$levelNumber';
      if (!initialTubes.any((t) => t.id == extraId)) {
        initialTubes.add(TubeModel(id: extraId, layers: const []));
      }
    }

    _state = _state.copyWith(
      tubes: initialTubes,
      clearSelection: true,
      moveCount: 0,
      status: GameStatus.idle,
      currentLevel: levelNumber,
      historyStack: [],
    );
    _animatingSourceId = null;
    _animatingTargetId = null;
    _animatingColor = null;
    _animatingUnits = 0;
    PersistenceManager.saveCurrentLevel(levelNumber);

    if (_currentLevelModel?.hasTimer == true) {
      _startTimer();
    }

    notifyListeners();
  }

  /// Reset current level
  void resetCurrentLevel() {
    if (_state.isAnimating) return;
    _stopTimer();
    AudioManager().playUndo();
    if (_currentLevelModel != null) {
      _timeRemaining = _currentLevelModel?.timeLimitSeconds;
      _state = _state.copyWith(
        tubes: _currentLevelModel!.cloneInitialTubes(),
        clearSelection: true,
        moveCount: 0,
        status: GameStatus.idle,
        historyStack: [],
      );
      if (_currentLevelModel?.hasTimer == true) {
        _startTimer();
      }
      notifyListeners();
    } else {
      loadLevel(_state.currentLevel);
    }
  }

  /// Select tube or execute pour with invalid feedback callback
  Future<void> handleTubeTap(
    String tubeId, {
    required Function(TubeModel source, TubeModel target, int units, Color color) onStartPour,
    required Function(String invalidTubeId) onInvalidTarget,
    Function(TubeModel lockedTube)? onLockedTubeTap,
  }) async {
    if (_state.status == GameStatus.animating ||
        _state.status == GameStatus.won ||
        _state.status == GameStatus.gameOver) {
      return;
    }

    final tappedTube = _state.tubes.firstWhere((t) => t.id == tubeId);

    // If tapped tube is locked, prompt to unlock
    if (tappedTube.isLocked) {
      if (onLockedTubeTap != null) {
        onLockedTubeTap(tappedTube);
      } else {
        AudioManager().playInvalid();
        onInvalidTarget(tubeId);
      }
      return;
    }

    // Step 1: No tube currently selected
    if (_state.selectedTubeId == null) {
      if (tappedTube.isEmpty) {
        AudioManager().playInvalid();
        onInvalidTarget(tubeId);
        return;
      }
      // If tube is already solved and full, no need to touch it
      if (tappedTube.isSolved && tappedTube.isFull) {
        AudioManager().playInvalid();
        onInvalidTarget(tubeId);
        return;
      }
      _state = _state.copyWith(
        selectedTubeId: tubeId,
        status: GameStatus.selected,
      );
      AudioManager().playSelect();
      notifyListeners();
      return;
    }

    // Step 2: A tube is already selected
    if (_state.selectedTubeId == tubeId) {
      // Deselect if tapping the same tube
      _state = _state.copyWith(
        clearSelection: true,
        status: GameStatus.idle,
      );
      AudioManager().playSelect();
      notifyListeners();
      return;
    }

    // Tapping a different tube -> Check if pour is valid
    final sourceTube = _state.tubes.firstWhere((t) => t.id == _state.selectedTubeId);
    if (sourceTube.canPourInto(tappedTube)) {
      final units = sourceTube.transferableUnitsTo(tappedTube);
      if (units > 0) {
        final movingColor = sourceTube.topColor!;
        
        // Save move snapshot to history stack before pour
        final newHistory = List<List<TubeModel>>.from(_state.historyStack)
          ..add(_state.tubes.map((t) => t.copyWith()).toList());

        _state = _state.copyWith(
          status: GameStatus.animating,
          historyStack: newHistory,
          moveCount: _state.moveCount + 1,
        );
        notifyListeners();

        // Trigger physical animation
        await onStartPour(sourceTube, tappedTube, units, movingColor);

        // Execute state update after animation finishes
        _executeLiquidTransfer(sourceTube.id, tappedTube.id, units, movingColor);
        return;
      }
    }

    // Invalid pour target!
    // Trigger invalid target vibration + shake + red glow on the tapped tube!
    AudioManager().playInvalid();
    onInvalidTarget(tubeId);
  }

  /// Completes the transfer inside state after physical animation finishes
  void _executeLiquidTransfer(String sourceId, String targetId, int units, Color color) {
    final updatedTubes = _state.tubes.map((tube) {
      if (tube.id == sourceId) {
        final newLayers = List<Color>.from(tube.layers);
        for (int i = 0; i < units; i++) {
          if (newLayers.isNotEmpty) newLayers.removeLast();
        }
        // Uncover mystery layer if top layer was removed
        final newHidden = tube.hiddenCount.clamp(0, (newLayers.length - 1).clamp(0, 99));
        return tube.copyWith(layers: newLayers, hiddenCount: newHidden);
      } else if (tube.id == targetId) {
        final newLayers = List<Color>.from(tube.layers);
        for (int i = 0; i < units; i++) {
          newLayers.add(color);
        }
        return tube.copyWith(layers: newLayers);
      }
      return tube.copyWith();
    }).toList();

    // Fast Combo & Fever Calculation
    final now = DateTime.now();
    if (_lastMoveTime != null && now.difference(_lastMoveTime!).inMilliseconds < 3800) {
      _comboCount++;
      if (_comboCount >= 3) {
        _isFeverMode = true;
      }
    } else {
      _comboCount = 1;
      _isFeverMode = false;
    }
    _lastMoveTime = now;
    _comboResetTimer?.cancel();
    _comboResetTimer = Timer(const Duration(milliseconds: 3900), () {
      _comboCount = 0;
      _isFeverMode = false;
      notifyListeners();
    });

    if (_comboCount > 1) {
      final comboBonus = _comboCount * 2;
      _state = _state.copyWith(coins: _state.coins + comboBonus);
      PersistenceManager.saveTotalCoins(_state.coins);
    }

    // Unstable Bomb Hazard Countdown Processing
    bool bombExploded = false;
    final finalTubes = updatedTubes.map((tube) {
      if (tube.bombCountdown != null) {
        if (tube.isSolved || tube.isEmpty) {
          // Bomb safely disarmed!
          _state = _state.copyWith(coins: _state.coins + 50);
          PersistenceManager.saveTotalCoins(_state.coins);
          AudioManager().playCoin();
          return tube.copyWith(clearBomb: true);
        }
        final newCount = tube.bombCountdown! - 1;
        if (newCount <= 0) {
          bombExploded = true;
        }
        return tube.copyWith(bombCountdown: newCount);
      }
      return tube;
    }).toList();

    final wasTargetSolved = _state.tubes.any((t) => t.id == targetId && t.isSolved);
    final isTargetNowSolved = finalTubes.any((t) => t.id == targetId && t.isSolved);

    // Check victory
    final won = finalTubes.every((t) => t.isSolved);
    if (!wasTargetSolved && isTargetNowSolved && !won) {
      AudioManager().playTubeDone();
      // Rush Bonus Time: Reward player with +12 seconds for solving any bottle!
      if (_timeRemaining != null && _timeRemaining! > 0) {
        _timeRemaining = _timeRemaining! + 12;
        _bonusTimePulse = true;
        Future.delayed(const Duration(milliseconds: 1400), () {
          _bonusTimePulse = false;
          notifyListeners();
        });
      }
    }

    if (won) {
      _stopTimer();
      final baseReward = (_currentLevelModel?.isBossLevel == true) ? 80 : 25;
      final reward = _doubleCoins ? (baseReward * 2) : baseReward;
      final newCoins = _state.coins + reward;
      final nextLevelNum = _state.currentLevel + 1;
      if (nextLevelNum > _maxUnlockedLevel) {
        _maxUnlockedLevel = nextLevelNum;
        PersistenceManager.saveMaxUnlockedLevel(_maxUnlockedLevel);
      }
      PersistenceManager.saveTotalCoins(newCoins);
      PersistenceManager.saveLevelStars(_state.currentLevel, 3);
      AudioManager().playWin();

      _state = _state.copyWith(
        tubes: finalTubes,
        clearSelection: true,
        status: GameStatus.won,
        coins: newCoins,
      );
    } else if (bombExploded) {
      _stopTimer();
      AudioManager().playInvalid();
      _state = _state.copyWith(
        tubes: finalTubes,
        clearSelection: true,
        status: GameStatus.gameOver,
      );
      notifyListeners();
      return;
    } else {
      // Check Move Limit Challenge
      if (_currentLevelModel != null && _currentLevelModel!.hasMoveLimit) {
        if (_state.moveCount >= _currentLevelModel!.maxMoves!) {
          _stopTimer();
          AudioManager().playInvalid();
          _state = _state.copyWith(
            tubes: updatedTubes,
            clearSelection: true,
            status: GameStatus.gameOver,
          );
          notifyListeners();
          return;
        }
      }

      _state = _state.copyWith(
        tubes: updatedTubes,
        clearSelection: true,
        status: GameStatus.idle,
      );
    }

    notifyListeners();
  }

  /// Unlock a locked tube using keys or coins
  bool unlockTube(String tubeId) {
    if (_state.isAnimating || _state.status == GameStatus.won) return false;
    final tubeIndex = _state.tubes.indexWhere((t) => t.id == tubeId);
    if (tubeIndex == -1) return false;
    final tube = _state.tubes[tubeIndex];
    if (!tube.isLocked) return false;

    // 1. If player has a Master Key, use it for free!
    if (_unlockKeys > 0) {
      _unlockKeys--;
      PersistenceManager.useUnlockKey();
      final updatedTubes = List<TubeModel>.from(_state.tubes);
      updatedTubes[tubeIndex] = tube.copyWith(isLocked: false);
      _state = _state.copyWith(tubes: updatedTubes);
      AudioManager().playSelect();
      notifyListeners();
      return true;
    }

    // 2. Otherwise pay with coins
    if (_state.coins >= tube.unlockCost) {
      final updatedCoins = _state.coins - tube.unlockCost;
      PersistenceManager.saveTotalCoins(updatedCoins);
      final updatedTubes = List<TubeModel>.from(_state.tubes);
      updatedTubes[tubeIndex] = tube.copyWith(isLocked: false);
      _state = _state.copyWith(
        tubes: updatedTubes,
        coins: updatedCoins,
      );
      AudioManager().playSelect();
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Buy and equip skin with coins
  bool buyAndEquipSkin(String skinId, int cost) {
    if (_unlockedSkins.contains(skinId)) {
      equipSkin(skinId);
      return true;
    }
    if (_state.coins >= cost) {
      final updatedCoins = _state.coins - cost;
      PersistenceManager.saveTotalCoins(updatedCoins);
      PersistenceManager.unlockSkin(skinId);
      PersistenceManager.saveActiveTubeSkin(skinId);
      _unlockedSkins = List<String>.from(_unlockedSkins)..add(skinId);
      _activeTubeSkin = skinId;
      _state = _state.copyWith(coins: updatedCoins);
      AudioManager().playBuy();
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Equip already unlocked skin
  void equipSkin(String skinId) {
    if (_unlockedSkins.contains(skinId)) {
      _activeTubeSkin = skinId;
      PersistenceManager.saveActiveTubeSkin(skinId);
      AudioManager().playSelect();
      notifyListeners();
    }
  }

  /// Buy real lab perk with coins
  bool buyPerk(String perkId, int cost) {
    if (_state.coins >= cost) {
      final updatedCoins = _state.coins - cost;
      PersistenceManager.saveTotalCoins(updatedCoins);
      if (perkId == 'pro_pass') {
        _isPro = true;
        _doubleCoins = true;
        _freeUndos += 5;
        _unlockKeys += 2;
        PersistenceManager.enablePro();
        PersistenceManager.addFreeUndos(5);
        PersistenceManager.addUnlockKeys(2);
      } else if (perkId == 'extra_tube_permanent') {
        _hasPermanentExtraTube = true;
        PersistenceManager.enablePermanentExtraTube();
        final extraId = 'extra_perm_${_state.currentLevel}';
        if (!_state.tubes.any((t) => t.id == extraId)) {
          final updated = List<TubeModel>.from(_state.tubes)..add(TubeModel(id: extraId, layers: const []));
          _state = _state.copyWith(tubes: updated);
        }
      } else if (perkId == 'color_radar') {
        _colorRadarCharges += 5;
        PersistenceManager.addColorRadar(5);
      } else if (perkId == 'time_freeze') {
        _timeFreezes += 3;
        PersistenceManager.addTimeFreeze(3);
      } else if (perkId == 'undo_pack') {
        _freeUndos += 5;
        PersistenceManager.addFreeUndos(5);
      } else if (perkId == 'tube_key') {
        _unlockKeys += 1;
        PersistenceManager.addUnlockKeys(1);
      } else if (perkId == 'double_coins') {
        _doubleCoins = true;
        PersistenceManager.enableDoubleCoins();
      }
      _state = _state.copyWith(coins: updatedCoins);
      AudioManager().playBuy();
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Use Color Radar booster: reveals all mystery hidden layers
  bool useColorRadar() {
    if (_colorRadarCharges > 0) {
      _colorRadarCharges--;
      PersistenceManager.useColorRadar();
      final revealed = _state.tubes.map((t) => t.copyWith(hiddenCount: 0)).toList();
      _state = _state.copyWith(tubes: revealed);
      AudioManager().playWin();
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Use Time Freeze booster: grants +45 seconds in timed challenges
  bool useTimeFreeze() {
    if (_timeFreezes > 0) {
      _timeFreezes--;
      PersistenceManager.useTimeFreeze();
      if (_timeRemaining != null) {
        _timeRemaining = (_timeRemaining! + 45);
      }
      AudioManager().playWin();
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Undo the last move
  void undoMove() {
    if (!canUndo) return;
    AudioManager().playUndo();

    final lastSnapshot = _state.historyStack.last;
    final updatedHistory = List<List<TubeModel>>.from(_state.historyStack)..removeLast();

    _state = _state.copyWith(
      tubes: lastSnapshot.map((t) => t.copyWith()).toList(),
      clearSelection: true,
      moveCount: (_state.moveCount - 1).clamp(0, 9999),
      status: GameStatus.idle,
      historyStack: updatedHistory,
    );
    notifyListeners();
  }

  /// Find intelligent hint for next legal move
  Map<String, String>? getHintMove() {
    for (int i = 0; i < _state.tubes.length; i++) {
      final src = _state.tubes[i];
      if (src.isEmpty || (src.isSolved && src.isFull)) continue;

      for (int j = 0; j < _state.tubes.length; j++) {
        if (i == j) continue;
        final tgt = _state.tubes[j];
        if (src.canPourInto(tgt) && src.transferableUnitsTo(tgt) > 0) {
          // Avoid redundant pour of already monochromatic tube into empty tube
          if (tgt.isEmpty && src.layers.every((c) => c == src.layers.first)) continue;
          return {'sourceId': src.id, 'targetId': tgt.id};
        }
      }
    }
    return null;
  }

  /// Add extra empty tube (costs coins)
  bool addExtraTube() {
    if (_state.isAnimating || _state.status == GameStatus.won) return false;
    
    final emptyCount = _state.tubes.where((t) => t.isEmpty).length;
    if (emptyCount >= 4) return false;

    const cost = 50;
    if (_state.coins >= cost) {
      final updatedCoins = _state.coins - cost;
      PersistenceManager.saveTotalCoins(updatedCoins);

      final newTube = TubeModel(
        id: 'tube_extra_${_state.tubes.length}',
        capacity: 4,
        layers: [],
      );

      final updatedTubes = List<TubeModel>.from(_state.tubes)..add(newTube);

      _state = _state.copyWith(
        tubes: updatedTubes,
        coins: updatedCoins,
      );
      AudioManager().playSelect();
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Double the level reward from victory dialog
  void doubleReward(int reward) {
    final newTotal = _state.coins + reward;
    PersistenceManager.saveTotalCoins(newTotal);
    _state = _state.copyWith(coins: newTotal);
    notifyListeners();
  }

  /// Advance to next level
  void nextLevel() {
    loadLevel(_state.currentLevel + 1);
  }
}
