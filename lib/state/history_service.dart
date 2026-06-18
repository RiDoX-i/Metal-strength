import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/models/assessment_record.dart';

/// Stores the user's saved strength assessments and exposes per-exercise
/// queries used by the progress / history screens. Persisted to
/// [SharedPreferences] as a JSON list under [_key].
class HistoryService extends ChangeNotifier {
  static const String _key = 'history_v1';

  final List<AssessmentRecord> _records = [];
  bool _ready = false;

  bool get ready => _ready;

  /// All records, newest first.
  List<AssessmentRecord> get all {
    final sorted = [..._records]..sort((a, b) => b.at.compareTo(a.at));
    return sorted;
  }

  bool get isEmpty => _records.isEmpty;

  /// Load saved history. Call once at startup.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        _records
          ..clear()
          ..addAll(list.map(
              (e) => AssessmentRecord.fromJson(e as Map<String, dynamic>)));
      } catch (_) {
        // Corrupt history — start fresh rather than crashing.
      }
    }
    _ready = true;
    notifyListeners();
  }

  /// Distinct exercise ids that have at least one record, ordered by most
  /// recently assessed first.
  List<String> get trackedExerciseIds {
    final seen = <String>[];
    for (final r in all) {
      if (!seen.contains(r.exerciseId)) seen.add(r.exerciseId);
    }
    return seen;
  }

  /// All records for one exercise, oldest first (chart-friendly order).
  List<AssessmentRecord> recordsFor(String exerciseId) {
    final list =
        _records.where((r) => r.exerciseId == exerciseId).toList()
          ..sort((a, b) => a.at.compareTo(b.at));
    return list;
  }

  /// The most recent record for one exercise, if any.
  AssessmentRecord? latestFor(String exerciseId) {
    final list = recordsFor(exerciseId);
    return list.isEmpty ? null : list.last;
  }

  Future<void> add(AssessmentRecord record) async {
    _records.add(record);
    notifyListeners();
    await _persist();
  }

  Future<void> remove(AssessmentRecord record) async {
    _records.removeWhere((r) =>
        r.exerciseId == record.exerciseId &&
        r.at.millisecondsSinceEpoch == record.at.millisecondsSinceEpoch);
    notifyListeners();
    await _persist();
  }

  Future<void> clearExercise(String exerciseId) async {
    _records.removeWhere((r) => r.exerciseId == exerciseId);
    notifyListeners();
    await _persist();
  }

  Future<void> clearAll() async {
    _records.clear();
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode(_records.map((r) => r.toJson()).toList()));
  }

  /// Build a CSV dump of the history — either one [exerciseId] or, when null,
  /// everything. Backs the (free) data-export feature. Weights are kilograms.
  String toCsv({String? exerciseId}) {
    final rows = (exerciseId == null ? all : recordsFor(exerciseId))
      ..sort((a, b) => a.at.compareTo(b.at));
    final buffer = StringBuffer()
      ..writeln('date,exercise,tier,percentile,est_1rm_kg,reps,bodyweight_kg');
    String esc(String v) =>
        v.contains(',') || v.contains('"') ? '"${v.replaceAll('"', '""')}"' : v;
    for (final r in rows) {
      buffer.writeln([
        r.at.toIso8601String(),
        esc(r.exerciseName),
        r.tier.name,
        r.percentile.toStringAsFixed(1),
        r.oneRmKg?.toStringAsFixed(1) ?? '',
        r.repCount?.toString() ?? '',
        r.bodyweightKg.toStringAsFixed(1),
      ].join(','));
    }
    return buffer.toString();
  }
}
