import 'package:flutter_test/flutter_test.dart';
import 'package:metal_strength/core/formulas/scoring.dart';
import 'package:metal_strength/core/models/sex.dart';

void main() {
  group('Scoring', () {
    test('all systems give positive, finite scores', () {
      for (final s in ScoreSystem.values) {
        final v = Scoring.score(s, 500, 80, Sex.male);
        expect(v.isFinite, isTrue, reason: s.label);
        expect(v, greaterThan(0), reason: s.label);
      }
    });

    test('a bigger total always scores higher at fixed bodyweight', () {
      for (final s in ScoreSystem.values) {
        final low = Scoring.score(s, 400, 90, Sex.male);
        final high = Scoring.score(s, 600, 90, Sex.male);
        expect(high, greaterThan(low), reason: s.label);
      }
    });

    test('Wilks and DOTS stay in the same ballpark for a mid lifter', () {
      final wilks = Scoring.wilks(500, 90, Sex.male);
      final dots = Scoring.dots(500, 90, Sex.male);
      expect((wilks - dots).abs() / wilks, lessThan(0.20));
    });

    test('interpret() maps scores to levels (refrence §5.4)', () {
      expect(Scoring.interpret(150), 'Beginner');
      expect(Scoring.interpret(250), 'Intermediate');
      expect(Scoring.interpret(350), 'Advanced');
      expect(Scoring.interpret(450), 'Elite');
      expect(Scoring.interpret(550), 'World class');
    });

    test('female coefficients differ from male', () {
      final male = Scoring.dots(400, 70, Sex.male);
      final female = Scoring.dots(400, 70, Sex.female);
      expect(female, isNot(closeTo(male, 0.01)));
    });
  });
}
