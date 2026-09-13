import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_mixer_new/models/tube_model.dart';

void main() {
  group('TubeModel & Mathematical Pouring Rules', () {
    test('Empty tube properties', () {
      final tube = TubeModel(id: 't1', capacity: 4, layers: []);
      expect(tube.isEmpty, isTrue);
      expect(tube.isFull, isFalse);
      expect(tube.topColor, isNull);
      expect(tube.topColorCount, 0);
      expect(tube.isSolved, isTrue); // Empty tube counts as solved
      expect(tube.availableCapacity, 4);
    });

    test('Single color full tube is solved', () {
      final tube = TubeModel(
        id: 't2',
        capacity: 4,
        layers: [Colors.red, Colors.red, Colors.red, Colors.red],
      );
      expect(tube.isEmpty, isFalse);
      expect(tube.isFull, isTrue);
      expect(tube.topColor, Colors.red);
      expect(tube.topColorCount, 4);
      expect(tube.isSolved, isTrue);
      expect(tube.availableCapacity, 0);
    });

    test('Mixed color tube is NOT solved', () {
      final tube = TubeModel(
        id: 't3',
        capacity: 4,
        layers: [Colors.red, Colors.blue, Colors.red, Colors.blue],
      );
      expect(tube.isSolved, isFalse);
      expect(tube.topColor, Colors.blue);
      expect(tube.topColorCount, 1);
    });

    test('Consecutive top colors count properly', () {
      final tube = TubeModel(
        id: 't4',
        capacity: 4,
        layers: [Colors.green, Colors.red, Colors.red, Colors.red],
      );
      expect(tube.topColor, Colors.red);
      expect(tube.topColorCount, 3);
    });

    test('Pour validation rules', () {
      final source = TubeModel(
        id: 'src',
        capacity: 4,
        layers: [Colors.green, Colors.blue, Colors.blue],
      );
      final targetMatching = TubeModel(
        id: 'tgt1',
        capacity: 4,
        layers: [Colors.blue],
      );
      final targetMismatch = TubeModel(
        id: 'tgt2',
        capacity: 4,
        layers: [Colors.red],
      );
      final targetFull = TubeModel(
        id: 'tgt3',
        capacity: 4,
        layers: [Colors.blue, Colors.blue, Colors.blue, Colors.blue],
      );
      final targetEmpty = TubeModel(
        id: 'tgt4',
        capacity: 4,
        layers: [],
      );

      // Cannot pour into itself
      expect(source.canPourInto(source), isFalse);

      // Can pour into matching color
      expect(source.canPourInto(targetMatching), isTrue);

      // Cannot pour into mismatched top color
      expect(source.canPourInto(targetMismatch), isFalse);

      // Cannot pour into full target
      expect(source.canPourInto(targetFull), isFalse);

      // Can pour into empty target
      expect(source.canPourInto(targetEmpty), isTrue);
    });

    test('Transfer volume formula: min(Source Top Color Count, Target Capacity - Target Length)', () {
      // Source has 3 blue on top: [green, blue, blue, blue] -> topColorCount = 3
      final source = TubeModel(
        id: 'src',
        capacity: 4,
        layers: [Colors.green, Colors.blue, Colors.blue, Colors.blue],
      );
      // Target has 2 layers: [red, blue] -> available = 2
      final target = TubeModel(
        id: 'tgt',
        capacity: 4,
        layers: [Colors.red, Colors.blue],
      );

      // transferable = min(3, 4 - 2) = 2
      expect(source.transferableUnitsTo(target), 2);
    });
  });
}
