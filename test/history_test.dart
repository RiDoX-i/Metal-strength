import 'package:flutter_test/flutter_test.dart';
import 'package:metal_strength/core/formulas/one_rep_max.dart';
import 'package:metal_strength/core/formulas/tiers.dart';
import 'package:metal_strength/core/models/assessment_record.dart';
import 'package:metal_strength/core/models/exercise.dart';
import 'package:metal_strength/core/models/strength_result.dart';
import 'package:metal_strength/core/models/user_profile.dart';
import 'package:metal_strength/state/history_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

StrengthResult _weighted(double oneRm) => StrengthResult(
      exerciseName: 'Bench',
      oneRmKg: oneRm,
      tier: StrengthTier.intermediate,
      percentile: 55,
      bodyweightRatio: oneRm / 80,
      formula: OneRepMaxFormula.epley,
      lowConfidence: false,
      isEstimate: false,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AssessmentRecord', () {
    test('JSON round-trips losslessly', () {
      final r = AssessmentRecord(
        exerciseId: 'bench-press',
        exerciseName: 'Bench Press',
        at: DateTime.fromMillisecondsSinceEpoch(1700000000000),
        tier: StrengthTier.advanced,
        percentile: 82.4,
        bodyweightKg: 84,
        oneRmKg: 140.5,
      );
      final back = AssessmentRecord.fromJson(r.toJson());
      expect(back.exerciseId, r.exerciseId);
      expect(back.exerciseName, r.exerciseName);
      expect(back.at, r.at);
      expect(back.tier, StrengthTier.advanced);
      expect(back.percentile, closeTo(82.4, 1e-9));
      expect(back.bodyweightKg, 84);
      expect(back.oneRmKg, 140.5);
      expect(back.repCount, isNull);
      expect(back.isReps, isFalse);
    });

    test('fromResult copies the tangible metric', () {
      final rec = AssessmentRecord.fromResult(
        exercise: _ex('bench-press'),
        result: _weighted(120),
        profile: const UserProfile(bodyweightKg: 80),
      );
      expect(rec.metric, 120);
      expect(rec.oneRmKg, 120);
      expect(rec.bodyweightKg, 80);
      expect(rec.tier, StrengthTier.intermediate);
    });
  });

  group('HistoryService', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('records sort oldest-first per exercise, newest-first across', () async {
      final h = HistoryService();
      await h.init();
      await h.add(AssessmentRecord.fromResult(
        exercise: _ex('squat'),
        result: _weighted(100),
        profile: const UserProfile(),
        at: DateTime(2026, 1, 1),
      ));
      await h.add(AssessmentRecord.fromResult(
        exercise: _ex('bench-press'),
        result: _weighted(90),
        profile: const UserProfile(),
        at: DateTime(2026, 2, 1),
      ));
      await h.add(AssessmentRecord.fromResult(
        exercise: _ex('squat'),
        result: _weighted(110),
        profile: const UserProfile(),
        at: DateTime(2026, 3, 1),
      ));

      final squat = h.recordsFor('squat');
      expect(squat.map((r) => r.oneRmKg), [100, 110]); // oldest first
      expect(h.latestFor('squat')?.oneRmKg, 110);
      // Most-recently assessed exercise comes first.
      expect(h.trackedExerciseIds, ['squat', 'bench-press']);
    });

    test('survives a reload from persisted prefs', () async {
      final h = HistoryService();
      await h.init();
      await h.add(AssessmentRecord.fromResult(
        exercise: _ex('squat'),
        result: _weighted(100),
        profile: const UserProfile(),
      ));
      final reloaded = HistoryService();
      await reloaded.init();
      expect(reloaded.recordsFor('squat').length, 1);
    });

    test('CSV export has a header and one row per record', () async {
      final h = HistoryService();
      await h.init();
      await h.add(AssessmentRecord.fromResult(
        exercise: _ex('squat'),
        result: _weighted(100),
        profile: const UserProfile(),
        at: DateTime(2026, 1, 1),
      ));
      final csv = h.toCsv(exerciseId: 'squat').trim().split('\n');
      expect(csv.first, startsWith('date,exercise,tier,percentile'));
      expect(csv.length, 2);
      expect(csv[1], contains('squat'));
    });
  });
}
