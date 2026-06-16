import 'dart:math' as math;

import '../models/sex.dart';

/// Bodyweight-adjusted powerlifting scores (`refrence` Section 5).
///
/// All inputs are in **kilograms**. `total` = squat + bench + deadlift (kg),
/// `bodyweight` = lifter bodyweight (kg). Every coefficient set is a published,
/// public-domain formula.
enum ScoreSystem {
  wilks('Wilks', 'Original 1994 / 2004 coefficients'),
  wilks2('Wilks-2', '2020 revision'),
  dots('DOTS', '2019, most bodyweight-neutral'),
  ipfGl('IPF GL', 'IPF GoodLift points (raw)');

  const ScoreSystem(this.label, this.description);
  final String label;
  final String description;
}

class Scoring {
  const Scoring._();

  /// 5th-order polynomial coefficients (constant term first) for Wilks.
  static const List<double> _wilksMale = [
    -216.0475144,
    16.2606339,
    -0.002388645,
    -0.00113732,
    7.01863e-6,
    -1.291e-8,
  ];
  static const List<double> _wilksFemale = [
    594.31747775582,
    -27.23842536447,
    0.82112226871,
    -0.00930733913,
    4.731582e-5,
    -9.054e-8,
  ];

  static const List<double> _wilks2Male = [
    47.46178854,
    8.472061379,
    0.07369410346,
    -0.001395833811,
    7.07665973070743e-6,
    -1.20804336482315e-8,
  ];
  static const List<double> _wilks2Female = [
    -125.4255398,
    13.71219419,
    -0.03307250631,
    -0.001050400051,
    9.38773881462799e-6,
    -2.3334613884954e-8,
  ];

  /// 4th-order polynomial coefficients (constant term first) for DOTS.
  static const List<double> _dotsMale = [
    -307.75076,
    24.0900756,
    -0.1918759221,
    0.0007391293,
    -0.000001093,
  ];
  static const List<double> _dotsFemale = [
    -57.96288,
    13.6175032,
    -0.1126655495,
    0.0005158568,
    -0.0000010706,
  ];

  /// Evaluate a polynomial whose [coeffs] are ordered constant-term-first.
  static double _poly(List<double> coeffs, double x) {
    var sum = 0.0;
    var power = 1.0;
    for (final c in coeffs) {
      sum += c * power;
      power *= x;
    }
    return sum;
  }

  static double wilks(double total, double bodyweight, Sex sex) {
    final coeffs = sex.isMale ? _wilksMale : _wilksFemale;
    return total * (500 / _poly(coeffs, bodyweight));
  }

  static double wilks2(double total, double bodyweight, Sex sex) {
    final coeffs = sex.isMale ? _wilks2Male : _wilks2Female;
    return total * (500 / _poly(coeffs, bodyweight));
  }

  static double dots(double total, double bodyweight, Sex sex) {
    final coeffs = sex.isMale ? _dotsMale : _dotsFemale;
    return total * (500 / _poly(coeffs, bodyweight));
  }

  /// IPF GoodLift points (raw/classic). Public 2020 coefficients:
  /// `GL = total * 100 / (A - B * e^(-C * bodyweight))`.
  static double ipfGl(double total, double bodyweight, Sex sex) {
    final (a, b, c) = sex.isMale
        ? (1199.72839, 1025.18162, 0.00921)
        : (610.32796, 1045.59282, 0.03048);
    return total * 100 / (a - b * math.exp(-c * bodyweight));
  }

  static double score(
    ScoreSystem system,
    double total,
    double bodyweight,
    Sex sex,
  ) {
    switch (system) {
      case ScoreSystem.wilks:
        return wilks(total, bodyweight, sex);
      case ScoreSystem.wilks2:
        return wilks2(total, bodyweight, sex);
      case ScoreSystem.dots:
        return dots(total, bodyweight, sex);
      case ScoreSystem.ipfGl:
        return ipfGl(total, bodyweight, sex);
    }
  }

  /// Rough level label for a Wilks/DOTS score (`refrence` Section 5.4).
  static String interpret(double score) {
    if (score < 200) return 'Beginner';
    if (score < 300) return 'Intermediate';
    if (score < 400) return 'Advanced';
    if (score < 500) return 'Elite';
    return 'World class';
  }
}
