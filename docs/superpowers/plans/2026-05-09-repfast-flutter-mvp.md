# RepFast Flutter MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the RepFast offline MVP Flutter app: a single-cockpit gym-floor logger with SQLite persistence, previous-set defaults, rest timing, and instant today-vs-last-time comparison.

**Architecture:** Create a new Flutter app in `repfast_app/` with a domain-first structure. Pure Dart domain logic lives under `lib/src/domain`, persistence contracts and SQLite implementation live under `lib/src/data`, active workout state lives under `lib/src/application`, and UI widgets live under `lib/src/ui`. Tests start with pure domain tests, then repository tests, then widget tests.

**Tech Stack:** Flutter 3.41.7, Dart 3.11.5, Material 3, `sqflite`, `path`, `flutter_test`, `test`.

---

## File Structure

- Create: `repfast_app/`
- Create: `repfast_app/lib/main.dart`
- Create: `repfast_app/lib/src/domain/models.dart`
- Create: `repfast_app/lib/src/domain/calculators.dart`
- Create: `repfast_app/lib/src/domain/comparison.dart`
- Create: `repfast_app/lib/src/data/workout_repository.dart`
- Create: `repfast_app/lib/src/data/sqlite_workout_repository.dart`
- Create: `repfast_app/lib/src/application/active_workout_controller.dart`
- Create: `repfast_app/lib/src/ui/repfast_app.dart`
- Create: `repfast_app/lib/src/ui/theme.dart`
- Create: `repfast_app/lib/src/ui/screens/active_cockpit_screen.dart`
- Create: `repfast_app/lib/src/ui/widgets/numeric_stepper.dart`
- Create: `repfast_app/lib/src/ui/widgets/comparison_strip.dart`
- Create: `repfast_app/lib/src/ui/widgets/rest_timer_chip.dart`
- Create: `repfast_app/test/domain/calculators_test.dart`
- Create: `repfast_app/test/domain/comparison_test.dart`
- Create: `repfast_app/test/application/active_workout_controller_test.dart`
- Create: `repfast_app/test/data/sqlite_workout_repository_test.dart`
- Create: `repfast_app/test/ui/active_cockpit_screen_test.dart`

## Task 1: Scaffold Flutter App

**Files:**
- Create: `repfast_app/`
- Modify: `repfast_app/pubspec.yaml`

- [ ] **Step 1: Create Flutter project**

Run:

```bash
flutter create --empty --project-name repfast_app --org com.repfast --platforms ios,android repfast_app
```

Expected: `repfast_app/` exists with `pubspec.yaml`, `lib/main.dart`, `test/widget_test.dart`, `ios/`, and `android/`.

- [ ] **Step 2: Add dependencies**

Modify `repfast_app/pubspec.yaml` so the dependency section includes:

```yaml
dependencies:
  flutter:
    sdk: flutter
  path: ^1.9.1
  sqflite: ^2.4.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  test: ^1.26.3
```

- [ ] **Step 3: Fetch packages**

Run:

```bash
cd repfast_app && flutter pub get
```

Expected: package resolution succeeds and `pubspec.lock` is created.

- [ ] **Step 4: Commit scaffold**

```bash
git add repfast_app
git commit -m "Add Flutter app scaffold"
```

## Task 2: Domain Models and Calculators

**Files:**
- Create: `repfast_app/test/domain/calculators_test.dart`
- Create: `repfast_app/lib/src/domain/models.dart`
- Create: `repfast_app/lib/src/domain/calculators.dart`

- [ ] **Step 1: Write failing calculator tests**

Create `repfast_app/test/domain/calculators_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:repfast_app/src/domain/calculators.dart';

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
}
```

- [ ] **Step 2: Verify RED**

Run:

```bash
cd repfast_app && flutter test test/domain/calculators_test.dart
```

Expected: FAIL because `repfast_app/src/domain/calculators.dart` does not exist.

- [ ] **Step 3: Implement domain models**

Create `repfast_app/lib/src/domain/models.dart`:

```dart
class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    this.weightIncrement = 5,
    this.repIncrement = 1,
  });

  final String id;
  final String name;
  final double weightIncrement;
  final int repIncrement;
}

class WorkoutSession {
  const WorkoutSession({
    required this.id,
    required this.startedAt,
    this.completedAt,
  });

  final String id;
  final DateTime startedAt;
  final DateTime? completedAt;
}

class WorkoutSet {
  const WorkoutSet({
    required this.id,
    required this.sessionId,
    required this.exerciseId,
    required this.setIndex,
    required this.weight,
    required this.reps,
    required this.completedAt,
  });

  final String id;
  final String sessionId;
  final String exerciseId;
  final int setIndex;
  final double weight;
  final int reps;
  final DateTime completedAt;

  double get volume => weight * reps;
}
```

