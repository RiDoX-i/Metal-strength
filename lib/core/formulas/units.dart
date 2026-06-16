/// Weight unit handling. Internally the whole app computes in **kilograms**
/// (required by the Wilks/DOTS formulas); pounds are a display concern only.
enum WeightUnit {
  kg('kg'),
  lb('lb');

  const WeightUnit(this.symbol);
  final String symbol;
}

/// 1 kg == this many pounds (exact international avoirdupois pound).
const double _kgToLb = 2.2046226218;

class Units {
  const Units._();

  static double kgToLb(double kg) => kg * _kgToLb;
  static double lbToKg(double lb) => lb / _kgToLb;

  /// Convert [value] expressed in [from] into kilograms.
  static double toKg(double value, WeightUnit from) =>
      from == WeightUnit.kg ? value : lbToKg(value);

  /// Convert a kilogram [valueKg] into the user's [unit] for display.
  static double fromKg(double valueKg, WeightUnit unit) =>
      unit == WeightUnit.kg ? valueKg : kgToLb(valueKg);

  /// Round to the nearest displayable plate increment (0.5 kg / 1 lb).
  static double prettyRound(double value, WeightUnit unit) {
    final step = unit == WeightUnit.kg ? 0.5 : 1.0;
    return (value / step).round() * step;
  }
}
