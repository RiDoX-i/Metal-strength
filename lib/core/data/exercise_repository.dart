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
    'push-ups': [10, 20, 40, 60, 90],
    'dips': [1, 8, 20, 35, 50],
    'chin-ups': [1, 6, 14, 22, 32],
    'muscle-ups': [1, 2, 5, 10, 16],
    'bodyweight-squat': [25, 40, 60, 90, 130],
    'sit-ups': [20, 35, 55, 75, 100],
    'crunches': [25, 45, 70, 100, 140],
  };

  static const Map<String, List<int>> _repAnchorsFemale = {
    'pull-ups': [1, 2, 5, 10, 16],
    'push-ups': [5, 12, 25, 40, 60],
    'dips': [1, 3, 10, 20, 30],
    'chin-ups': [1, 3, 6, 12, 18],
    'muscle-ups': [1, 1, 2, 4, 8],
    'bodyweight-squat': [20, 35, 55, 80, 120],
    'sit-ups': [18, 30, 50, 70, 95],
    'crunches': [20, 40, 65, 95, 135],
  };
}
