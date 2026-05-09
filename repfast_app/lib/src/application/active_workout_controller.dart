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
    required this.isSaving,
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
  final bool isSaving;
  final String statusLabel;
  final WorkoutComparisonResult comparison;
  final String? saveError;

  ActiveWorkoutState copyWith({
    double? weight,
    int? reps,
    int? setIndex,
    bool? isResting,
    bool? isSaving,
    String? statusLabel,
    WorkoutComparisonResult? comparison,
    String? saveError,
    bool clearSaveError = false,
  }) {
    return ActiveWorkoutState(
      exercise: exercise,
      session: session,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      setIndex: setIndex ?? this.setIndex,
      isResting: isResting ?? this.isResting,
      isSaving: isSaving ?? this.isSaving,
      statusLabel: statusLabel ?? this.statusLabel,
      comparison: comparison ?? this.comparison,
      saveError: clearSaveError ? null : saveError ?? this.saveError,
    );
  }
}

class ActiveWorkoutController {
  ActiveWorkoutController({required WorkoutRepository repository})
    : _repository = repository;

  static const double _fallbackWeight = 45;
  static const int _fallbackReps = 5;

  final WorkoutRepository _repository;
  ActiveWorkoutState? _state;

  ActiveWorkoutState get state {
    final current = _state;
    if (current == null) {
      throw StateError('Active workout has not been loaded.');
    }
    return current;
  }

  Future<ActiveWorkoutState> load() async {
    await _repository.seedIfEmpty();
    final exercise = await _repository.activeExercise();
    final session = await _repository.activeSession();
    final previousSets = await _repository.previousSetsForExercise(exercise.id);
    final currentSets = await _repository.currentSetsForExercise(exercise.id);
    final previousDefault = previousSets.isEmpty ? null : previousSets.last;

    _state = ActiveWorkoutState(
      exercise: exercise,
      session: session,
      weight: previousDefault?.weight ?? _fallbackWeight,
      reps: previousDefault?.reps ?? _fallbackReps,
      setIndex: currentSets.length + 1,
      isResting: false,
      isSaving: false,
      statusLabel: 'Saved on device',
      comparison: _compareAgainstPreviousDefault(
        currentSets: currentSets,
        previousSets: previousSets,
      ),
    );
    return state;
  }

  ActiveWorkoutState updateWeight(double weight) {
    if (state.isSaving) {
      return state;
    }
    _state = state.copyWith(
      weight: weight < 0 ? 0 : weight,
      clearSaveError: true,
    );
    return state;
  }

  ActiveWorkoutState updateReps(int reps) {
    if (state.isSaving) {
      return state;
    }
    _state = state.copyWith(reps: reps < 1 ? 1 : reps, clearSaveError: true);
    return state;
  }

  Future<ActiveWorkoutState> logSet({DateTime? now}) async {
    final current = state;
    if (current.isSaving) {
      return current;
    }

    _state = current.copyWith(isSaving: true, clearSaveError: true);
    final saving = state;
    try {
      await _repository.logSet(
        sessionId: saving.session.id,
        exerciseId: saving.exercise.id,
        setIndex: saving.setIndex,
        weight: saving.weight,
        reps: saving.reps,
        completedAt: now ?? DateTime.now(),
      );
    } catch (_) {
      _state = saving.copyWith(
        isResting: false,
        isSaving: false,
        saveError: 'Set not saved. Retry.',
      );
      return state;
    }

    try {
      final previousSets = await _repository.previousSetsForExercise(
        saving.exercise.id,
      );
      final currentSets = await _repository.currentSetsForExercise(
        saving.exercise.id,
      );

      _state = saving.copyWith(
        setIndex: currentSets.length + 1,
        isResting: true,
        isSaving: false,
        comparison: _compareAgainstPreviousDefault(
          currentSets: currentSets,
          previousSets: previousSets,
        ),
        clearSaveError: true,
      );
      return state;
    } catch (_) {
      _state = saving.copyWith(
        isSaving: false,
        saveError: 'Set saved. Refresh workout.',
      );
      return state;
    }
  }

  WorkoutComparisonResult _compareAgainstPreviousDefault({
    required List<WorkoutSet> currentSets,
    required List<WorkoutSet> previousSets,
  }) {
    return WorkoutComparison.compare(
      currentSets: currentSets,
      previousSets: previousSets.isEmpty ? const [] : [previousSets.last],
    );
  }
}
