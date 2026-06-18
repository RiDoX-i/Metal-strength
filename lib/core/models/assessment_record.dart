import '../formulas/tiers.dart';
import 'exercise.dart';
import 'strength_result.dart';
import 'user_profile.dart';

/// A single saved strength assessment — one entry in the user's progress
/// history. Weights are always stored in **kilograms** (display unit is a
/// presentation concern), so history survives a kg/lb switch unchanged.
class AssessmentRecord {
  const AssessmentRecord({
    required this.exerciseId,
    required this.exerciseName,
    required this.at,
    required this.tier,
    required this.percentile,
    required this.bodyweightKg,
    this.oneRmKg,
    this.repCount,
  });

  final String exerciseId;
  final String exerciseName;
  final DateTime at;
  final StrengthTier tier;

  /// Population percentile (0..100) at the time of the assessment.
  final double percentile;

  /// Bodyweight (kg) the lifter had when this was recorded.
  final double bodyweightKg;

  /// Estimated 1RM in kg for weighted lifts; null for rep-count exercises.
  final double? oneRmKg;

  /// Reps performed for bodyweight exercises; null for weighted lifts.
  final int? repCount;

  bool get isReps => oneRmKg == null;

  /// The tangible "progress" number this record tracks — estimated 1RM (kg)
  /// for weighted lifts, rep count for bodyweight movements.
  double get metric => oneRmKg ?? (repCount ?? 0).toDouble();

  /// Build a record from a freshly-computed [StrengthResult].
  factory AssessmentRecord.fromResult({
    required Exercise exercise,
    required StrengthResult result,
    required UserProfile profile,
    DateTime? at,
  }) {
    return AssessmentRecord(
      exerciseId: exercise.id,
      exerciseName: exercise.name,
      at: at ?? DateTime.now(),
      tier: result.tier,
      percentile: result.percentile,
      bodyweightKg: profile.bodyweightKg,
      oneRmKg: result.oneRmKg,
      repCount: result.repCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'exerciseName': exerciseName,
        'at': at.millisecondsSinceEpoch,
        'tier': tier.name,
        'percentile': percentile,
        'bodyweightKg': bodyweightKg,
        'oneRmKg': oneRmKg,
        'repCount': repCount,
      };

  factory AssessmentRecord.fromJson(Map<String, dynamic> json) =>
      AssessmentRecord(
        exerciseId: json['exerciseId'] as String,
        exerciseName: json['exerciseName'] as String? ?? json['exerciseId'] as String,
        at: DateTime.fromMillisecondsSinceEpoch((json['at'] as num).toInt()),
        tier: StrengthTier.values.firstWhere(
          (t) => t.name == json['tier'],
          orElse: () => StrengthTier.beginner,
        ),
        percentile: (json['percentile'] as num?)?.toDouble() ?? 0,
        bodyweightKg: (json['bodyweightKg'] as num?)?.toDouble() ?? 0,
        oneRmKg: (json['oneRmKg'] as num?)?.toDouble(),
        repCount: (json['repCount'] as num?)?.toInt(),
      );
}
