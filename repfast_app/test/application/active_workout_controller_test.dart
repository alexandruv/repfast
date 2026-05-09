import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:repfast_app/src/application/active_workout_controller.dart';
import 'package:repfast_app/src/data/sqlite_workout_repository.dart';
import 'package:repfast_app/src/data/workout_repository.dart';
import 'package:repfast_app/src/domain/models.dart';
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

  test('loads previous defaults into active state', () async {
    final repository = await openRepository();
    await repository.seedIfEmpty();
    final controller = ActiveWorkoutController(repository: repository);

    final state = await controller.load();

    expect(state.exercise.name, 'Bench Press');
    expect(state.weight, 225);
    expect(state.reps, 5);
    expect(state.setIndex, 1);
    expect(state.statusLabel, 'Saved on device');
  });

  test(
    'logging a set persists it, advances set index, starts rest, and updates comparison',
    () async {
      final repository = await openRepository();
      await repository.seedIfEmpty();
      final controller = ActiveWorkoutController(repository: repository);
      await controller.load();
      controller.updateReps(6);

      final state = await controller.logSet(now: DateTime(2026, 5, 9, 12));

      expect(state.setIndex, 2);
      expect(state.isResting, isTrue);
      expect(state.restStartedAt, DateTime(2026, 5, 9, 12));
      expect(state.comparison.volumeDeltaPercent, greaterThan(0));
      expect(
        state.comparison.takeaway,
        'You added one rep at the same weight.',
      );
    },
  );

  test('updates clamp invalid inputs and clear save errors', () async {
    final repository = await openRepository();
    await repository.seedIfEmpty();
    final controller = ActiveWorkoutController(repository: repository);
    await controller.load();

    var state = controller.updateWeight(-10);
    expect(state.weight, 0);

    state = controller.updateReps(0);
    expect(state.reps, 1);
    expect(state.saveError, isNull);
  });

  test(
    'failed logging keeps current values and exposes retry message',
    () async {
      final repository = _FailingWorkoutRepository();
      final controller = ActiveWorkoutController(repository: repository);
      await controller.load();
      controller.updateWeight(135);
      controller.updateReps(8);

      final state = await controller.logSet(now: DateTime(2026, 5, 9, 12));

      expect(state.weight, 135);
      expect(state.reps, 8);
      expect(state.setIndex, 1);
      expect(state.isResting, isFalse);
      expect(state.saveError, 'Set not saved. Retry.');
    },
  );

  test('ignores edits while a set save is in flight', () async {
    final repository = _DelayedWorkoutRepository();
    final controller = ActiveWorkoutController(repository: repository);
    await controller.load();

    final save = controller.logSet(now: DateTime(2026, 5, 9, 12));
    await repository.saveStarted.future;

    final edited = controller.updateWeight(135);
    expect(edited.isSaving, isTrue);
    expect(edited.weight, 225);

    repository.finishSave();
    final state = await save;

    expect(state.isSaving, isFalse);
    expect(state.weight, 225);
    expect(repository.savedWeights, [225]);
  });

  test('ignores a second log request while a set save is in flight', () async {
    final repository = _DelayedWorkoutRepository();
    final controller = ActiveWorkoutController(repository: repository);
    await controller.load();

    final firstSave = controller.logSet(now: DateTime(2026, 5, 9, 12));
    await repository.saveStarted.future;

    final secondState = await controller.logSet(
      now: DateTime(2026, 5, 9, 12, 1),
    );

    expect(secondState.isSaving, isTrue);
    expect(repository.logCalls, 1);

    repository.finishSave();
    final finalState = await firstSave;

    expect(finalState.setIndex, 2);
    expect(repository.logCalls, 1);
  });

  test(
    'refresh failure after successful save does not report unsaved retry',
    () async {
      final repository = _RefreshFailingWorkoutRepository();
      final controller = ActiveWorkoutController(repository: repository);
      await controller.load();

      final state = await controller.logSet(now: DateTime(2026, 5, 9, 12));

      expect(repository.logCalls, 1);
      expect(state.isSaving, isFalse);
      expect(state.isResting, isTrue);
      expect(state.restStartedAt, DateTime(2026, 5, 9, 12));
      expect(state.setIndex, 2);
      expect(state.saveError, 'Set saved. Refresh workout.');
    },
  );

  test(
    'refresh failure after successful save does not reuse set index on next log',
    () async {
      final repository = _RefreshFailingWorkoutRepository();
      final controller = ActiveWorkoutController(repository: repository);
      await controller.load();

      await controller.logSet(now: DateTime(2026, 5, 9, 12));
      repository.failRefresh = false;
      final state = await controller.logSet(now: DateTime(2026, 5, 9, 12, 5));

      expect(repository.savedSetIndexes, [1, 2]);
      expect(state.setIndex, 3);
      expect(state.saveError, isNull);
    },
  );
}

