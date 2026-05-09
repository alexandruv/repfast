import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../domain/models.dart';
import 'workout_repository.dart';

class SqliteWorkoutRepository implements WorkoutRepository {
  const SqliteWorkoutRepository._(this._database);

  final sqflite.Database _database;

  static Future<SqliteWorkoutRepository> open() async {
    final databasesPath = await sqflite.getDatabasesPath();
    final database = await sqflite.openDatabase(
      p.join(databasesPath, 'repfast.db'),
      version: 1,
      onCreate: _createSchema,
    );
    return SqliteWorkoutRepository._(database);
  }

  static Future<SqliteWorkoutRepository> inMemory() async {
    sqfliteFfiInit();
    final database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: sqflite.OpenDatabaseOptions(version: 1, onCreate: _createSchema),
    );
    return SqliteWorkoutRepository._(database);
  }

  static Future<void> _createSchema(sqflite.Database db, int version) async {
    await db.execute('''
      CREATE TABLE exercises (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        weight_increment REAL NOT NULL,
        rep_increment INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE sessions (
        id TEXT PRIMARY KEY,
        started_at TEXT NOT NULL,
        completed_at TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE sets (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        exercise_id TEXT NOT NULL,
        set_index INTEGER NOT NULL,
        weight REAL NOT NULL,
        reps INTEGER NOT NULL,
        completed_at TEXT NOT NULL,
        FOREIGN KEY (session_id) REFERENCES sessions (id),
        FOREIGN KEY (exercise_id) REFERENCES exercises (id)
      )
    ''');
  }

  @override
  Future<void> seedIfEmpty() async {
    final existing = sqflite.Sqflite.firstIntValue(
      await _database.rawQuery('SELECT COUNT(*) FROM exercises'),
    );
    if ((existing ?? 0) > 0) {
      return;
    }

    await _database.transaction((txn) async {
      await txn.insert('exercises', const {
        'id': 'bench-press',
        'name': 'Bench Press',
        'weight_increment': 5.0,
        'rep_increment': 1,
      });
      await txn.insert('sessions', {
        'id': 'previous-session',
        'started_at': DateTime(2026, 5, 2, 12).toIso8601String(),
        'completed_at': DateTime(2026, 5, 2, 13).toIso8601String(),
      });
      await txn.insert('sessions', {
        'id': 'current-session',
        'started_at': DateTime(2026, 5, 9, 12).toIso8601String(),
        'completed_at': null,
      });
      await txn.insert('sets', {
        'id': 'previous-session-bench-press-1',
        'session_id': 'previous-session',
        'exercise_id': 'bench-press',
        'set_index': 1,
        'weight': 185.0,
        'reps': 8,
        'completed_at': DateTime(2026, 5, 2, 12, 10).toIso8601String(),
      });
      await txn.insert('sets', {
        'id': 'previous-session-bench-press-2',
        'session_id': 'previous-session',
        'exercise_id': 'bench-press',
        'set_index': 2,
        'weight': 205.0,
        'reps': 6,
        'completed_at': DateTime(2026, 5, 2, 12, 16).toIso8601String(),
      });
      await txn.insert('sets', {
        'id': 'previous-session-bench-press-3',
        'session_id': 'previous-session',
        'exercise_id': 'bench-press',
        'set_index': 3,
        'weight': 225.0,
        'reps': 5,
        'completed_at': DateTime(2026, 5, 2, 12, 22).toIso8601String(),
      });
    });
  }

  @override
  Future<Exercise> activeExercise() async {
    final rows = await _database.query(
      'exercises',
      orderBy: 'id ASC',
      limit: 1,
    );
    return _exerciseFromRow(_singleRow(rows, 'active exercise'));
  }

  @override
  Future<WorkoutSession> activeSession() async {
    final rows = await _database.query(
      'sessions',
      where: 'completed_at IS NULL',
      orderBy: 'started_at DESC',
      limit: 1,
    );
    return _sessionFromRow(_singleRow(rows, 'active session'));
  }

  @override
  Future<List<WorkoutSet>> previousSetsForExercise(String exerciseId) async {
    final active = await activeSession();
    final rows = await _database.query(
      'sets',
      where: 'exercise_id = ? AND session_id <> ?',
      whereArgs: [exerciseId, active.id],
      orderBy: 'completed_at ASC, set_index ASC',
    );
    return rows.map(_setFromRow).toList();
  }

  @override
  Future<List<WorkoutSet>> currentSetsForExercise(String exerciseId) async {
    final active = await activeSession();
    final rows = await _database.query(
      'sets',
      where: 'exercise_id = ? AND session_id = ?',
      whereArgs: [exerciseId, active.id],
      orderBy: 'set_index ASC',
    );
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
    await _database.insert('sets', _setToRow(set));
    return set;
  }

  static Map<String, Object?> _setToRow(WorkoutSet set) {
    return {
      'id': set.id,
      'session_id': set.sessionId,
      'exercise_id': set.exerciseId,
      'set_index': set.setIndex,
      'weight': set.weight,
      'reps': set.reps,
      'completed_at': set.completedAt.toIso8601String(),
    };
  }

  static Exercise _exerciseFromRow(Map<String, Object?> row) {
    return Exercise(
      id: row['id']! as String,
      name: row['name']! as String,
      weightIncrement: row['weight_increment']! as double,
      repIncrement: row['rep_increment']! as int,
    );
  }

  static WorkoutSession _sessionFromRow(Map<String, Object?> row) {
    final completedAt = row['completed_at'] as String?;
    return WorkoutSession(
      id: row['id']! as String,
      startedAt: DateTime.parse(row['started_at']! as String),
      completedAt: completedAt == null ? null : DateTime.parse(completedAt),
    );
  }

  static WorkoutSet _setFromRow(Map<String, Object?> row) {
    return WorkoutSet(
      id: row['id']! as String,
      sessionId: row['session_id']! as String,
      exerciseId: row['exercise_id']! as String,
      setIndex: row['set_index']! as int,
      weight: row['weight']! as double,
      reps: row['reps']! as int,
      completedAt: DateTime.parse(row['completed_at']! as String),
    );
  }

  static Map<String, Object?> _singleRow(
    List<Map<String, Object?>> rows,
    String label,
  ) {
    if (rows.isEmpty) {
      throw StateError('No $label found');
    }
    return rows.single;
  }
}
