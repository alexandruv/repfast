import 'package:flutter_test/flutter_test.dart';
import 'package:repfast_app/src/data/sqlite_workout_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  Future<SqliteWorkoutRepository> openRepository() async {
    final database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
    );
    final repository = await SqliteWorkoutRepository.openWithDatabase(database);
    addTearDown(repository.close);
    return repository;
  }

  test('seeds starter workout data when empty', () async {
    final repository = await openRepository();
    await repository.seedIfEmpty();

    final exercise = await repository.activeExercise();
    final previous = await repository.previousSetsForExercise(exercise.id);

    expect(exercise.name, 'Bench Press');
    expect(previous, isNotEmpty);
    expect(previous.last.weight, 225);
    expect(previous.last.reps, 5);
  });

  test('seeds starter exercise list for selection', () async {
    final repository = await openRepository();
    await repository.seedIfEmpty();

    final exercises = await repository.exercises();

    expect(
      exercises.map((exercise) => exercise.name),
      containsAll([
        'Bench Press',
        'Squat',
        'Deadlift',
        'Overhead Press',
        'Barbell Row',
      ]),
    );
  });

  test(
    'persists a logged set and returns it in current session sets',
    () async {
      final repository = await openRepository();
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

  test('rejects logged sets for missing exercise', () async {
    final repository = await openRepository();
    await repository.seedIfEmpty();
    final session = await repository.activeSession();

    await expectLater(
      repository.logSet(
        sessionId: session.id,
        exerciseId: 'missing-exercise',
        setIndex: 1,
        weight: 225,
        reps: 6,
        completedAt: DateTime(2026, 5, 9, 12),
      ),
      throwsException,
    );

    final sets = await repository.currentSetsForExercise('missing-exercise');
    expect(sets, isEmpty);
  });

  test('rejects logged sets for missing session', () async {
    final repository = await openRepository();
    await repository.seedIfEmpty();
    final exercise = await repository.activeExercise();

    await expectLater(
      repository.logSet(
        sessionId: 'missing-session',
        exerciseId: exercise.id,
        setIndex: 1,
        weight: 225,
        reps: 6,
        completedAt: DateTime(2026, 5, 9, 12),
      ),
      throwsException,
    );

    final sets = await repository.currentSetsForExercise(exercise.id);
    expect(sets, isEmpty);
  });
}
