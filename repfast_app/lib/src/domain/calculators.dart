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
