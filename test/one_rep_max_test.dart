import 'package:flutter_test/flutter_test.dart';
import 'package:metal_strength/core/formulas/one_rep_max.dart';

void main() {
  group('OneRepMax.estimate', () {
    test('worked example: Epley 100kg x 5 = 116.67kg (refrence §10)', () {
      final oneRm = OneRepMax.estimate(
        weight: 100,
        reps: 5,
        formula: OneRepMaxFormula.epley,
      );
      expect(oneRm, closeTo(116.667, 0.01));
    });

    test('a single rep returns the weight unchanged for every formula', () {
      for (final f in OneRepMaxFormula.values) {
        expect(
          OneRepMax.estimate(weight: 140, reps: 1, formula: f),
          140,
          reason: f.label,
        );
      }
    });

    test("O'Conner 100kg x 5 = 112.5kg", () {
      expect(
        OneRepMax.estimate(
            weight: 100, reps: 5, formula: OneRepMaxFormula.oconner),
        closeTo(112.5, 0.001),
      );
    });

    test('Brzycki 100kg x 5 = 112.5kg', () {
      expect(
        OneRepMax.estimate(
            weight: 100, reps: 5, formula: OneRepMaxFormula.brzycki),
        closeTo(112.5, 0.001),
      );
    });

    test('average sits between the lowest and highest single formula', () {
      final values = OneRepMaxFormula.values
          .where((f) => f != OneRepMaxFormula.average)
          .map((f) => OneRepMax.estimate(weight: 100, reps: 5, formula: f))
          .toList();
      final avg = OneRepMax.estimate(
          weight: 100, reps: 5, formula: OneRepMaxFormula.average);
      expect(avg, greaterThanOrEqualTo(values.reduce((a, b) => a < b ? a : b)));
      expect(avg, lessThanOrEqualTo(values.reduce((a, b) => a > b ? a : b)));
    });

    test('rejects non-positive input', () {
      expect(() => OneRepMax.estimate(weight: 0, reps: 5), throwsArgumentError);
      expect(() => OneRepMax.estimate(weight: 100, reps: 0), throwsArgumentError);
    });

    test('flags high-rep estimates as low confidence', () {
      expect(OneRepMax.isLowConfidence(10), isFalse);
      expect(OneRepMax.isLowConfidence(15), isTrue);
    });
  });
}
