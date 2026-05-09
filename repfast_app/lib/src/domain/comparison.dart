import 'calculators.dart';
import 'models.dart';

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
    final currentBestOrm = bestCurrentSet == null
        ? 0
        : RepFastCalculators.estimatedOneRepMax(
            weight: bestCurrentSet.weight,
            reps: bestCurrentSet.reps,
          );
    final previousBestOrm = bestPreviousSet == null
        ? 0
        : RepFastCalculators.estimatedOneRepMax(
            weight: bestPreviousSet.weight,
            reps: bestPreviousSet.reps,
          );
    final delta = previousVolume == 0
        ? 0.0
        : ((currentVolume - previousVolume) / previousVolume) * 100;

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
      final bestOrm = RepFastCalculators.estimatedOneRepMax(
        weight: best.weight,
        reps: best.reps,
      );
      final nextOrm = RepFastCalculators.estimatedOneRepMax(
        weight: next.weight,
        reps: next.reps,
      );
      return nextOrm > bestOrm ? next : best;
    });
  }

  static String _takeaway(
    WorkoutSet? current,
    WorkoutSet? previous,
    double previousVolume,
  ) {
    if (current == null) return 'Log your first set to compare this lift.';
    if (previous == null || previousVolume == 0) {
      return 'First logged set for this lift.';
    }
    if (current.weight == previous.weight && current.reps > previous.reps) {
      return 'You added one rep at the same weight.';
    }
    if (current.weight > previous.weight) {
      return 'You moved more weight than last time.';
    }
    if (current.weight == previous.weight && current.reps == previous.reps) {
      return 'You matched last time.';
    }
    return 'Keep the next set controlled and compare again.';
  }
}
