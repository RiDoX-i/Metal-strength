import 'package:flutter_test/flutter_test.dart';
import 'package:metal_strength/core/models/exercise.dart';
import 'package:metal_strength/l10n/app_strings.dart';

Exercise _ex(String id, String name) => Exercise(
      id: id,
      name: name,
      equipment: Equipment.barbell,
      loadType: LoadType.externalWeight,
      usesDataset: false,
      ageAdjust: false,
      maleAnchors: null,
      femaleAnchors: null,
    );

void main() {
  group('cross-language exercise search', () {
    final bench = _ex('bench-press', 'Bench Press');
    final squat = _ex('squat', 'Squat');

    test('matches the canonical English name', () {
      expect(exerciseMatchesQuery(bench, 'bench'), isTrue);
    });

    test('matches translations in every shipped language', () {
      expect(exerciseMatchesQuery(bench, 'press de banca'), isTrue); // es
      expect(exerciseMatchesQuery(bench, 'bankdrücken'), isTrue); // de
      expect(exerciseMatchesQuery(bench, 'supino'), isTrue); // pt
      expect(exerciseMatchesQuery(bench, 'développé'), isTrue); // fr
    });

    test('is accent- and case-insensitive', () {
      expect(exerciseMatchesQuery(bench, 'DEVELOPPE'), isTrue);
      expect(exerciseMatchesQuery(squat, 'sentadílla'), isTrue);
    });

    test('matches on the id slug too', () {
      expect(exerciseMatchesQuery(bench, 'bench press'), isTrue);
    });

    test('an empty query matches everything', () {
      expect(exerciseMatchesQuery(bench, '   '), isTrue);
    });

    test('an unrelated query does not match', () {
      expect(exerciseMatchesQuery(bench, 'deadlift'), isFalse);
    });
  });
}
