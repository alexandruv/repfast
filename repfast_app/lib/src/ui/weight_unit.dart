import '../domain/models.dart';
import '../domain/calculators.dart';

enum WeightUnit {
  pounds(label: 'lb'),
  kilograms(label: 'kg');

  const WeightUnit({required this.label});

  static const double _poundsPerKilogram = 2.2046226218;

  final String label;

  double displayValue(double pounds) {
    return switch (this) {
      WeightUnit.pounds => pounds,
      WeightUnit.kilograms => pounds / _poundsPerKilogram,
    };
  }

  double stepInPounds(Exercise exercise) {
    return switch (this) {
      WeightUnit.pounds => exercise.weightIncrement,
      WeightUnit.kilograms => 2.5 * _poundsPerKilogram,
    };
  }

  String displayWeight(double pounds) {
    return RepFastCalculators.displayWeight(displayValue(pounds));
  }
}
