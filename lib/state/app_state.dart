import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/data/exercise_repository.dart';
import '../core/formulas/units.dart';
import '../core/models/exercise.dart';
import '../core/models/sex.dart';
import '../core/models/user_profile.dart';

/// App-wide state: the lifter profile, unit preference, and the loaded catalog.
/// Profile changes are persisted to [SharedPreferences].
class AppState extends ChangeNotifier {
  AppState({ExerciseRepository? repository})
      : _repository = repository ?? ExerciseRepository();

  static const String _profileKey = 'profile_v1';

  final ExerciseRepository _repository;
  ExerciseRepository get repository => _repository;

  UserProfile _profile = const UserProfile();
  UserProfile get profile => _profile;

  bool _ready = false;
  bool get ready => _ready;

  List<Exercise> get exercises => _repository.all;

  WeightUnit get unit => _profile.unit;

  /// Load the catalog + saved profile. Call once at startup.
  Future<void> init() async {
    await _repository.load();
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profileKey);
    if (raw != null) {
      try {
        _profile = UserProfile.fromJson(
            jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {
        // Corrupt prefs — fall back to defaults silently.
      }
    }
    _ready = true;
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile profile) async {
    _profile = profile;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  Future<void> setSex(Sex sex) => updateProfile(_profile.copyWith(sex: sex));

  Future<void> setBodyweightKg(double kg) =>
      updateProfile(_profile.copyWith(bodyweightKg: kg));

  Future<void> setAge(int? age) => updateProfile(
        age == null
            ? _profile.copyWith(clearAge: true)
            : _profile.copyWith(age: age),
      );

  Future<void> setUnit(WeightUnit unit) =>
      updateProfile(_profile.copyWith(unit: unit));
}