- [ ] **Step 4: Implement calculators**

Create `repfast_app/lib/src/domain/calculators.dart`:

```dart
class RepFastCalculators {
  const RepFastCalculators._();

  static double volume({required double weight, required int reps}) {
    return weight * reps;
  }

  static double estimatedOneRepMax({required double weight, required int reps}) {
    return weight * (1 + reps / 30);
  }

  static String displayWeight(double weight) {
    if (weight == weight.roundToDouble()) {
      return weight.toStringAsFixed(0);
    }
    return weight.toStringAsFixed(1);
  }
}
```

- [ ] **Step 5: Verify GREEN**

Run:

```bash
cd repfast_app && flutter test test/domain/calculators_test.dart
```

Expected: PASS.

- [ ] **Step 6: Commit domain calculators**

```bash
git add repfast_app/lib/src/domain repfast_app/test/domain/calculators_test.dart
git commit -m "Add workout domain calculators"
```

## Task 3: Session Comparison Domain Logic

**Files:**
- Create: `repfast_app/test/domain/comparison_test.dart`
- Create: `repfast_app/lib/src/domain/comparison.dart`

- [ ] **Step 1: Write failing comparison tests**

Create `repfast_app/test/domain/comparison_test.dart`:

```dart
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
}
```

- [ ] **Step 2: Verify RED**

Run:

```bash
cd repfast_app && flutter test test/domain/comparison_test.dart
```

Expected: FAIL because `comparison.dart` does not exist.

- [ ] **Step 3: Implement comparison logic**

Create `repfast_app/lib/src/domain/comparison.dart`:

```dart
import 'models.dart';
import 'calculators.dart';

class WorkoutComparisonResult {
  const WorkoutComparisonResult({
    required this.currentVolume,
    required this.previousVolume,
    required this.volumeDeltaPercent,
    required this.isPersonalRecord,
    required this.takeaway,
    this.bestSet,
  });

  final double currentVolume;
  final double previousVolume;
  final double volumeDeltaPercent;
  final bool isPersonalRecord;
  final String takeaway;
  final WorkoutSet? bestSet;
}

class WorkoutComparison {
  const WorkoutComparison._();

  static WorkoutSet? previousSetForExercise(
    List<WorkoutSet> sets, {
    required String exerciseId,
  }) {
    final matching = sets.where((set) => set.exerciseId == exerciseId).toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return matching.isEmpty ? null : matching.first;
  }

  static WorkoutComparisonResult compare({
    required List<WorkoutSet> currentSets,
    required List<WorkoutSet> previousSets,
  }) {
    final currentVolume = _totalVolume(currentSets);
    final previousVolume = _totalVolume(previousSets);
    final bestCurrentSet = _bestSet(currentSets);
    final bestPreviousSet = _bestSet(previousSets);
    final currentBestOrm = bestCurrentSet == null ? 0 : RepFastCalculators.estimatedOneRepMax(weight: bestCurrentSet.weight, reps: bestCurrentSet.reps);
    final previousBestOrm = bestPreviousSet == null ? 0 : RepFastCalculators.estimatedOneRepMax(weight: bestPreviousSet.weight, reps: bestPreviousSet.reps);
    final delta = previousVolume == 0 ? 0 : ((currentVolume - previousVolume) / previousVolume) * 100;

    return WorkoutComparisonResult(
      currentVolume: currentVolume,
      previousVolume: previousVolume,
      volumeDeltaPercent: delta,
      isPersonalRecord: currentBestOrm > previousBestOrm,
      bestSet: bestCurrentSet,
      takeaway: _takeaway(bestCurrentSet, bestPreviousSet, previousVolume),
    );
  }

  static double _totalVolume(List<WorkoutSet> sets) {
    return sets.fold(0, (sum, set) => sum + set.volume);
  }

  static WorkoutSet? _bestSet(List<WorkoutSet> sets) {
    if (sets.isEmpty) return null;
    return sets.reduce((best, next) {
      final bestOrm = RepFastCalculators.estimatedOneRepMax(weight: best.weight, reps: best.reps);
      final nextOrm = RepFastCalculators.estimatedOneRepMax(weight: next.weight, reps: next.reps);
      return nextOrm > bestOrm ? next : best;
    });
  }

  static String _takeaway(WorkoutSet? current, WorkoutSet? previous, double previousVolume) {
    if (current == null) return 'Log your first set to compare this lift.';
    if (previous == null || previousVolume == 0) return 'First logged set for this lift.';
    if (current.weight == previous.weight && current.reps > previous.reps) {
      return 'You added one rep at the same weight.';
    }
    if (current.weight > previous.weight) return 'You moved more weight than last time.';
    if (current.weight == previous.weight && current.reps == previous.reps) return 'You matched last time.';
    return 'Keep the next set controlled and compare again.';
  }
}
```

