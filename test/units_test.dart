import 'package:flutter_test/flutter_test.dart';
import 'package:metal_strength/core/formulas/rep_percent_table.dart';
import 'package:metal_strength/core/formulas/units.dart';

void main() {
  group('Units', () {
    test('100kg is about 220.46lb', () {
      expect(Units.kgToLb(100), closeTo(220.462, 0.01));
    });

    test('kg <-> lb round trips', () {
      expect(Units.lbToKg(Units.kgToLb(82.5)), closeTo(82.5, 1e-9));
    });

    test('toKg/fromKg respect the unit', () {
      expect(Units.toKg(100, WeightUnit.kg), 100);
      expect(Units.toKg(220.462, WeightUnit.lb), closeTo(100, 0.01));
      expect(Units.fromKg(100, WeightUnit.lb), closeTo(220.462, 0.01));
    });

    test('prettyRound snaps to plate increments', () {
      expect(Units.prettyRound(101.3, WeightUnit.kg), 101.5);
      expect(Units.prettyRound(220.6, WeightUnit.lb), 221);
    });
  });

  group('RepPercentTable', () {
    test('matches the reference table (refrence §2)', () {
      expect(RepPercentTable.fractionForReps(1), 1.0);
      expect(RepPercentTable.fractionForReps(10), 0.75);
      expect(RepPercentTable.fractionForReps(20), 0.60);
    });

    test('clamps out-of-range reps', () {
      expect(RepPercentTable.fractionForReps(0), 1.0);
      expect(RepPercentTable.fractionForReps(99), 0.50);
    });

    test('predicts load for a rep target', () {
      expect(RepPercentTable.loadForReps(100, 10), closeTo(75, 0.001));
    });
  });
}
