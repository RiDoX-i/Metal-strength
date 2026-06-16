/// Age adjustment (`refrence` Section 6). Strength peaks ~25–35 then declines;
/// it also ramps up through the late teens. We return a multiplier applied to a
/// raw 1RM so that a non-peak lifter is compared on equal footing.
///
/// The curve is a bounded, monotone-ish approximation inspired by published
/// masters/sub-junior age coefficients — recalibrate from the dataset later.
class AgeAdjust {
  const AgeAdjust._();

  /// Multiplier (>= 1.0) for [age]. Returns 1.0 inside the peak window or when
  /// [age] is null. Capped so extreme ages can't explode the score.
  static double factor(int? age) {
    if (age == null) return 1.0;
    if (age >= 25 && age <= 35) return 1.0;

    if (age < 25) {
      // Late teens / early 20s ramp: ~1.10 at 14 -> 1.00 at 25.
      if (age <= 13) return 1.15;
      final t = (25 - age) / (25 - 14); // 0 at 25, 1 at 14
      return (1.0 + 0.12 * t).clamp(1.0, 1.15);
    }

    // Masters decline: gentle to 40, steeper after.
    final over = age - 35;
    // ~0.6% per year to 50, then ~1.2%/yr, bounded at +60%.
    final pct = over <= 15 ? over * 0.006 : 15 * 0.006 + (over - 15) * 0.012;
    return (1.0 + pct).clamp(1.0, 1.6);
  }
}