- [ ] **Step 4: Verify GREEN**

Run:

```bash
cd repfast_app && flutter test test/domain/comparison_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit comparison logic**

```bash
git add repfast_app/lib/src/domain repfast_app/test/domain
git commit -m "Add workout comparison logic"
```

## Task 4: Repository Contract and SQLite Persistence

**Files:**
- Create: `repfast_app/test/data/sqlite_workout_repository_test.dart`
- Create: `repfast_app/lib/src/data/workout_repository.dart`
- Create: `repfast_app/lib/src/data/sqlite_workout_repository.dart`

- [ ] **Step 1: Write failing repository tests**

Create `repfast_app/test/data/sqlite_workout_repository_test.dart`:

```dart
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

  test('persists a logged set and returns it in current session sets', () async {
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
  });
}
```

- [ ] **Step 2: Verify RED**

Run:

```bash
cd repfast_app && flutter test test/data/sqlite_workout_repository_test.dart
```

Expected: FAIL because data files do not exist.

- [ ] **Step 3: Define repository contract**

Create `repfast_app/lib/src/data/workout_repository.dart`:

```dart
import '../domain/models.dart';

abstract class WorkoutRepository {
  Future<void> seedIfEmpty();
  Future<Exercise> activeExercise();
  Future<WorkoutSession> activeSession();
  Future<List<WorkoutSet>> previousSetsForExercise(String exerciseId);
  Future<List<WorkoutSet>> currentSetsForExercise(String exerciseId);
  Future<WorkoutSet> logSet({
    required String sessionId,
    required String exerciseId,
    required int setIndex,
    required double weight,
    required int reps,
    required DateTime completedAt,
  });
}
```

- [ ] **Step 4: Implement SQLite repository**

Create `repfast_app/lib/src/data/sqlite_workout_repository.dart` with:

```dart
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../domain/models.dart';
import 'workout_repository.dart';

class SqliteWorkoutRepository implements WorkoutRepository {
  SqliteWorkoutRepository._(this._database);

  final Database _database;

  static Future<SqliteWorkoutRepository> open() async {
    final dbPath = await getDatabasesPath();
    final database = await _openDatabase(p.join(dbPath, 'repfast.db'));
    return SqliteWorkoutRepository._(database);
  }

  static Future<SqliteWorkoutRepository> inMemory() async {
    final database = await _openDatabase(inMemoryDatabasePath);
    return SqliteWorkoutRepository._(database);
  }

