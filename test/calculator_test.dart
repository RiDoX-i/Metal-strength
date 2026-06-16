import 'package:flutter_test/flutter_test.dart';
import 'package:metal_strength/core/formulas/one_rep_max.dart';
import 'package:metal_strength/core/formulas/tiers.dart';
import 'package:metal_strength/core/models/exercise.dart';
import 'package:metal_strength/core/models/sex.dart';
import 'package:metal_strength/core/models/user_profile.dart';
import 'package:metal_strength/core/strength_calculator.dart';

// Male bench-press entry mirroring assets/catalog/exercises.json.
const benchPress = Exercise(
  id: 'bench-press',
  name: 'Bench Press',
  equipment: Equipment.barbell,
  loadType: LoadType.externalWeight,
  usesDataset: true,
  ageAdjust: true,
  isPowerlift: true,
  image: null,
  maleAnchors: RatioAnchors(
    beginner: 0.50,
    novice: 0.75,
    intermediate: 1.25,
    advanced: 1.75,
    elite: 2.00,
  ),
  femaleAnchors: RatioAnchors(
    beginner: 0.25,
    novice: 0.50,
    intermediate: 0.75,
    advanced: 1.00,
    elite: 1.50,
  ),
);

void main() {
  const calc = StrengthCalculator();

  test('full pipeline reproduces refrence §10 worked example', () {
    const profile = UserProfile(sex: Sex.male, bodyweightKg: 80);
    final result = calc.assessWeighted(
      exercise: benchPress,
      profile: profile,
      weightKg: 100,
      reps: 5,
      formula: OneRepMaxFormula.epley,
    );

    expect(result.oneRmKg, closeTo(116.667, 0.01));
    expect(result.bodyweightRatio, closeTo(1.4583, 0.001));
    expect(result.tier, StrengthTier.intermediate);
    expect(result.nextTier, StrengthTier.advanced);
    // Needs ~24.3kg more 1RM to hit Advanced (1.75 x 80 = 140kg).
    expect(result.toNextTierKg, closeTo(23.33, 0.1));
  });

  test('rep-based assessment classifies by reps', () {
    const pullUps = Exercise(
      id: 'pull-ups',
      name: 'Pull Ups',
      equipment: Equipment.bodyweight,
      loadType: LoadType.repCount,
      usesDataset: false,
      ageAdjust: false,
      maleAnchors: null,
      femaleAnchors: null,
    );
    final result = calc.assessRepBased(
      exercise: pullUps,
      reps: 12,
      repAnchors: const {
        StrengthTier.beginner: 1,
        StrengthTier.novice: 5,
        StrengthTier.intermediate: 12,
        StrengthTier.advanced: 20,
        StrengthTier.elite: 30,
      },
    );
    expect(result.repCount, 12);
    expect(result.tier, StrengthTier.intermediate);
    expect(result.oneRmKg, isNull);
  });
}
