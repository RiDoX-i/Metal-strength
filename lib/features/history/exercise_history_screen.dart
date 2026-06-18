import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/formulas/units.dart';
import '../../core/models/assessment_record.dart';
import '../../core/models/exercise.dart';
import '../../l10n/app_strings.dart';
import '../../state/app_state.dart';
import '../../state/history_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/exercise_glyph.dart';
import '../../widgets/trend_chart.dart';

/// Full progress detail for one exercise: a trend chart of estimated 1RM (or
/// reps) plus a dated log of every assessment. The full history and CSV export
/// are free for everyone.
class ExerciseHistoryScreen extends StatelessWidget {
  const ExerciseHistoryScreen({super.key, required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryService>();
    final unit = context.watch<AppState>().unit;

    final all = history.recordsFor(exercise.id); // oldest first
    if (all.isEmpty) {
      // Everything for this exercise was deleted while open — leave.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    final visible = all;
    final isReps = visible.last.isReps;
    final tierColor = Color(visible.last.tier.colorValue);

    double chartValue(AssessmentRecord r) =>
        isReps ? (r.repCount ?? 0).toDouble() : Units.fromKg(r.oneRmKg ?? 0, unit);

    return Scaffold(
      appBar: AppBar(
        title: Text(exerciseName(context, exercise), overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: tr(context, 'export'),
            icon: const Icon(Icons.ios_share_rounded),
            onPressed: () => _export(context, history),
          ),
          IconButton(
            tooltip: tr(context, 'clear_history'),
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => _confirmClear(context, history),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            _header(context, visible.last, tierColor),
            const SizedBox(height: 18),
            _chartCard(context, visible, chartValue, isReps, unit, tierColor),
            const SizedBox(height: 16),
            _logHeader(context),
            const SizedBox(height: 8),
            for (final r in visible.reversed)
              _LogRow(record: r, unit: unit, history: history),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, AssessmentRecord latest, Color color) {
    return Row(
      children: [
        ExerciseGlyph(exercise: exercise, size: 56, radius: 16),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tierLabel(context, latest.tier),
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: 18)),
              const SizedBox(height: 2),
              Text(
                trp(context, 'stronger_than', {'n': latest.percentile.round()}),
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chartCard(
    BuildContext context,
    List<AssessmentRecord> visible,
    double Function(AssessmentRecord) chartValue,
    bool isReps,
    WeightUnit unit,
    Color color,
  ) {
    final points = [for (final r in visible) TrendPoint(r.at, chartValue(r))];
    final first = chartValue(visible.first);
    final last = chartValue(visible.last);
    final delta = last - first;
    final metricLabel =
        isReps ? tr(context, 'reps_trend') : tr(context, 'est_1rm_trend');

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(metricLabel,
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const Spacer(),
              if (visible.length > 1) _deltaChip(context, delta, isReps, unit),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isReps
                ? trp(context, 'reps_value', {'n': last.round()})
                : _weight(last, unit),
            style: TextStyle(
                color: color, fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          TrendChart(points: points, color: color),
        ],
      ),
    );
  }

  Widget _deltaChip(
      BuildContext context, double delta, bool isReps, WeightUnit unit) {
    final up = delta >= 0;
    final color = up ? const Color(0xFF4FB477) : const Color(0xFFEC5C7D);
    final text = isReps
        ? '${up ? '+' : ''}${delta.round()}'
        : '${up ? '+' : '−'}${_weight(delta.abs(), unit)}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              size: 13, color: color),
          const SizedBox(width: 3),
          Text(text,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w700, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _logHeader(BuildContext context) => Text(
        tr(context, 'history_log'),
        style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600),
      );

  Future<void> _export(
      BuildContext context, HistoryService history) async {
    final csv = history.toCsv(exerciseId: exercise.id);
    await Clipboard.setData(ClipboardData(text: csv));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(tr(context, 'exported_clipboard'))),
    );
  }

  Future<void> _confirmClear(
      BuildContext context, HistoryService history) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(tr(ctx, 'clear_history')),
        content: Text(tr(ctx, 'clear_history_q')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(tr(ctx, 'cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(tr(ctx, 'delete'),
                style: const TextStyle(color: Color(0xFFEC5C7D))),
          ),
        ],
      ),
    );
    if (ok == true) {
      // The build method's empty-history guard pops the screen once the last
      // record is gone, so we don't pop here (avoids a double-pop).
      await history.clearExercise(exercise.id);
    }
  }

  static String _weight(double kg, WeightUnit unit) {
    final v = Units.prettyRound(Units.fromKg(kg, unit), unit);
    final text =
        v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
    return '$text ${unit.symbol}';
  }
}

class _LogRow extends StatelessWidget {
  const _LogRow({required this.record, required this.unit, required this.history});

  final AssessmentRecord record;
  final WeightUnit unit;
  final HistoryService history;

  String _date(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  String _value(BuildContext context) {
    if (record.isReps) {
      return trp(context, 'reps_value', {'n': record.repCount ?? 0});
    }
    final v = Units.prettyRound(Units.fromKg(record.oneRmKg ?? 0, unit), unit);
    final text =
        v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
    return '$text ${unit.symbol}';
  }

  @override
  Widget build(BuildContext context) {
    final tierColor = Color(record.tier.colorValue);
    return Dismissible(
      key: ValueKey(record.at.millisecondsSinceEpoch),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEC5C7D).withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_rounded, color: Color(0xFFEC5C7D)),
      ),
      onDismissed: (_) => history.remove(record),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.stroke),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: tierColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_value(context),
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(
                    '${tierLabel(context, record.tier)}  ·  ${record.percentile.round()}%',
                    style: TextStyle(color: tierColor, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(_date(record.at),
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12.5)),
          ],
        ),
      ),
    );
  }
}