  static Future<Database> _openDatabase(String path) {
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE exercises(id TEXT PRIMARY KEY, name TEXT NOT NULL, weight_increment REAL NOT NULL, rep_increment INTEGER NOT NULL)');
        await db.execute('CREATE TABLE sessions(id TEXT PRIMARY KEY, started_at TEXT NOT NULL, completed_at TEXT)');
        await db.execute('CREATE TABLE sets(id TEXT PRIMARY KEY, session_id TEXT NOT NULL, exercise_id TEXT NOT NULL, set_index INTEGER NOT NULL, weight REAL NOT NULL, reps INTEGER NOT NULL, completed_at TEXT NOT NULL)');
      },
    );
  }

  @override
  Future<void> seedIfEmpty() async {
    final count = Sqflite.firstIntValue(await _database.rawQuery('SELECT COUNT(*) FROM exercises')) ?? 0;
    if (count > 0) return;

    await _database.insert('exercises', {
      'id': 'bench',
      'name': 'Bench Press',
      'weight_increment': 5.0,
      'rep_increment': 1,
    });
    await _database.insert('sessions', {
      'id': 'previous',
      'started_at': DateTime(2026, 5, 2, 12).toIso8601String(),
      'completed_at': DateTime(2026, 5, 2, 13).toIso8601String(),
    });
    await _database.insert('sessions', {
      'id': 'current',
      'started_at': DateTime(2026, 5, 9, 12).toIso8601String(),
      'completed_at': null,
    });
    await _database.insert('sets', _setMap('previous-bench-1', 'previous', 'bench', 1, 185, 8, DateTime(2026, 5, 2, 12, 10)));
    await _database.insert('sets', _setMap('previous-bench-2', 'previous', 'bench', 2, 205, 6, DateTime(2026, 5, 2, 12, 15)));
    await _database.insert('sets', _setMap('previous-bench-3', 'previous', 'bench', 3, 225, 5, DateTime(2026, 5, 2, 12, 20)));
  }

  @override
  Future<Exercise> activeExercise() async {
    final rows = await _database.query('exercises', limit: 1);
    return _exerciseFromRow(rows.single);
  }

  @override
  Future<WorkoutSession> activeSession() async {
    final rows = await _database.query('sessions', where: 'completed_at IS NULL', limit: 1);
    return _sessionFromRow(rows.single);
  }

  @override
  Future<List<WorkoutSet>> previousSetsForExercise(String exerciseId) async {
    final rows = await _database.query('sets', where: 'exercise_id = ? AND session_id != ?', whereArgs: [exerciseId, 'current'], orderBy: 'completed_at ASC');
    return rows.map(_setFromRow).toList();
  }

  @override
  Future<List<WorkoutSet>> currentSetsForExercise(String exerciseId) async {
    final rows = await _database.query('sets', where: 'exercise_id = ? AND session_id = ?', whereArgs: [exerciseId, 'current'], orderBy: 'set_index ASC');
    return rows.map(_setFromRow).toList();
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
      id: '$sessionId-$exerciseId-$setIndex-${completedAt.microsecondsSinceEpoch}',
      sessionId: sessionId,
      exerciseId: exerciseId,
      setIndex: setIndex,
      weight: weight,
      reps: reps,
      completedAt: completedAt,
    );
    await _database.insert('sets', _setMap(set.id, sessionId, exerciseId, setIndex, weight, reps, completedAt));
    return set;
  }

  static Map<String, Object?> _setMap(String id, String sessionId, String exerciseId, int setIndex, double weight, int reps, DateTime completedAt) {
    return {
      'id': id,
      'session_id': sessionId,
      'exercise_id': exerciseId,
      'set_index': setIndex,
      'weight': weight,
      'reps': reps,
      'completed_at': completedAt.toIso8601String(),
    };
  }

  static Exercise _exerciseFromRow(Map<String, Object?> row) {
    return Exercise(
      id: row['id'] as String,
      name: row['name'] as String,
      weightIncrement: row['weight_increment'] as double,
      repIncrement: row['rep_increment'] as int,
    );
  }

  static WorkoutSession _sessionFromRow(Map<String, Object?> row) {
    return WorkoutSession(
      id: row['id'] as String,
      startedAt: DateTime.parse(row['started_at'] as String),
      completedAt: row['completed_at'] == null ? null : DateTime.parse(row['completed_at'] as String),
    );
  }

  static WorkoutSet _setFromRow(Map<String, Object?> row) {
    return WorkoutSet(
      id: row['id'] as String,
      sessionId: row['session_id'] as String,
      exerciseId: row['exercise_id'] as String,
      setIndex: row['set_index'] as int,
      weight: row['weight'] as double,
      reps: row['reps'] as int,
      completedAt: DateTime.parse(row['completed_at'] as String),
    );
  }
}
```

- [ ] **Step 5: Verify GREEN**

Run:

```bash
cd repfast_app && flutter test test/data/sqlite_workout_repository_test.dart
```

Expected: PASS.

- [ ] **Step 6: Commit persistence**

```bash
git add repfast_app/lib/src/data repfast_app/test/data repfast_app/pubspec.yaml repfast_app/pubspec.lock
git commit -m "Add SQLite workout repository"
```

## Task 5: Active Workout Controller

**Files:**
- Create: `repfast_app/test/application/active_workout_controller_test.dart`
- Create: `repfast_app/lib/src/application/active_workout_controller.dart`

- [ ] **Step 1: Write failing controller tests**

Create `repfast_app/test/application/active_workout_controller_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:repfast_app/src/application/active_workout_controller.dart';
import 'package:repfast_app/src/data/sqlite_workout_repository.dart';

void main() {
  test('loads previous defaults into active state', () async {
    final repository = await SqliteWorkoutRepository.inMemory();
    await repository.seedIfEmpty();
    final controller = ActiveWorkoutController(repository: repository);

    final state = await controller.load();

    expect(state.exercise.name, 'Bench Press');
    expect(state.weight, 225);
    expect(state.reps, 5);
    expect(state.setIndex, 1);
    expect(state.statusLabel, 'Saved on device');
  });

  test('logging a set persists it, advances set index, starts rest, and updates comparison', () async {
    final repository = await SqliteWorkoutRepository.inMemory();
    await repository.seedIfEmpty();
    final controller = ActiveWorkoutController(repository: repository);
    await controller.load();
    controller.updateReps(6);

    final state = await controller.logSet(now: DateTime(2026, 5, 9, 12));

    expect(state.setIndex, 2);
    expect(state.isResting, isTrue);
    expect(state.comparison.volumeDeltaPercent, greaterThan(0));
    expect(state.comparison.takeaway, 'You added one rep at the same weight.');
  });
}
```

- [ ] **Step 2: Verify RED**

Run:

```bash
cd repfast_app && flutter test test/application/active_workout_controller_test.dart
```

Expected: FAIL because controller does not exist.

- [ ] **Step 3: Implement controller**

Create `repfast_app/lib/src/application/active_workout_controller.dart`:

```dart
import '../data/workout_repository.dart';
import '../domain/comparison.dart';
import '../domain/models.dart';

