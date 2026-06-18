import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:metal_strength/l10n/exercise_names.dart';

/// Guards the localized exercise-name table against drift: every catalog
/// exercise must have a complete set of translations, and there must be no
/// orphan entries. Regenerate with `python tool/generate_exercise_names.py`.
void main() {
  const langs = ['en', 'fr', 'es', 'de', 'pt'];

  final raw = File('assets/catalog/exercises.json').readAsStringSync();
  final json = jsonDecode(raw) as Map<String, dynamic>;
  final catalogIds = (json['exercises'] as List<dynamic>)
      .map((e) => (e as Map<String, dynamic>)['id'] as String)
      .toSet();

  test('every catalog exercise has a localized name entry', () {
    final missing = catalogIds.difference(kExerciseNames.keys.toSet());
    expect(missing, isEmpty, reason: 'no translations for: $missing');
  });

  test('no orphan translations for unknown ids', () {
    final orphans = kExerciseNames.keys.toSet().difference(catalogIds);
    expect(orphans, isEmpty, reason: 'translations for unknown ids: $orphans');
  });

  test('every entry has all languages, non-empty', () {
    kExerciseNames.forEach((id, names) {
      for (final lang in langs) {
        expect(names[lang], isNotNull, reason: '$id missing $lang');
        expect(names[lang]!.trim(), isNotEmpty, reason: '$id has empty $lang');
      }
    });
  });
}
