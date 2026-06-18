import 'dart:convert';
import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/data/exercise_repository.dart';
import '../core/formulas/units.dart';
import '../core/models/exercise.dart';
import '../core/models/sex.dart';
import '../core/models/user_profile.dart';

/// App-wide state: the lifter profile, unit preference, language, and the
/// loaded catalog. Profile + language changes are persisted to
/// [SharedPreferences].
class AppState extends ChangeNotifier {
  AppState({ExerciseRepository? repository})
      : _repository = repository ?? ExerciseRepository();

  static const String _profileKey = 'profile_v1';
  static const String _localeKey = 'locale_v1';

  /// Languages the UI ships translations for.
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('fr'),
    Locale('es'),
    Locale('de'),
    Locale('pt'),
  ];

  final ExerciseRepository _repository;
  ExerciseRepository get repository => _repository;

  UserProfile _profile = const UserProfile();
  UserProfile get profile => _profile;

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  bool _ready = false;
  bool get ready => _ready;

  List<Exercise> get exercises => _repository.all;

  WeightUnit get unit => _profile.unit;

  /// Load the catalog + saved profile + language. Call once at startup.
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
    final savedLang = prefs.getString(_localeKey);
    if (savedLang != null &&
        supportedLocales.any((l) => l.languageCode == savedLang)) {
      _locale = Locale(savedLang);
    }
    _ready = true;
    notifyListeners();
  }

  /// Switch the UI language and persist the choice.
  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.any((l) => l.languageCode == locale.languageCode)) {
      return;
    }
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
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
