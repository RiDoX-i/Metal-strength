/// Biological sex used to pick the correct standards/coefficients.
enum Sex {
  male('Male'),
  female('Female');

  const Sex(this.label);
  final String label;

  bool get isMale => this == Sex.male;
}
