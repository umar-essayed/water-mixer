import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_mixer_new/core/utils/puzzle_solver.dart';
import 'package:water_mixer_new/core/utils/level_generator.dart';
import 'package:water_mixer_new/models/tube_model.dart';

void main() {
  group('PuzzleSolver & LevelGenerator Tests', () {
    test('Solved board detection', () {
      final tubes = [
        const TubeModel(id: 't1', capacity: 4, layers: [Colors.red, Colors.red, Colors.red, Colors.red]),
        const TubeModel(id: 't2', capacity: 4, layers: [Colors.blue, Colors.blue, Colors.blue, Colors.blue]),
        const TubeModel(id: 't3', capacity: 4, layers: []),
      ];
      expect(PuzzleSolver.isStateWon(tubes), isTrue);
      expect(PuzzleSolver.isSolvable(tubes), isTrue);
    });

    test('1-move simple puzzle is solvable', () {
      final tubes = [
        const TubeModel(id: 't1', capacity: 4, layers: [Colors.red, Colors.red, Colors.red]),
        const TubeModel(id: 't2', capacity: 4, layers: [Colors.blue, Colors.blue, Colors.blue, Colors.blue]),
        const TubeModel(id: 't3', capacity: 4, layers: [Colors.red]),
      ];
      expect(PuzzleSolver.isSolvable(tubes), isTrue);
    });

    test('LevelGenerator produces valid level with correct tube count', () {
      final level1 = LevelGenerator.generateLevel(1);
      expect(level1.levelNumber, 1);
      expect(level1.initialTubes.isNotEmpty, isTrue);

      final level5 = LevelGenerator.generateLevel(5);
      expect(level5.levelNumber, 5);
      expect(level5.initialTubes.length, greaterThanOrEqualTo(5));
    });
  });
}
