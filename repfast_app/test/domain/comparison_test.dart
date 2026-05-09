import 'package:flutter_test/flutter_test.dart';
import 'package:repfast_app/src/domain/comparison.dart';
import 'package:repfast_app/src/domain/models.dart';

void main() {
  final now = DateTime(2026, 5, 9, 12);

  WorkoutSet set({
    required String id,
    required String sessionId,
    required int index,
    required double weight,
    required int reps,
  }) {
    return WorkoutSet(
      id: id,
      sessionId: sessionId,
      exerciseId: 'bench',
      setIndex: index,
      weight: weight,
      reps: reps,
      completedAt: now.add(Duration(minutes: index)),
    );
  }

  test('finds the most recent previous set for defaults', () {
    final result = WorkoutComparison.previousSetForExercise([
      set(id: 'old-1', sessionId: 'previous', index: 1, weight: 205, reps: 5),
      set(id: 'old-2', sessionId: 'previous', index: 2, weight: 225, reps: 5),
    ], exerciseId: 'bench');

    expect(result?.weight, 225);
    expect(result?.reps, 5);
  });

  test('compares current and previous volume', () {
    final result = WorkoutComparison.compare(
      currentSets: [
        set(id: 'new-1', sessionId: 'current', index: 1, weight: 225, reps: 6),
      ],
      previousSets: [
        set(id: 'old-1', sessionId: 'previous', index: 1, weight: 225, reps: 5),
      ],
    );

    expect(result.currentVolume, 1350);
    expect(result.previousVolume, 1125);
    expect(result.volumeDeltaPercent, closeTo(20, 0.001));
    expect(result.takeaway, 'You added one rep at the same weight.');
  });

  test('marks a PR when current estimated strength is higher', () {
    final result = WorkoutComparison.compare(
      currentSets: [
        set(id: 'new-1', sessionId: 'current', index: 1, weight: 225, reps: 6),
      ],
      previousSets: [
        set(id: 'old-1', sessionId: 'previous', index: 1, weight: 225, reps: 5),
      ],
    );

    expect(result.isPersonalRecord, isTrue);
    expect(result.bestSet?.reps, 6);
  });

  test('does not mark a PR for a first logged lift', () {
    final result = WorkoutComparison.compare(
      currentSets: [
        set(id: 'new-1', sessionId: 'current', index: 1, weight: 225, reps: 6),
      ],
      previousSets: [],
    );

    expect(result.isPersonalRecord, isFalse);
    expect(result.takeaway, 'First logged set for this lift.');
  });

  test('reports exact added reps at the same weight', () {
    final result = WorkoutComparison.compare(
      currentSets: [
        set(id: 'new-1', sessionId: 'current', index: 1, weight: 225, reps: 7),
      ],
      previousSets: [
        set(id: 'old-1', sessionId: 'previous', index: 1, weight: 225, reps: 5),
      ],
    );

    expect(result.takeaway, 'You added 2 reps at the same weight.');
  });

  test('breaks estimated strength ties by higher volume', () {
    final result = WorkoutComparison.compare(
      currentSets: [
        set(id: 'new-1', sessionId: 'current', index: 1, weight: 225, reps: 2),
        set(id: 'new-2', sessionId: 'current', index: 2, weight: 200, reps: 6),
      ],
      previousSets: [
        set(id: 'old-1', sessionId: 'previous', index: 1, weight: 135, reps: 5),
      ],
    );

    expect(result.bestSet?.id, 'new-2');
  });
}