class ActiveWorkoutState {
  const ActiveWorkoutState({
    required this.exercise,
    required this.session,
    required this.weight,
    required this.reps,
    required this.setIndex,
    required this.isResting,
    required this.statusLabel,
    required this.comparison,
    this.saveError,
  });

  final Exercise exercise;
  final WorkoutSession session;
  final double weight;
  final int reps;
  final int setIndex;
  final bool isResting;
  final String statusLabel;
  final WorkoutComparisonResult comparison;
  final String? saveError;

  ActiveWorkoutState copyWith({
    double? weight,
    int? reps,
    int? setIndex,
    bool? isResting,
    String? statusLabel,
    WorkoutComparisonResult? comparison,
    String? saveError,
  }) {
    return ActiveWorkoutState(
      exercise: exercise,
      session: session,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      setIndex: setIndex ?? this.setIndex,
      isResting: isResting ?? this.isResting,
      statusLabel: statusLabel ?? this.statusLabel,
      comparison: comparison ?? this.comparison,
      saveError: saveError,
    );
  }
}

class ActiveWorkoutController {
  ActiveWorkoutController({required WorkoutRepository repository}) : _repository = repository;

  final WorkoutRepository _repository;
  ActiveWorkoutState? _state;

  ActiveWorkoutState get state {
    final value = _state;
    if (value == null) throw StateError('Active workout has not loaded.');
    return value;
  }

  Future<ActiveWorkoutState> load() async {
    await _repository.seedIfEmpty();
    final exercise = await _repository.activeExercise();
    final session = await _repository.activeSession();
    final previousSets = await _repository.previousSetsForExercise(exercise.id);
    final currentSets = await _repository.currentSetsForExercise(exercise.id);
    final previous = WorkoutComparison.previousSetForExercise(previousSets, exerciseId: exercise.id);

    _state = ActiveWorkoutState(
      exercise: exercise,
      session: session,
      weight: previous?.weight ?? 45,
      reps: previous?.reps ?? 5,
      setIndex: currentSets.length + 1,
      isResting: false,
      statusLabel: 'Saved on device',
      comparison: WorkoutComparison.compare(currentSets: currentSets, previousSets: previousSets),
    );
    return state;
  }

  void updateWeight(double value) {
    _state = state.copyWith(weight: value < 0 ? 0 : value, saveError: null);
  }

  void updateReps(int value) {
    _state = state.copyWith(reps: value < 1 ? 1 : value, saveError: null);
  }

  Future<ActiveWorkoutState> logSet({DateTime? now}) async {
    final current = state;
    try {
      await _repository.logSet(
        sessionId: current.session.id,
        exerciseId: current.exercise.id,
        setIndex: current.setIndex,
        weight: current.weight,
        reps: current.reps,
        completedAt: now ?? DateTime.now(),
      );
      final currentSets = await _repository.currentSetsForExercise(current.exercise.id);
      final previousSets = await _repository.previousSetsForExercise(current.exercise.id);
      _state = current.copyWith(
        setIndex: currentSets.length + 1,
        isResting: true,
        statusLabel: 'Saved on device',
        comparison: WorkoutComparison.compare(currentSets: currentSets, previousSets: previousSets),
        saveError: null,
      );
      return state;
    } catch (_) {
      _state = current.copyWith(saveError: 'Set not saved. Retry.');
      return state;
    }
  }
}
```

- [ ] **Step 4: Verify GREEN**

Run:

```bash
cd repfast_app && flutter test test/application/active_workout_controller_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit controller**

```bash
git add repfast_app/lib/src/application repfast_app/test/application
git commit -m "Add active workout controller"
```

## Task 6: Dark Gym Mode UI Components

**Files:**
- Create: `repfast_app/lib/src/ui/theme.dart`
- Create: `repfast_app/lib/src/ui/widgets/numeric_stepper.dart`
- Create: `repfast_app/lib/src/ui/widgets/comparison_strip.dart`
- Create: `repfast_app/lib/src/ui/widgets/rest_timer_chip.dart`

- [ ] **Step 1: Create theme**

Create `repfast_app/lib/src/ui/theme.dart`:

