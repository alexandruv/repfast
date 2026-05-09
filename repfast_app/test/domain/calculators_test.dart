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
