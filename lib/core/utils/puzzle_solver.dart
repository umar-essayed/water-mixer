import 'dart:collection';
import 'package:flutter/material.dart';
import '../../models/tube_model.dart';

class PuzzleSolver {
  /// Encodes list of tubes into a canonical string key for visited states
  static String _canonicalStateKey(List<TubeModel> tubes) {
    // Sort representation of non-empty tubes to eliminate order-permutation redundancy
    final tubeStrings = tubes.map((t) {
      return t.layers.map((c) => c.toARGB32().toRadixString(16)).join(',');
    }).toList()..sort();
    return tubeStrings.join('|');
  }

  /// Check if the state is already won
  static bool isStateWon(List<TubeModel> tubes) {
    return tubes.every((tube) => tube.isSolved);
  }

  /// Solves using BFS tracking move depth to return the exact minimum moves to solve, or -1 if unreached
  static int findMinimumMoves(List<TubeModel> initialTubes, {int maxStates = 4000}) {
    if (isStateWon(initialTubes)) return 0;

    final Queue<({List<TubeModel> tubes, int depth})> queue = Queue();
    final Set<String> visited = {};

    queue.add((tubes: initialTubes.map((t) => t.copyWith()).toList(), depth: 0));
    visited.add(_canonicalStateKey(initialTubes));

    int examined = 0;
    while (queue.isNotEmpty && examined < maxStates) {
      final item = queue.removeFirst();
      final current = item.tubes;
      final depth = item.depth;
      examined++;

      if (isStateWon(current)) {
        return depth;
      }

      // Generate all valid next moves
      for (int i = 0; i < current.length; i++) {
        final source = current[i];
        if (source.isEmpty) continue;

        // Optimization: if source is already completed (monochromatic full), don't pour out
        if (source.isSolved && source.isFull) continue;

        for (int j = 0; j < current.length; j++) {
          if (i == j) continue;
          final target = current[j];

          // Optimization: pouring a monochromatic tube into an empty tube is just swapping tubes
          if (target.isEmpty && source.layers.every((c) => c == source.layers.first)) {
            if (current.where((t) => t.isEmpty).length > 1) {
              continue;
            }
          }

          if (source.canPourInto(target)) {
            final units = source.transferableUnitsTo(target);
            if (units <= 0) continue;

            // Perform pour
            final nextTubes = current.map((t) => t.copyWith()).toList();
            final movingColor = source.topColor!;
            final newSourceLayers = List<Color>.from(source.layers)
              ..removeRange(source.layers.length - units, source.layers.length);
            final newTargetLayers = List<Color>.from(target.layers)
              ..addAll(List.filled(units, movingColor));

            nextTubes[i] = source.copyWith(layers: newSourceLayers);
            nextTubes[j] = target.copyWith(layers: newTargetLayers);

            final key = _canonicalStateKey(nextTubes);
            if (!visited.contains(key)) {
              if (isStateWon(nextTubes)) return depth + 1;
              visited.add(key);
              queue.add((tubes: nextTubes, depth: depth + 1));
            }
          }
        }
      }
    }

    return -1;
  }

  /// Check if the state is solvable using BFS
  static bool isSolvable(List<TubeModel> initialTubes, {int maxStates = 4000}) {
    return findMinimumMoves(initialTubes, maxStates: maxStates) != -1;
  }
}