```dart
import 'package:flutter/material.dart';

class RepFastColors {
  const RepFastColors._();

  static const background = Color(0xFF050708);
  static const surface = Color(0xFF0C141A);
  static const surfaceRaised = Color(0xFF111C23);
  static const border = Color(0xFF243640);
  static const text = Color(0xFFF2FBFB);
  static const muted = Color(0xFF9AADB4);
  static const cyan = Color(0xFF24E6D0);
  static const green = Color(0xFF37EE8A);
  static const amber = Color(0xFFF5B84B);
  static const red = Color(0xFFFF6B6B);
}

ThemeData repFastTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: RepFastColors.background,
    colorScheme: const ColorScheme.dark(
      primary: RepFastColors.cyan,
      secondary: RepFastColors.green,
      error: RepFastColors.red,
      surface: RepFastColors.surface,
      onSurface: RepFastColors.text,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: RepFastColors.text),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: RepFastColors.text),
      bodyMedium: TextStyle(fontSize: 16, color: RepFastColors.muted),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: RepFastColors.text),
    ),
  );
}
```

- [ ] **Step 2: Create numeric stepper**

Create `repfast_app/lib/src/ui/widgets/numeric_stepper.dart`:

```dart
import 'package:flutter/material.dart';

import '../theme.dart';

class NumericStepper extends StatelessWidget {
  const NumericStepper({
    super.key,
    required this.label,
    required this.valueText,
    this.unit,
    required this.onDecrease,
    required this.onIncrease,
  });

  final String label;
  final String valueText;
  final String? unit;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 104),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: RepFastColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: RepFastColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label.toUpperCase(), style: Theme.of(context).textTheme.labelLarge?.copyWith(color: RepFastColors.muted)),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(valueText, style: Theme.of(context).textTheme.headlineMedium),
                    if (unit != null) ...[
                      const SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(unit!, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: RepFastColors.cyan)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _StepperButton(label: 'Decrease $label', symbol: '-', onPressed: onDecrease),
          const SizedBox(width: 8),
          _StepperButton(label: 'Increase $label', symbol: '+', onPressed: onIncrease),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.label,
    required this.symbol,
    required this.onPressed,
  });

  final String label;
  final String symbol;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: FilledButton(
        style: FilledButton.styleFrom(
          minimumSize: const Size(56, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: RepFastColors.surfaceRaised,
          foregroundColor: RepFastColors.text,
        ),
        onPressed: onPressed,
        child: Text(symbol, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
      ),
    );
  }
}
```

- [ ] **Step 3: Create comparison strip**

Create `repfast_app/lib/src/ui/widgets/comparison_strip.dart`:

```dart
import 'package:flutter/material.dart';

import '../../domain/calculators.dart';
import '../../domain/comparison.dart';
import '../theme.dart';

class ComparisonStrip extends StatelessWidget {
  const ComparisonStrip({super.key, required this.result});

  final WorkoutComparisonResult result;

  @override
  Widget build(BuildContext context) {
    final bestSet = result.bestSet;
    final deltaText = result.previousVolume == 0
        ? 'New'
        : '${result.volumeDeltaPercent >= 0 ? '+' : ''}${result.volumeDeltaPercent.toStringAsFixed(0)}%';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF08100D),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: RepFastColors.green.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Today vs last time', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: RepFastColors.green)),
              const Spacer(),
              if (result.isPersonalRecord)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: RepFastColors.amber),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('PR', style: TextStyle(color: RepFastColors.amber, fontWeight: FontWeight.w900)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(deltaText, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: RepFastColors.green)),
              const SizedBox(width: 16),
              if (bestSet != null)
                Expanded(
                  child: Text(
                    'Best ${RepFastCalculators.displayWeight(bestSet.weight)} x ${bestSet.reps}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(result.takeaway, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: RepFastColors.text)),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Create rest timer chip**

Create `repfast_app/lib/src/ui/widgets/rest_timer_chip.dart`:

```dart
import 'package:flutter/material.dart';

import '../theme.dart';

class RestTimerChip extends StatelessWidget {
  const RestTimerChip({super.key, required this.isResting});

  final bool isResting;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isResting ? RepFastColors.green.withValues(alpha: 0.1) : RepFastColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isResting ? RepFastColors.green : RepFastColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isResting ? Icons.timer_outlined : Icons.bolt_outlined,
            size: 18,
            color: isResting ? RepFastColors.green : RepFastColors.cyan,
          ),
          const SizedBox(width: 8),
          Text(
            isResting ? 'Rest started' : 'Ready',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: isResting ? RepFastColors.green : RepFastColors.text),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 5: Commit UI components**

