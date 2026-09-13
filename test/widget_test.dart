import 'package:flutter_test/flutter_test.dart';
import 'package:water_mixer_new/models/tube_model.dart';
import 'package:flutter/material.dart';

void main() {
  test('Smoke test - TubeModel creation', () {
    final tube = TubeModel(id: 'smoke_test', capacity: 4, layers: [Colors.blue]);
    expect(tube.id, 'smoke_test');
    expect(tube.layers.length, 1);
  });
}
