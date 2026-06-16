import 'dart:math' as math;

/// One-rep-max (1RM) estimation formulas.
///
/// Every equation here is public-domain mathematics (see `refrence` Section 2).
/// `w` = weight lifted, `r` = reps performed. If `r == 1` the lift *is* the 1RM
/// and estimation is skipped.
enum OneRepMaxFormula {
  epley('Epley', 'Most common; good general use'),
  brzycki('Brzycki', 'Accurate for low reps (<10)'),
  lander('Lander', 'Linear, validated'),
  lombardi('Lombardi', 'Power-curve based'),
  mayhew('Mayhew et al.', 'Research-validated'),
  oconner("O'Conner et al.", 'Simple linear'),
  wathan('Wathan', 'Exponential decay'),
  average('Average', 'Mean of all formulas above');

  const OneRepMaxFormula(this.label, this.description);

  final String label;
  final String description;
}

/// Accuracy of all 1RM formulas degrades above this rep count — warn the user.
const int kReliableRepCeiling = 12;

class OneRepMax {
  const OneRepMax._();

  /// Estimate 1RM from a working set of [weight] for [reps] using [formula].
  ///
  /// Returns [weight] unchanged when [reps] <= 1. Throws [ArgumentError] for
  /// non-positive input.
  static double estimate({
    required double weight,
    required int reps,
    OneRepMaxFormula formula = OneRepMaxFormula.epley,
  }) {
    if (weight <= 0) {
      throw ArgumentError.value(weight, 'weight', 'must be > 0');
    }
    if (reps <= 0) {
      throw ArgumentError.value(reps, 'reps', 'must be >= 1');
    }
    if (reps == 1) return weight;

    final r = reps.toDouble();
    switch (formula) {
      case OneRepMaxFormula.epley:
        return weight * (1 + r / 30);
      case OneRepMaxFormula.brzycki:
        // Diverges as r -> 37; guard the asymptote.
        if (reps >= 37) return _averageOf(weight, reps);
        return weight * 36 / (37 - r);
      case OneRepMaxFormula.lander:
        return (100 * weight) / (101.3 - 2.67123 * r);
      case OneRepMaxFormula.lombardi:
        return weight * math.pow(r, 0.10).toDouble();
      case OneRepMaxFormula.mayhew:
        return (100 * weight) / (52.2 + 41.9 * math.exp(-0.055 * r));
      case OneRepMaxFormula.oconner:
        return weight * (1 + 0.025 * r);
      case OneRepMaxFormula.wathan:
        return (100 * weight) / (48.8 + 53.8 * math.exp(-0.075 * r));
      case OneRepMaxFormula.average:
        return _averageOf(weight, reps);
    }
  }

  /// Mean 1RM across every concrete formula (excludes [OneRepMaxFormula.average]).
  static double _averageOf(double weight, int reps) {
    final formulas = OneRepMaxFormula.values
        .where((f) => f != OneRepMaxFormula.average)
        // Brzycki is undefined near its asymptote; drop it from the mean there.
        .where((f) => !(f == OneRepMaxFormula.brzycki && reps >= 37));
    final values =
        formulas.map((f) => estimate(weight: weight, reps: reps, formula: f));
    return values.reduce((a, b) => a + b) / values.length;
  }

  /// True when [reps] is high enough that the estimate should be flagged.
  static bool isLowConfidence(int reps) => reps > kReliableRepCeiling;
}
