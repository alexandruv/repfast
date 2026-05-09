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
