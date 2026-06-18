import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/assessment_record.dart';
import '../../core/models/exercise.dart';
import '../../l10n/app_strings.dart';
import '../../state/app_state.dart';
import '../../state/history_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/exercise_glyph.dart';
import '../../widgets/trend_chart.dart';
import '../home/catalog_screen.dart';
import 'exercise_history_screen.dart';

/// Progress hub: one row per exercise the user has assessed, each with a
/// percentile sparkline. Tapping a row opens its full trend + entry log.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryService>();
    final repo = context.read<AppState>().repository;
    final ids = history.trackedExerciseIds;

    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'progress'))),
      body: SafeArea(
        top: false,
        child: ids.isEmpty
            ? _Empty()
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                itemCount: ids.length + 1,
                separatorBuilder: (_, i) =>
                    SizedBox(height: i == 0 ? 0 : 12),
                itemBuilder: (_, i) {
                  if (i == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Text(
                        tr(context, 'history_subtitle'),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    );
                  }
                  final id = ids[i - 1];
                  return _HistoryRow(
                    exercise: repo.byId(id),
                    records: history.recordsFor(id),
                  );
                },
              ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.exercise, required this.records});

  final Exercise? exercise;
  final List<AssessmentRecord> records;

  @override
  Widget build(BuildContext context) {
    final latest = records.last;
    final tierColor = Color(latest.tier.colorValue);
    final spark = records.map((r) => r.percentile).toList();

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: exercise == null
            ? null
            : () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ExerciseHistoryScreen(exercise: exercise!),
                )),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.stroke),
          ),
          child: Row(
            children: [
              if (exercise != null)
                ExerciseGlyph(exercise: exercise!, size: 48, radius: 14)
              else
                _FallbackGlyph(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        exercise != null
                            ? exerciseName(context, exercise!)
                            : latest.exerciseName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(tierLabel(context, latest.tier),
                            style: TextStyle(
                                color: tierColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5)),
                        Text(
                          '  ·  ${trp(context, 'assessments_count', {'n': records.length})}',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Sparkline(values: spark, color: tierColor),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _FallbackGlyph extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(Icons.fitness_center_rounded,
          color: AppColors.textSecondary, size: 22),
    );
  }
}

class _Empty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.timeline_rounded,
                size: 52, color: AppColors.textSecondary),
            const SizedBox(height: 14),
            Text(tr(context, 'history_empty'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.textSecondary, height: 1.4)),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (_) => const CatalogScreen()));
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.stroke),
                foregroundColor: AppColors.textPrimary,
              ),
              icon: const Icon(Icons.fitness_center_rounded, size: 18),
              label: Text(tr(context, 'browse_exercises')),
            ),
          ],
        ),
      ),
    );
  }
}
