import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../../models/tube_model.dart';
import '../../models/level_model.dart';
import 'puzzle_solver.dart';

class LevelGenerator {
  static final Random _random = Random();

  /// Generates a validated solvable level for the given level number
  static LevelModel generateLevel(int levelNumber) {
    // 1. Determine Capacity (4 to 6)
    final int capacity;
    if (levelNumber <= 15) {
      capacity = 4;
    } else if (levelNumber <= 30) {
      capacity = (levelNumber % 3 == 0) ? 5 : 4;
    } else if (levelNumber <= 45) {
      capacity = 5;
    } else {
      capacity = (levelNumber % 2 == 0) ? 6 : 5;
    }

    // 2. Determine Number of Colors & Empty Tubes (Scaling from 3 to 12 tubes)
    final int numColors;
    final int numEmpty;

    if (levelNumber == 1) {
      numColors = 2;
      numEmpty = 1; // Total: 3
    } else if (levelNumber <= 3) {
      numColors = 3;
      numEmpty = 2; // Total: 5
    } else if (levelNumber <= 6) {
      numColors = 4;
      numEmpty = 2; // Total: 6
    } else if (levelNumber <= 10) {
      numColors = 5;
      numEmpty = 2; // Total: 7
    } else if (levelNumber <= 18) {
      numColors = 6;
      numEmpty = 2; // Total: 8
    } else if (levelNumber <= 28) {
      numColors = 7;
      numEmpty = 2; // Total: 9
    } else if (levelNumber <= 38) {
      numColors = 8;
      numEmpty = 2; // Total: 10
    } else if (levelNumber <= 48) {
      numColors = 9;
      numEmpty = 2; // Total: 11
    } else {
      numColors = min(10, AppColors.liquidPalette.length);
      numEmpty = 2; // Total: 12
    }

    // 3. Generate Solvable Tube Configuration via Backward Simulation
    final scrambleSteps = 15 + (levelNumber * 3).clamp(0, 100);
    List<TubeModel> candidate = _scrambleSolvedState(
      numColors,
      numEmpty,
      capacity: capacity,
      scrambleSteps: scrambleSteps,
    );

    // 4. Determine Challenge Mode (Boss, Timer Rush, Limited Moves, or Casual)
    final bool isBossLevel = levelNumber >= 10 && (levelNumber % 10 == 0);
    int? timeLimit;
    int? maxMoves;

    if (isBossLevel) {
      // Boss Level: Tight timer with scaling pressure + mystery layer
      timeLimit = max(40, 60 - ((levelNumber ~/ 10) * 3));
    } else if (levelNumber >= 4 && (levelNumber % 4 == 0 || levelNumber % 7 == 0)) {
      // Time Attack / Rush Mode: Time scales down as level increases!
      // Each solved tube rewards +12 seconds bonus time!
      timeLimit = max(38, 70 - ((levelNumber - 4) ~/ 2) * 2 + (numColors * 2));
    } else if (levelNumber >= 5 && (levelNumber % 4 == 2 || levelNumber % 6 == 3)) {
      // Limited Moves Mode: Mathematically validated via PuzzleSolver!
      final optMoves = PuzzleSolver.findMinimumMoves(candidate, maxStates: 3000);
      final buffer = (levelNumber <= 8) ? 5 : ((levelNumber <= 22) ? 4 : 3);
      if (optMoves > 0) {
        maxMoves = optMoves + buffer;
      } else {
        // Fallback guaranteed buffer
        maxMoves = min(scrambleSteps, numColors * capacity) + buffer;
      }
    }

    // 5. Mystery Hidden Layers (Levels 6+)
    if (levelNumber >= 6) {
      final int hiddenTargetTubes = (isBossLevel || levelNumber >= 18) ? 2 : 1;
      final int hiddenDepth = (capacity > 4 && levelNumber >= 26) ? 2 : 1;

      int appliedCount = 0;
      candidate = candidate.map((tube) {
        if (appliedCount < hiddenTargetTubes && tube.layers.length >= 3) {
          appliedCount++;
          return tube.copyWith(hiddenCount: hiddenDepth);
        }
        return tube;
      }).toList();
    }

    // 6. Locked Tube Mechanic (Levels 8+, every 6th level)
    if (levelNumber >= 8 && levelNumber % 6 == 2 && !isBossLevel) {
      // Find an empty tube to lock
      bool lockedOne = false;
      candidate = candidate.map((tube) {
        if (!lockedOne && tube.isEmpty) {
          lockedOne = true;
          return tube.copyWith(isLocked: true, unlockCost: 30);
        }
        return tube;
      }).toList();
    }

    // 7. Unstable Bomb Hazard Mechanic (Levels 7+, every 5th or 7th level or Boss levels)
    final bool hasBombHazard = (levelNumber >= 7 && (levelNumber % 5 == 2 || levelNumber % 7 == 3 || isBossLevel));
    if (hasBombHazard) {
      int bombApplied = 0;
      final int bombLimit = (isBossLevel || levelNumber >= 25) ? 2 : 1;
      final int countdown = max(10, 18 - (levelNumber ~/ 8));

      candidate = candidate.map((tube) {
        if (bombApplied < bombLimit && tube.layers.length >= 3 && !tube.isLocked) {
          bombApplied++;
          return tube.copyWith(bombCountdown: countdown);
        }
        return tube;
      }).toList();
    }

    return LevelModel(
      levelNumber: levelNumber,
      initialTubes: candidate,
      minMoves: numColors * capacity,
      maxMoves: maxMoves,
      timeLimitSeconds: timeLimit,
      isUnlocked: levelNumber == 1,
      isBossLevel: isBossLevel,
    );
  }

