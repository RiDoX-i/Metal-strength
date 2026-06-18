import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:metal_strength/core/data/exercise_art.dart';
import 'package:metal_strength/core/data/world_records.dart';
import 'package:metal_strength/core/models/exercise.dart';
import 'package:metal_strength/core/models/sex.dart';

Exercise _ex(String id) => Exercise(
      id: id,
      name: id.replaceAll('-', ' '),
      equipment: Equipment.barbell,
      loadType: LoadType.externalWeight,
      usesDataset: false,
      ageAdjust: false,
      maleAnchors: null,
      femaleAnchors: null,
    );

void main() {
  group('figure classifier', () {
    const expected = <String, String>{
      'front-squat': 'front_squat',
      'squat': 'squat',
      'romanian-deadlift': 'hinge',
      'deadlift': 'deadlift',
      'snatch-grip-deadlift': 'deadlift', // pull, not Olympic
      'power-clean': 'olympic',
      'bench-press': 'bench_press',
      'incline-bench-press': 'incline_press',
      'overhead-press': 'overhead_press',
      'pull-ups': 'pull_up',
      'lat-pulldown': 'pulldown',
      'barbell-row': 'row',
      'barbell-curl': 'curl',
      'nordic-curl': 'leg_curl', // beats generic "curl"
      'skull-crusher': 'triceps',
      'lateral-raise': 'lateral_raise',
      'barbell-shrug': 'shrug',
      'bodyweight-lunge': 'lunge',
      'leg-press': 'leg_press',
      'leg-extension': 'leg_extension',
      'calf-raise-bodyweight': 'calf_raise',
      'hip-thrust': 'hip_thrust',
      'plank': 'plank',
      'hanging-leg-raise': 'hanging_leg_raise',
      'sit-ups': 'crunch',
      'push-ups': 'push_up',
      'dips': 'dip',
      'kettlebell-swing': 'kettlebell_swing',
      'totally-unknown-move': 'generic',
    };

    expected.forEach((id, pattern) {
      test('$id -> $pattern', () {
        expect(patternFor(_ex(id)), pattern);
      });
    });

    test('every mapped figure asset exists on disk', () {
      for (final pattern in {...expected.values, 'generic'}) {
        final file = File('assets/images/figures/$pattern.svg');
        expect(file.existsSync(), isTrue, reason: 'missing ${file.path}');
      }
    });

    test('figureFor returns the equipment-category icon', () {
      // _ex() builds a barbell exercise, so every id resolves to the one
      // shared barbell logo regardless of movement pattern.
      expect(figureFor(_ex('bench-press')), 'assets/images/barbell.svg');
    });

    test('every equipment type has an icon asset', () {
      for (final e in Equipment.values) {
        final file = File('assets/images/${e.name}.svg');
        expect(file.existsSync(), isTrue, reason: 'missing ${file.path}');
      }
    });

    test('every catalog exercise maps to an existing figure asset', () {
      final raw =
          File('assets/catalog/exercises.json').readAsStringSync();
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final list = (json['exercises'] as List<dynamic>)
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList();
      expect(list.length, greaterThan(250));
      for (final e in list) {
        final file = File(figureFor(e));
        expect(file.existsSync(), isTrue,
            reason: '${e.id} -> ${figureFor(e)} is missing');
      }
    });
  });

  group('world records', () {
    test('major lift has gendered records', () {
      expect(worldRecordFor('squat', Sex.male)?.holder, 'Ray Williams');
      expect(worldRecordFor('squat', Sex.female), isNotNull);
    });

    test('lift without a record returns null', () {
      expect(worldRecordFor('barbell-curl', Sex.male), isNull);
    });
  });
}
