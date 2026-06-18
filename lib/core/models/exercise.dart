import '../formulas/tiers.dart';
import 'sex.dart';

/// Equipment groupings used for catalog filtering + the fallback illustration.
enum Equipment {
  barbell('Barbell'),
  dumbbell('Dumbbell'),
  kettlebell('Kettlebell'),
  machine('Machine'),
  cable('Cable'),
  bodyweight('Bodyweight');

  const Equipment(this.label);
  final String label;

  static Equipment fromId(String id) => Equipment.values.firstWhere(
        (e) => e.name == id,
        orElse: () => Equipment.machine,
      );
}

/// How an exercise is measured.
enum LoadType {
  /// Classified by the external weight lifted (most lifts).
  externalWeight,

  /// Bodyweight movement classified by rep count vs. population.
  repCount,
}

/// A single catalog entry (`refrence` Section 6).
class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.equipment,
    required this.loadType,
    required this.usesDataset,
    required this.ageAdjust,
    required this.maleAnchors,
    required this.femaleAnchors,
    this.femaleFactor = 0.72,
    this.isPowerlift = false,
    this.estimateNote,
    this.image,
  });

  final String id;
  final String name;
  final Equipment equipment;
  final LoadType loadType;
  final bool usesDataset;
  final bool ageAdjust;

  /// True for squat/bench/deadlift — eligible for Wilks/DOTS scoring.
  final bool isPowerlift;

  /// Set when standards are derived as a ratio of a compound lift (an estimate).
  final String? estimateNote;

  /// Asset path to the non-human SVG illustration, if a bespoke one exists.
  final String? image;

  final RatioAnchors? maleAnchors;
  final RatioAnchors? femaleAnchors;

  /// When [femaleAnchors] is absent, female standards are derived as
  /// [maleAnchors] × this factor (lower body lifts close the gender gap more).
  final double femaleFactor;

  bool get isBodyweight => loadType == LoadType.repCount;

  RatioAnchors anchorsFor(Sex sex) {
    if (sex.isMale) return maleAnchors ?? fallbackAnchorsFor(sex);
    if (femaleAnchors != null) return femaleAnchors!;
    if (maleAnchors != null) return maleAnchors!.scaled(femaleFactor);
    return fallbackAnchorsFor(sex);
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    RatioAnchors? anchors(String sexKey) {
      final ratios = json['ratios'] as Map<String, dynamic>?;
      final block = ratios?[sexKey] as Map<String, dynamic>?;
      return block == null ? null : RatioAnchors.fromJson(block);
    }

    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      equipment: Equipment.fromId(json['equipment'] as String),
      loadType: (json['loadType'] as String) == 'rep_count'
          ? LoadType.repCount
          : LoadType.externalWeight,
      usesDataset: json['usesDataset'] as bool? ?? false,
      ageAdjust: json['ageAdjust'] as bool? ?? false,
      isPowerlift: json['isPowerlift'] as bool? ?? false,
      estimateNote: json['estimateNote'] as String?,
      image: json['image'] as String?,
      femaleFactor: (json['femaleFactor'] as num?)?.toDouble() ?? 0.72,
      maleAnchors: anchors('male'),
      femaleAnchors: anchors('female'),
    );
  }
}
