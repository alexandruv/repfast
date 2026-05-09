import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:repfast_app/src/domain/calculators.dart';
import 'package:repfast_app/src/domain/models.dart';

void main() {
  group('RepFastCalculators', () {
    test('calculates set volume as weight times reps', () {
      expect(RepFastCalculators.volume(weight: 225, reps: 6), 1350);
    });

    test('calculates estimated one rep max using Epley formula', () {
      expect(RepFastCalculators.estimatedOneRepMax(weight: 225, reps: 6), closeTo(270, 0.001));
    });

    test('rounds display values without changing source precision', () {
      expect(RepFastCalculators.displayWeight(225.5), '225.5');
      expect(RepFastCalculators.displayWeight(225), '225');
    });
  });

  group('WorkoutSet', () {
    test('uses calculator contract for volume', () {
      final set = WorkoutSet(
        id: 'set-1',
        sessionId: 'session-1',
        exerciseId: 'exercise-1',
        setIndex: 1,
        weight: 225,
        reps: 6,
        completedAt: DateTime(2026),
      );

      expect(
        set.volume,
        RepFastCalculators.volume(weight: set.weight, reps: set.reps),
      );
      expect(
        File('lib/src/domain/models.dart').readAsStringSync(),
        contains('RepFastCalculators.volume'),
      );
    });
  });
}