```bash
git add repfast_app/lib/src/ui
git commit -m "Add RepFast UI components"
```

## Task 7: Active Cockpit Screen and App Shell

**Files:**
- Create: `repfast_app/test/ui/active_cockpit_screen_test.dart`
- Create: `repfast_app/lib/src/ui/screens/active_cockpit_screen.dart`
- Create: `repfast_app/lib/src/ui/repfast_app.dart`
- Modify: `repfast_app/lib/main.dart`

- [ ] **Step 1: Write failing widget tests**

Create `repfast_app/test/ui/active_cockpit_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repfast_app/src/application/active_workout_controller.dart';
import 'package:repfast_app/src/data/sqlite_workout_repository.dart';
import 'package:repfast_app/src/ui/repfast_app.dart';

void main() {
  testWidgets('cockpit renders active lift defaults and comparison', (tester) async {
    final repository = await SqliteWorkoutRepository.inMemory();
    final controller = ActiveWorkoutController(repository: repository);

    await tester.pumpWidget(RepFastApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('Bench Press'), findsOneWidget);
    expect(find.text('225'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('LOG SET'), findsOneWidget);
    expect(find.text('Today vs last time'), findsOneWidget);
  });

  testWidgets('log set updates reps comparison and starts rest', (tester) async {
    final repository = await SqliteWorkoutRepository.inMemory();
    final controller = ActiveWorkoutController(repository: repository);

    await tester.pumpWidget(RepFastApp(controller: controller));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Increase reps'));
    await tester.pump();
    await tester.tap(find.text('LOG SET'));
    await tester.pumpAndSettle();

    expect(find.text('Rest started'), findsOneWidget);
    expect(find.textContaining('+'), findsWidgets);
    expect(find.text('You added one rep at the same weight.'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Verify RED**

Run:

```bash
cd repfast_app && flutter test test/ui/active_cockpit_screen_test.dart
```

Expected: FAIL because app UI files do not exist.

- [ ] **Step 3: Implement app shell**

Create `repfast_app/lib/src/ui/repfast_app.dart`:

```dart
import 'package:flutter/material.dart';

import '../application/active_workout_controller.dart';
import 'screens/active_cockpit_screen.dart';
import 'theme.dart';

class RepFastApp extends StatelessWidget {
  const RepFastApp({super.key, required this.controller});

  final ActiveWorkoutController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RepFast',
      debugShowCheckedModeBanner: false,
      theme: repFastTheme(),
      home: ActiveCockpitScreen(controller: controller),
    );
  }
}
```

- [ ] **Step 4: Implement active cockpit screen**

Create `repfast_app/lib/src/ui/screens/active_cockpit_screen.dart`:

```dart
import 'package:flutter/material.dart';

import '../../application/active_workout_controller.dart';
import '../../domain/calculators.dart';
import '../theme.dart';
import '../widgets/comparison_strip.dart';
import '../widgets/numeric_stepper.dart';
import '../widgets/rest_timer_chip.dart';

class ActiveCockpitScreen extends StatefulWidget {
  const ActiveCockpitScreen({super.key, required this.controller});

  final ActiveWorkoutController controller;

  @override
  State<ActiveCockpitScreen> createState() => _ActiveCockpitScreenState();
}

class _ActiveCockpitScreenState extends State<ActiveCockpitScreen> {
  ActiveWorkoutState? _state;
  Object? _error;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final state = await widget.controller.load();
      if (!mounted) return;
      setState(() => _state = state);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    }
  }

  void _changeWeight(double delta) {
    final current = _state;
    if (current == null) return;
    widget.controller.updateWeight(current.weight + delta);
    setState(() => _state = widget.controller.state);
  }

  void _changeReps(int delta) {
    final current = _state;
    if (current == null) return;
    widget.controller.updateReps(current.reps + delta);
    setState(() => _state = widget.controller.state);
  }

  Future<void> _logSet() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    final state = await widget.controller.logSet();
    if (!mounted) return;
    setState(() {
      _state = state;
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: _error != null
              ? _ErrorState(onRetry: _load)
              : state == null
                  ? const Center(child: CircularProgressIndicator())
                  : _CockpitBody(
                      state: state,
                      isSaving: _isSaving,
                      onWeightDown: () => _changeWeight(-state.exercise.weightIncrement),
                      onWeightUp: () => _changeWeight(state.exercise.weightIncrement),
                      onRepsDown: () => _changeReps(-state.exercise.repIncrement),
                      onRepsUp: () => _changeReps(state.exercise.repIncrement),
                      onLogSet: _logSet,
                    ),
        ),
      ),
    );
  }
}

