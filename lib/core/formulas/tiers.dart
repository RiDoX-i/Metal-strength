import '../models/sex.dart';

/// Strength classification tiers (`refrence` Section 3) and the two ways of
/// assigning one: by population **percentile** (dataset-backed) or by
/// **bodyweight ratio** (fast, dataset-free fallback, Section 4).
enum StrengthTier {
  beginner('Beginner', 5, 0xFF8A94A6),
  novice('Novice', 20, 0xFF4FB477),
  intermediate('Intermediate', 50, 0xFF3D9BE9),
  advanced('Advanced', 80, 0xFF9B6DFF),
  elite('Elite', 95, 0xFFFF9F43);

  const StrengthTier(this.label, this.minPercentile, this.colorValue);

  /// Inclusive lower percentile bound for this tier.
  final int minPercentile;
  final String label;

  /// Brand accent (ARGB) used by the UI for this tier.
  final int colorValue;

  /// Tiers ordered weakest -> strongest.
  static List<StrengthTier> get ordered => [
        beginner,
        novice,
        intermediate,
        advanced,
        elite,
      ];

  StrengthTier? get next {
    final i = ordered.indexOf(this);
    return i < ordered.length - 1 ? ordered[i + 1] : null;
  }
}

/// Per-exercise ratio anchors (lift ÷ bodyweight) for a single sex.
class RatioAnchors {
  const RatioAnchors({
    required this.beginner,
    required this.novice,
    required this.intermediate,
    required this.advanced,
    required this.elite,
  });

  final double beginner;
  final double novice;
  final double intermediate;
  final double advanced;
  final double elite;

  factory RatioAnchors.fromJson(Map<String, dynamic> json) => RatioAnchors(
        beginner: (json['beginner'] as num).toDouble(),
        novice: (json['novice'] as num).toDouble(),
        intermediate: (json['intermediate'] as num).toDouble(),
        advanced: (json['advanced'] as num).toDouble(),
        elite: (json['elite'] as num).toDouble(),
      );

  double anchorFor(StrengthTier tier) => switch (tier) {
        StrengthTier.beginner => beginner,
        StrengthTier.novice => novice,
        StrengthTier.intermediate => intermediate,
        StrengthTier.advanced => advanced,
        StrengthTier.elite => elite,
      };

  /// Uniformly scale every anchor by [factor] — used to derive female anchors
  /// from male ones for accessory lifts that lack their own table.
  RatioAnchors scaled(double factor) => RatioAnchors(
        beginner: beginner * factor,
        novice: novice * factor,
        intermediate: intermediate * factor,
        advanced: advanced * factor,
        elite: elite * factor,
      );
}

class Tiers {
  const Tiers._();

  /// Map a population [percentile] (0..100) to the tier it falls into.
  static StrengthTier fromPercentile(double percentile) {
    StrengthTier result = StrengthTier.beginner;
    for (final tier in StrengthTier.ordered) {
      if (percentile >= tier.minPercentile) result = tier;
    }
    return result;
  }

  /// Classify by lift-to-bodyweight [ratio] against [anchors].
  static StrengthTier fromRatio(double ratio, RatioAnchors anchors) {
    if (ratio >= anchors.elite) return StrengthTier.elite;
    if (ratio >= anchors.advanced) return StrengthTier.advanced;
    if (ratio >= anchors.intermediate) return StrengthTier.intermediate;
    if (ratio >= anchors.novice) return StrengthTier.novice;
    return StrengthTier.beginner;
  }

  /// Estimate a 0..100 percentile by linearly interpolating between the ratio
  /// anchors, so the UI can show a smooth "stronger than X%" figure.
  static double percentileFromRatio(double ratio, RatioAnchors anchors) {
    // (anchor ratio, percentile) control points.
    final points = <(double, double)>[
      (0, 0),
      (anchors.beginner, 5),
      (anchors.novice, 20),
      (anchors.intermediate, 50),
      (anchors.advanced, 80),
      (anchors.elite, 95),
    ];
    if (ratio <= points.first.$1) return 0;
    if (ratio >= anchors.elite) {
      // Extrapolate gently above Elite, capped at 99.9.
      final span = anchors.elite - anchors.advanced;
      if (span <= 0) return 95;
      final extra = ((ratio - anchors.elite) / span) * 5;
      return (95 + extra).clamp(0, 99.9);
    }
    for (var i = 0; i < points.length - 1; i++) {
      final (r0, p0) = points[i];
      final (r1, p1) = points[i + 1];
      if (ratio >= r0 && ratio <= r1 && r1 > r0) {
        final t = (ratio - r0) / (r1 - r0);
        return p0 + t * (p1 - p0);
      }
    }
    return 50;
  }
}

/// Convenience: default anchors used when an exercise carries none of its own.
RatioAnchors fallbackAnchorsFor(Sex sex) => sex.isMale
    ? const RatioAnchors(
        beginner: 0.5,
        novice: 0.75,
        intermediate: 1.25,
        advanced: 1.75,
        elite: 2.0,
      )
    : const RatioAnchors(
        beginner: 0.25,
        novice: 0.5,
        intermediate: 0.75,
        advanced: 1.0,
        elite: 1.5,
      );
