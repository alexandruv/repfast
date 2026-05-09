import 'package:repfast_app/src/domain/calculators.dart';

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

  double get volume => RepFastCalculators.volume(weight: weight, reps: reps);
}