class _CockpitBody extends StatelessWidget {
  const _CockpitBody({
    required this.state,
    required this.isSaving,
    required this.onWeightDown,
    required this.onWeightUp,
    required this.onRepsDown,
    required this.onRepsUp,
    required this.onLogSet,
  });

  final ActiveWorkoutState state;
  final bool isSaving;
  final VoidCallback onWeightDown;
  final VoidCallback onWeightUp;
  final VoidCallback onRepsDown;
  final VoidCallback onRepsUp;
  final VoidCallback onLogSet;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Row(
          children: [
            Text('RepFast', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: RepFastColors.cyan)),
            const Spacer(),
            RestTimerChip(isResting: state.isResting),
          ],
        ),
        const SizedBox(height: 26),
        Text(state.exercise.name, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        Row(
          children: [
            Text('Set ${state.setIndex} of 5', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(width: 12),
            Text(state.statusLabel, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: RepFastColors.green)),
          ],
        ),
        const SizedBox(height: 26),
        NumericStepper(
          label: 'weight',
          valueText: RepFastCalculators.displayWeight(state.weight),
          unit: 'lb',
          onDecrease: onWeightDown,
          onIncrease: onWeightUp,
        ),
        const SizedBox(height: 14),
        NumericStepper(
          label: 'reps',
          valueText: state.reps.toString(),
          onDecrease: onRepsDown,
          onIncrease: onRepsUp,
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          height: 64,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: RepFastColors.cyan,
              foregroundColor: RepFastColors.background,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: isSaving ? null : onLogSet,
            child: Text(isSaving ? 'SAVING' : 'LOG SET', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          ),
        ),
        if (state.saveError != null) ...[
          const SizedBox(height: 12),
          Text(state.saveError!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: RepFastColors.red)),
        ],
        const SizedBox(height: 18),
        ComparisonStrip(result: state.comparison),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Could not load workout.', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
```

- [ ] **Step 5: Update main**

Replace `repfast_app/lib/main.dart`:

```dart
import 'package:flutter/material.dart';

import 'src/application/active_workout_controller.dart';
import 'src/data/sqlite_workout_repository.dart';
import 'src/ui/repfast_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = await SqliteWorkoutRepository.open();
  runApp(RepFastApp(controller: ActiveWorkoutController(repository: repository)));
}
```

- [ ] **Step 6: Verify GREEN**

Run:

```bash
cd repfast_app && flutter test test/ui/active_cockpit_screen_test.dart
```

Expected: PASS.

- [ ] **Step 7: Commit cockpit UI**

```bash
git add repfast_app/lib repfast_app/test/ui
git commit -m "Add active workout cockpit UI"
```

## Task 8: Full Verification and Polish

**Files:**
- Inspect: `repfast_app/lib/**`
- Inspect: `repfast_app/test/**`
- Modify only the exact files reported by `flutter test`, `dart analyze`, or `dart format`.

- [ ] **Step 1: Run full tests**

```bash
cd repfast_app && flutter test
```

Expected: all tests pass.

- [ ] **Step 2: Run analyzer**

```bash
cd repfast_app && dart analyze
```

Expected: no issues.

- [ ] **Step 3: Run formatter**

```bash
cd repfast_app && dart format lib test
```

Expected: formatter completes and either reports changed files or no changes.

- [ ] **Step 4: Run tests again after formatting**

```bash
cd repfast_app && flutter test
```

Expected: all tests pass.

- [ ] **Step 5: Manual launch check**

Run one of:

```bash
cd repfast_app && flutter run -d ios
```

or:

```bash
cd repfast_app && flutter run -d android
```

Expected: app opens to the RepFast active cockpit, shows Bench Press with `225` and `5`, and the `LOG SET` button is visible.

- [ ] **Step 6: Commit final verification fixes**

If formatting or polish changed files:

```bash
git add repfast_app
git commit -m "Polish RepFast MVP"
```

## Task 9: Completion Audit and Push

**Files:**
- Inspect: `repfast_app/lib/**`
- Inspect: `repfast_app/test/**`
- Inspect: `docs/superpowers/specs/2026-05-09-repfast-flutter-mvp-design.md`

- [ ] **Step 1: Build objective checklist**

Confirm evidence for:

- Flutter app exists under `repfast_app/`.
- Offline SQLite persistence exists.
- Active cockpit screen exists.
- Previous-set defaults load.
- `LOG SET` persists a set.
- Rest timer state starts after logging.
- Comparison strip updates after logging.
- Dark gym mode theme exists.
- Domain tests pass.
- Repository tests pass.
- Widget tests pass.
- `dart analyze` passes.

- [ ] **Step 2: Push commits**

```bash
git push origin main
```

Expected: GitHub `main` receives the MVP commits.
