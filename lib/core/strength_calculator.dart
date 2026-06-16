import 'formulas/age_adjust.dart';
import 'formulas/one_rep_max.dart';
import 'formulas/tiers.dart';
import 'models/exercise.dart';
import 'models/strength_result.dart';
import 'models/user_profile.dart';

/// Orchestrates the core pipeline from `refrence` Section 1:
///
/// ```
/// lift + reps -> 1RM -> bodyweight ratio -> tier lookup -> level + percentile
/// ```
class StrengthCalculator {
  const StrengthCalculator();

  /// Assess a weighted (external-load) exercise.
  ///
  /// [weightKg] and the user's bodyweight are in kilograms.
  StrengthResult assessWeighted({
    required Exercise exercise,
    required UserProfile profile,
    required double weightKg,
    required int reps,
    OneRepMaxFormula formula = OneRepMaxFormula.epley,
  }) {
    final rawOneRm =
        OneRepMax.estimate(weight: weightKg, reps: reps, formula: formula);

    // Age-normalise the 1RM before comparing against standards.
    final ageFactor =
        exercise.ageAdjust ? AgeAdjust.factor(profile.age) : 1.0;
    final adjustedOneRm = rawOneRm * ageFactor;

    final ratio = adjustedOneRm / profile.bodyweightKg;
    final anchors = exercise.anchorsFor(profile.sex);

    final tier = Tiers.fromRatio(ratio, anchors);
    final percentile = Tiers.percentileFromRatio(ratio, anchors);

    // How much more 1RM (raw kg) to reach the next tier?
    final next = tier.next;
    double? toNext;
    if (next != null) {
      final targetOneRm = anchors.anchorFor(next) * profile.bodyweightKg;
      // Express the gap in raw (un-adjusted) kilograms the user must add.
      final gap = (targetOneRm / ageFactor) - rawOneRm;
      toNext = gap > 0 ? gap : 0;
    }

    return StrengthResult(
      exerciseName: exercise.name,
      oneRmKg: rawOneRm,
      tier: tier,
      percentile: percentile,
      bodyweightRatio: ratio,
      formula: formula,
      lowConfidence: OneRepMax.isLowConfidence(reps),
      isEstimate: !exercise.usesDataset || exercise.estimateNote != null,
      estimateNote: exercise.estimateNote,
      nextTier: next,
      toNextTierKg: toNext,
    );
  }

  /// Assess a bodyweight, rep-count exercise (pull ups, push ups, …).
  ///
  /// Classified by reps performed against [repAnchors] (reps per tier).
  StrengthResult assessRepBased({
    required Exercise exercise,
    required int reps,
    required Map<StrengthTier, int> repAnchors,
  }) {
    StrengthTier tier = StrengthTier.beginner;
    for (final t in StrengthTier.ordered) {
      if (reps >= (repAnchors[t] ?? 1 << 30)) tier = t;
    }

    // Interpolate a percentile from the rep anchors.
    final percentile = _percentileFromReps(reps, repAnchors);
    final next = tier.next;
    final toNextReps =
        next != null ? ((repAnchors[next] ?? reps) - reps).toDouble() : null;

    return StrengthResult(
      exerciseName: exercise.name,
      oneRmKg: null,
      repCount: reps,
      tier: tier,
      percentile: percentile,
      bodyweightRatio: null,
      formula: OneRepMaxFormula.epley,
      lowConfidence: false,
      isEstimate: true,
      estimateNote: exercise.estimateNote,
      nextTier: next,
      toNextTierKg: toNextReps, // reused as "reps to next" for bodyweight
    );
  }

  double _percentileFromReps(int reps, Map<StrengthTier, int> anchors) {
    final points = <(double, double)>[
      (0, 0),
      ((anchors[StrengthTier.beginner] ?? 1).toDouble(), 5),
      ((anchors[StrengthTier.novice] ?? 2).toDouble(), 20),
      ((anchors[StrengthTier.intermediate] ?? 3).toDouble(), 50),
      ((anchors[StrengthTier.advanced] ?? 4).toDouble(), 80),
      ((anchors[StrengthTier.elite] ?? 5).toDouble(), 95),
    ];
    final r = reps.toDouble();
    if (r <= points.first.$1) return 0;
    if (r >= points.last.$1) return 95 + (r - points.last.$1).clamp(0, 4.9);
    for (var i = 0; i < points.length - 1; i++) {
      final (x0, y0) = points[i];
      final (x1, y1) = points[i + 1];
      if (r >= x0 && r <= x1 && x1 > x0) {
        return y0 + ((r - x0) / (x1 - x0)) * (y1 - y0);
      }
    }
    return 50;
  }
}