class _FailingWorkoutRepository implements WorkoutRepository {
  final Exercise _exercise = const Exercise(
    id: 'bench-press',
    name: 'Bench Press',
  );
  final WorkoutSession _session = WorkoutSession(
    id: 'current-session',
    startedAt: DateTime(2026, 5, 9, 12),
  );
  final List<WorkoutSet> _previousSets = [
    WorkoutSet(
      id: 'previous-session-bench-press-1',
      sessionId: 'previous-session',
      exerciseId: 'bench-press',
      setIndex: 1,
      weight: 135,
      reps: 5,
      completedAt: DateTime(2026, 5, 2, 12),
    ),
  ];

  @override
  Future<Exercise> activeExercise() async => _exercise;

  @override
  Future<WorkoutSession> activeSession() async => _session;

  @override
  Future<void> close() async {}

  @override
  Future<List<WorkoutSet>> currentSetsForExercise(String exerciseId) async =>
      [];

  @override
  Future<WorkoutSet> logSet({
    required String sessionId,
    required String exerciseId,
    required int setIndex,
    required double weight,
    required int reps,
    required DateTime completedAt,
  }) {
    throw Exception('insert failed');
  }

  @override
  Future<List<WorkoutSet>> previousSetsForExercise(String exerciseId) async {
    return _previousSets;
  }

  @override
  Future<void> seedIfEmpty() async {}
}

class _DelayedWorkoutRepository extends _MemoryWorkoutRepository {
  final Completer<void> saveStarted = Completer<void>();
  final Completer<void> _finishSave = Completer<void>();
  final List<double> savedWeights = [];
  int logCalls = 0;

  void finishSave() {
    if (!_finishSave.isCompleted) {
      _finishSave.complete();
    }
  }

  @override
  Future<WorkoutSet> logSet({
    required String sessionId,
    required String exerciseId,
    required int setIndex,
    required double weight,
    required int reps,
    required DateTime completedAt,
  }) async {
    logCalls += 1;
    savedWeights.add(weight);
    if (!saveStarted.isCompleted) {
      saveStarted.complete();
    }
    await _finishSave.future;
    return super.logSet(
      sessionId: sessionId,
      exerciseId: exerciseId,
      setIndex: setIndex,
      weight: weight,
      reps: reps,
      completedAt: completedAt,
    );
  }
}

class _RefreshFailingWorkoutRepository extends _MemoryWorkoutRepository {
  int logCalls = 0;
  bool failRefresh = true;
  final List<int> savedSetIndexes = [];

  @override
  Future<WorkoutSet> logSet({
    required String sessionId,
    required String exerciseId,
    required int setIndex,
    required double weight,
    required int reps,
    required DateTime completedAt,
  }) {
    logCalls += 1;
    savedSetIndexes.add(setIndex);
    return super.logSet(
      sessionId: sessionId,
      exerciseId: exerciseId,
      setIndex: setIndex,
      weight: weight,
      reps: reps,
      completedAt: completedAt,
    );
  }

  @override
  Future<List<WorkoutSet>> currentSetsForExercise(String exerciseId) {
    if (failRefresh && logCalls > 0) {
      throw Exception('refresh failed');
    }
    return super.currentSetsForExercise(exerciseId);
  }
}

class _MemoryWorkoutRepository implements WorkoutRepository {
  final Exercise _exercise = const Exercise(
    id: 'bench-press',
    name: 'Bench Press',
  );
  final WorkoutSession _session = WorkoutSession(
    id: 'current-session',
    startedAt: DateTime(2026, 5, 9, 12),
  );
  final List<WorkoutSet> _previousSets = [
    WorkoutSet(
      id: 'previous-session-bench-press-1',
      sessionId: 'previous-session',
      exerciseId: 'bench-press',
      setIndex: 1,
      weight: 225,
      reps: 5,
      completedAt: DateTime(2026, 5, 2, 12),
    ),
  ];
  final List<WorkoutSet> _currentSets = [];

  @override
  Future<Exercise> activeExercise() async => _exercise;

  @override
  Future<WorkoutSession> activeSession() async => _session;

  @override
  Future<void> close() async {}

  @override
  Future<List<WorkoutSet>> currentSetsForExercise(String exerciseId) async {
    return List.unmodifiable(_currentSets);
  }

  @override
  Future<WorkoutSet> logSet({
    required String sessionId,
    required String exerciseId,
    required int setIndex,
    required double weight,
    required int reps,
    required DateTime completedAt,
  }) async {
    final set = WorkoutSet(
      id: '$sessionId-$exerciseId-$setIndex',
      sessionId: sessionId,
      exerciseId: exerciseId,
      setIndex: setIndex,
      weight: weight,
      reps: reps,
      completedAt: completedAt,
    );
    _currentSets.add(set);
    return set;
  }

  @override
  Future<List<WorkoutSet>> previousSetsForExercise(String exerciseId) async {
    return List.unmodifiable(_previousSets);
  }

  @override
  Future<void> seedIfEmpty() async {}
}