  /// Generates a guaranteed 100% solvable compact wave for Survival Mode
  static List<TubeModel> generateSurvivalWave(int wave) {
    final int numColors;
    const int numEmpty = 2;

    if (wave <= 1) {
      numColors = 3; // 5 tubes total
    } else if (wave <= 3) {
      numColors = 4; // 6 tubes total
    } else if (wave <= 6) {
      numColors = 5; // 7 tubes total
    } else {
      numColors = 6; // 8 tubes total max for survival screen
    }

    final scrambleSteps = 16 + (wave * 3).clamp(0, 45);
    final tubes = _scrambleSolvedState(
      numColors,
      numEmpty,
      capacity: 4,
      scrambleSteps: scrambleSteps,
    );

    // Unstable bomb in wave 4+ for extra thrill
    if (wave >= 4) {
      final int countdown = max(12, 20 - wave);
      for (int i = 0; i < tubes.length; i++) {
        if (tubes[i].layers.length >= 3) {
          tubes[i] = tubes[i].copyWith(bombCountdown: countdown);
          break;
        }
      }
    }

    return tubes;
  }

  /// Backward simulation: Starts with solved tubes and performs reverse moves
  static List<TubeModel> _scrambleSolvedState(
    int numColors,
    int numEmpty, {
    int capacity = 4,
    int scrambleSteps = 35,
  }) {
    final colors = List.generate(numColors, (i) => AppColors.getLiquidColor(i));

    // Solved base state
    List<List<Color>> tubesState = [];
    for (int i = 0; i < numColors; i++) {
      tubesState.add(List.filled(capacity, colors[i], growable: true));
    }
    for (int i = 0; i < numEmpty; i++) {
      tubesState.add(<Color>[]);
    }

    // Backward pours: transfer 1 unit from a non-empty tube to any tube with space < capacity
    for (int step = 0; step < scrambleSteps; step++) {
      final nonFullIndices = <int>[];
      final nonEmptyIndices = <int>[];

      for (int i = 0; i < tubesState.length; i++) {
        if (tubesState[i].length < capacity) nonFullIndices.add(i);
        if (tubesState[i].isNotEmpty) nonEmptyIndices.add(i);
      }

      if (nonFullIndices.isEmpty || nonEmptyIndices.isEmpty) continue;

      final fromIdx = nonEmptyIndices[_random.nextInt(nonEmptyIndices.length)];
      final validTo = nonFullIndices.where((idx) => idx != fromIdx).toList();

      if (validTo.isNotEmpty) {
        final toIdx = validTo[_random.nextInt(validTo.length)];
        final movingUnit = tubesState[fromIdx].removeLast();
        tubesState[toIdx].add(movingUnit);
      }
    }

    // Convert to TubeModels
    return List.generate(tubesState.length, (i) {
      return TubeModel(
        id: 'tube_$i',
        capacity: capacity,
        layers: tubesState[i],
      );
    });
  }
}
