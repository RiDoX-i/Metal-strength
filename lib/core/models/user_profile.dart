import '../formulas/units.dart';
import 'sex.dart';

/// The lifter's persistent profile. Bodyweight is always stored in **kg**;
/// [unit] only affects display + input parsing.
class UserProfile {
  const UserProfile({
    this.sex = Sex.male,
    this.bodyweightKg = 80,
    this.age,
    this.unit = WeightUnit.kg,
  });

  final Sex sex;
  final double bodyweightKg;
  final int? age;
  final WeightUnit unit;

  double get bodyweightInUnit => Units.fromKg(bodyweightKg, unit);

  UserProfile copyWith({
    Sex? sex,
    double? bodyweightKg,
    int? age,
    bool clearAge = false,
    WeightUnit? unit,
  }) {
    return UserProfile(
      sex: sex ?? this.sex,
      bodyweightKg: bodyweightKg ?? this.bodyweightKg,
      age: clearAge ? null : (age ?? this.age),
      unit: unit ?? this.unit,
    );
  }

  Map<String, dynamic> toJson() => {
        'sex': sex.name,
        'bodyweightKg': bodyweightKg,
        'age': age,
        'unit': unit.name,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        sex: Sex.values.firstWhere(
          (s) => s.name == json['sex'],
          orElse: () => Sex.male,
        ),
        bodyweightKg: (json['bodyweightKg'] as num?)?.toDouble() ?? 80,
        age: (json['age'] as num?)?.toInt(),
        unit: WeightUnit.values.firstWhere(
          (u) => u.name == json['unit'],
          orElse: () => WeightUnit.kg,
        ),
      );
}
