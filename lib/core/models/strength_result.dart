import '../formulas/one_rep_max.dart';
import '../formulas/tiers.dart';

/// The full outcome of a strength assessment for one exercise.
class StrengthResult {
  const StrengthResult({
    required this.exerciseName,
    required this.oneRmKg,
    required this.tier,
    required this.percentile,
    required this.bodyweightRatio,
    required this.formula,
    required this.lowConfidence,
    required this.isEstimate,
    this.repCount,
    this.nextTier,
    this.toNextTierKg,
    this.estimateNote,
  });

  final String exerciseName;

  /// Estimated one-rep max in kilograms. For rep-count (bodyweight) exercises
  /// this is null and [repCount] is set instead.
  final double? oneRmKg;

  /// For bodyweight exercises: the reps performed that were classified.
  final int? repCount;

  final StrengthTier tier;

  /// Population percentile (0..100) — "stronger than N% of lifters".
  final double percentile;

  /// lift ÷ bodyweight (null for bodyweight/rep-count exercises).
  final double? bodyweightRatio;

  final OneRepMaxFormula formula;

  /// True when reps were high enough to make the 1RM estimate unreliable.
  final bool lowConfidence;

  /// True when standards are derived from a related lift rather than a dataset.
  final bool isEstimate;
  final String? estimateNote;

  /// The tier immediately above [tier], if any.
  final StrengthTier? nextTier;

  /// Extra kilograms on the 1RM needed to reach [nextTier].
  final double? toNextTierKg;
}
