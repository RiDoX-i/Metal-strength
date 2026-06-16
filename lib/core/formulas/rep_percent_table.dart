/// Standard "reps -> % of 1RM" reference table (`refrence` Section 2).
///
/// Used to predict the load you could move for a target rep count once a 1RM
/// is known, and vice-versa.
class RepPercentTable {
  const RepPercentTable._();

  /// reps (1..30) -> percentage of 1RM (0..100).
  static const Map<int, int> _percentOfOneRm = {
    1: 100, 2: 97, 3: 94, 4: 92, 5: 89, 6: 86, 7: 83, 8: 81, 9: 78, 10: 75,
    11: 73, 12: 71, 13: 70, 14: 68, 15: 67, 16: 65, 17: 64, 18: 63, 19: 61,
    20: 60, 21: 59, 22: 58, 23: 57, 24: 56, 25: 55, 26: 54, 27: 53, 28: 52,
    29: 51, 30: 50,
  };

  /// Fraction (0..1) of 1RM expected for [reps]. Clamps to the 1..30 range.
  static double fractionForReps(int reps) {
    final clamped = reps.clamp(1, 30);
    return _percentOfOneRm[clamped]! / 100.0;
  }

  /// Predicted load for [reps] given a known [oneRm].
  static double loadForReps(double oneRm, int reps) =>
      oneRm * fractionForReps(reps);
}
