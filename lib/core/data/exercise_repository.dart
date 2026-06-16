import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../formulas/tiers.dart';
import '../models/exercise.dart';
import '../models/sex.dart';

/// Loads the exercise catalog (assets/catalog/exercises.json) and exposes the
/// rep-count anchors for bodyweight movements.
class ExerciseRepository {
  ExerciseRepository();

  static const String _assetPath = 'assets/catalog/exercises.json';

  List<Exercise> _exercises = const [];
  bool _loaded = false;

  List<Exercise> get all => _exercises;
  bool get isLoaded => _loaded;

  Future<List<Exercise>> load() async {
    if (_loaded) return _exercises;
    final raw = await rootBundle.loadString(_assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final list = (json['exercises'] as List<dynamic>)
        .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
    _exercises = list;
    _loaded = true;
    return _exercises;
  }

  Exercise? byId(String id) {
    for (final e in _exercises) {
      if (e.id == id) return e;
    }
    return null;
  }

  List<Exercise> byEquipment(Equipment equipment) =>
      _exercises.where((e) => e.equipment == equipment).toList();

  List<Exercise> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return _exercises;
    return _exercises.where((e) => e.name.toLowerCase().contains(q)).toList();
  }

  /// Rep-count anchors (reps needed per tier) for bodyweight exercises, by sex.
  /// Falls back to a generic curve for any unlisted bodyweight exercise.
  static Map<StrengthTier, int> repAnchors(String exerciseId, Sex sex) {
    final table = sex.isMale ? _repAnchorsMale : _repAnchorsFemale;
    final anchors = table[exerciseId] ?? _genericRepAnchors;
    return {
      StrengthTier.beginner: anchors[0],
      StrengthTier.novice: anchors[1],
      StrengthTier.intermediate: anchors[2],
      StrengthTier.advanced: anchors[3],
      StrengthTier.elite: anchors[4],
    };
  }

  // [beginner, novice, intermediate, advanced, elite]
  static const List<int> _genericRepAnchors = [5, 12, 25, 40, 60];

  static const Map<String, List<int>> _repAnchorsMale = {
    'pull-ups': [1, 5, 12, 20, 30],
    'chin-ups': [1, 6, 14, 22, 32],
    'muscle-ups': [1, 2, 5, 10, 16],
    'inverted-row': [5, 12, 20, 30, 45],
    'push-ups': [10, 20, 40, 60, 90],
    'diamond-push-up': [5, 12, 25, 40, 60],
    'wide-push-up': [8, 16, 32, 50, 75],
    'decline-push-up': [6, 14, 28, 45, 65],
    'pike-push-up': [3, 8, 16, 28, 45],
    'handstand-push-up': [1, 3, 6, 12, 20],
    'dips': [1, 8, 20, 35, 50],
    'bodyweight-squat': [25, 40, 60, 90, 130],
    'bodyweight-lunge': [15, 30, 50, 75, 110],
    'pistol-squat': [1, 3, 6, 12, 20],
    'jump-squat': [15, 30, 50, 75, 110],
    'bodyweight-step-up': [15, 30, 50, 75, 110],
    'glute-bridge': [20, 35, 55, 80, 120],
    'nordic-curl': [1, 3, 6, 10, 16],
    'calf-raise-bodyweight': [25, 45, 70, 100, 140],
    'hanging-leg-raise': [5, 10, 18, 28, 40],
    'hanging-knee-raise': [8, 15, 25, 38, 55],
    'toes-to-bar': [3, 8, 15, 25, 38],
    'sit-ups': [20, 35, 55, 75, 100],
    'crunches': [25, 45, 70, 100, 140],
    'bicycle-crunch': [20, 40, 70, 100, 140],
    'russian-twist': [20, 40, 70, 100, 140],
    'flutter-kicks': [20, 40, 70, 100, 140],
    'mountain-climbers': [20, 40, 70, 100, 140],
    'burpees': [10, 20, 35, 55, 80],
    'superman': [15, 30, 50, 75, 110],
    'hyperextension': [15, 30, 50, 75, 110],
    // Time-based holds — anchors are in SECONDS.
    'plank': [30, 60, 120, 180, 300],
    'side-plank': [20, 40, 75, 120, 180],
    'wall-sit': [30, 60, 120, 180, 300],
    'l-sit': [5, 10, 20, 30, 45],
  };

  static const Map<String, List<int>> _repAnchorsFemale = {
    'pull-ups': [1, 2, 5, 10, 16],
    'chin-ups': [1, 3, 6, 12, 18],
    'muscle-ups': [1, 1, 2, 4, 8],
    'inverted-row': [3, 8, 15, 24, 36],
    'push-ups': [5, 12, 25, 40, 60],
    'diamond-push-up': [2, 6, 14, 25, 40],
    'wide-push-up': [4, 10, 22, 38, 58],
    'decline-push-up': [3, 8, 18, 32, 50],
    'pike-push-up': [1, 4, 10, 20, 34],
    'handstand-push-up': [1, 1, 3, 7, 14],
    'dips': [1, 3, 10, 20, 30],
    'bodyweight-squat': [20, 35, 55, 80, 120],
    'bodyweight-lunge': [12, 25, 42, 65, 95],
    'pistol-squat': [1, 2, 5, 10, 17],
    'jump-squat': [12, 25, 42, 65, 95],
    'bodyweight-step-up': [12, 25, 42, 65, 95],
    'glute-bridge': [20, 35, 55, 80, 120],
    'nordic-curl': [1, 2, 4, 8, 13],
    'calf-raise-bodyweight': [25, 45, 70, 100, 140],
    'hanging-leg-raise': [3, 7, 13, 22, 33],
    'hanging-knee-raise': [5, 11, 20, 31, 46],
    'toes-to-bar': [1, 5, 11, 19, 30],
    'sit-ups': [18, 30, 50, 70, 95],
    'crunches': [20, 40, 65, 95, 135],
    'bicycle-crunch': [18, 36, 62, 92, 130],
    'russian-twist': [18, 36, 62, 92, 130],
    'flutter-kicks': [18, 36, 62, 92, 130],
    'mountain-climbers': [18, 36, 62, 92, 130],
    'burpees': [8, 16, 28, 46, 68],
    'superman': [15, 30, 50, 75, 110],
    'hyperextension': [15, 30, 50, 75, 110],
    // Time-based holds — anchors are in SECONDS.
    'plank': [25, 50, 100, 160, 260],
    'side-plank': [18, 35, 65, 105, 160],
    'wall-sit': [25, 50, 100, 160, 260],
    'l-sit': [3, 7, 15, 24, 38],
  };
}
