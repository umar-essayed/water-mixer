import 'package:flutter/material.dart';

class TubeModel {
  final String id;
  final int capacity;
  final List<Color> layers;
  final int hiddenCount; // Layers with index < hiddenCount are mystery layers
  final bool isLocked;   // If tube is currently locked
  final int unlockCost;  // Coin cost to unlock
  final int? bombCountdown; // Unstable explosive liquid countdown (moves remaining)

  const TubeModel({
    required this.id,
    this.capacity = 4,
    required this.layers,
    this.hiddenCount = 0,
    this.isLocked = false,
    this.unlockCost = 30,
    this.bombCountdown,
  });

  /// Check if the tube has an active ticking bomb
  bool get isBomb => bombCountdown != null && bombCountdown! > 0;

  /// Check if the tube has no liquid
  bool get isEmpty => layers.isEmpty;

  /// Check if the tube contains liquid
  bool get isNotEmpty => layers.isNotEmpty;

  /// Check if the tube has reached its max capacity
  bool get isFull => layers.length >= capacity;

  /// Available remaining capacity
  int get availableCapacity => (capacity - layers.length).clamp(0, capacity);

  /// Top liquid color (null if empty)
  Color? get topColor => layers.isEmpty ? null : layers.last;

  /// Check if tube has mystery hidden layers
  bool get hasHiddenLayers => hiddenCount > 0;

  /// Checks if a specific layer index is currently a hidden mystery layer
  /// Note: The top layer is always visible so the player can interact with it
  bool isLayerHidden(int index) {
    if (index >= layers.length) return false;
    // If it's the topmost layer, it is revealed
    if (index == layers.length - 1) return false;
    return index < hiddenCount;
  }

  /// Count of contiguous identical color layers at the top of the tube
  int get topColorCount {
    if (layers.isEmpty) return 0;
    final targetColor = layers.last;
    int count = 0;
    for (int i = layers.length - 1; i >= 0; i--) {
      // Stop if hitting a hidden layer or mismatched color
      if (isLayerHidden(i)) break;
      if (layers[i] == targetColor) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  /// Solved condition:
  /// Completely empty, OR full with zero hidden layers and all identical colors.
  bool get isSolved {
    if (isLocked) return false;
    if (isEmpty) return true;
    if (!isFull) return false;
    if (hiddenCount > 0) return false;
    final firstColor = layers.first;
    return layers.every((c) => c == firstColor);
  }

  /// Can we pour from this tube into [target]?
  bool canPourInto(TubeModel target) {
    if (isLocked || target.isLocked) return false;
    if (id == target.id) return false;
    if (isEmpty) return false;
    if (target.isFull) return false;
    if (target.isEmpty) return true;
    return topColor == target.topColor;
  }

  /// Calculate transferable volume units
  int transferableUnitsTo(TubeModel target) {
    if (!canPourInto(target)) return 0;
    return topColorCount.clamp(0, target.availableCapacity);
  }

  /// Returns a deep copy of this tube
  TubeModel copyWith({
    String? id,
    int? capacity,
    List<Color>? layers,
    int? hiddenCount,
    bool? isLocked,
    int? unlockCost,
    int? bombCountdown,
    bool clearBomb = false,
  }) {
    return TubeModel(
      id: id ?? this.id,
      capacity: capacity ?? this.capacity,
      layers: layers != null ? List<Color>.from(layers) : List<Color>.from(this.layers),
      hiddenCount: hiddenCount ?? this.hiddenCount,
      isLocked: isLocked ?? this.isLocked,
      unlockCost: unlockCost ?? this.unlockCost,
      bombCountdown: clearBomb ? null : (bombCountdown ?? this.bombCountdown),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TubeModel) return false;
    if (id != other.id ||
        capacity != other.capacity ||
        layers.length != other.layers.length ||
        hiddenCount != other.hiddenCount ||
        isLocked != other.isLocked ||
        bombCountdown != other.bombCountdown) {
      return false;
    }
    for (int i = 0; i < layers.length; i++) {
      if (layers[i] != other.layers[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(id, capacity, hiddenCount, isLocked, bombCountdown, Object.hashAll(layers));

  @override
  String toString() => 'TubeModel(id: $id, layers: ${layers.length}/$capacity, locked: $isLocked, hidden: $hiddenCount, bomb: $bombCountdown)';
}
