import 'package:flutter_test/flutter_test.dart';
import 'package:metal_strength/core/formulas/tiers.dart';

void main() {
  // Male bench anchors from refrence §4.
  const bench = RatioAnchors(
    beginner: 0.50,
    novice: 0.75,
    intermediate: 1.25,
    advanced: 1.75,
    elite: 2.00,
  );

  group('Tiers.fromRatio', () {
    test('worked example: 1.46x bench -> Intermediate (refrence §10)', () {
      expect(Tiers.fromRatio(1.46, bench), StrengthTier.intermediate);
    });

    test('boundary values land in the expected tier', () {
      expect(Tiers.fromRatio(0.40, bench), StrengthTier.beginner);
      expect(Tiers.fromRatio(0.75, bench), StrengthTier.novice);
      expect(Tiers.fromRatio(1.25, bench), StrengthTier.intermediate);
      expect(Tiers.fromRatio(1.75, bench), StrengthTier.advanced);
      expect(Tiers.fromRatio(2.10, bench), StrengthTier.elite);
    });
  });

  group('Tiers.fromPercentile', () {
    test('maps percentiles to the right tier', () {
      expect(Tiers.fromPercentile(3), StrengthTier.beginner);
      expect(Tiers.fromPercentile(20), StrengthTier.novice);
      expect(Tiers.fromPercentile(55), StrengthTier.intermediate);
      expect(Tiers.fromPercentile(85), StrengthTier.advanced);
      expect(Tiers.fromPercentile(96), StrengthTier.elite);
    });
  });

  group('Tiers.percentileFromRatio', () {
    test('anchor ratios produce their nominal percentiles', () {
      expect(Tiers.percentileFromRatio(1.25, bench), closeTo(50, 0.001));
      expect(Tiers.percentileFromRatio(1.75, bench), closeTo(80, 0.001));
    });

    test('increases monotonically with ratio', () {
      double last = -1;
      for (var r = 0.0; r <= 2.5; r += 0.1) {
        final p = Tiers.percentileFromRatio(r, bench);
        expect(p, greaterThanOrEqualTo(last));
        last = p;
      }
    });
  });

  test('female anchors derive from male via scaled()', () {
    final female = bench.scaled(0.7);
    expect(female.intermediate, closeTo(1.25 * 0.7, 0.0001));
  });
}
