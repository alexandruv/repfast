import 'package:flutter_test/flutter_test.dart';
import 'package:repfast_app/src/data/sqlite_workout_repository.dart';

void main() {
  test('seeds starter workout data when empty', () async {
    final repository = await SqliteWorkoutRepository.inMemory();
    await repository.seedIfEmpty();

    final exercise = await repository.activeExercise();
    final previous = await repository.previousSetsForExercise(exercise.id);

    expect(exercise.name, 'Bench Press');
    expect(previous, isNotEmpty);
    expect(previous.last.weight, 225);
    expect(previous.last.reps, 5);
  });

  test(
    'persists a logged set and returns it in current session sets',
    () async {
      final repository = await SqliteWorkoutRepository.inMemory();
      await repository.seedIfEmpty();
      final exercise = await repository.activeExercise();
      final session = await repository.activeSession();

      await repository.logSet(
        sessionId: session.id,
        exerciseId: exercise.id,
        setIndex: 1,
        weight: 225,
        reps: 6,
        completedAt: DateTime(2026, 5, 9, 12),
      );

      final sets = await repository.currentSetsForExercise(exercise.id);
      expect(sets.single.weight, 225);
      expect(sets.single.reps, 6);
    },
  );
}
