import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/data/exercise_tips.dart';
import '../../core/data/world_records.dart';
import '../../core/formulas/tiers.dart';
import '../../core/formulas/units.dart';
import '../../core/models/exercise.dart';
import '../../core/models/sex.dart';
import '../../core/models/strength_result.dart';
import '../../l10n/app_strings.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/exercise_glyph.dart';
import '../../widgets/share_card.dart';
import '../../widgets/tier_gauge.dart';

/// Shows the tier / percentile outcome of an assessment.
class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.result,
    required this.exercise,
  });

  final StrengthResult result;
  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final unit = state.unit;
    final sex = state.profile.sex;
    final tierColor = Color(result.tier.colorValue);
    final isReps = result.oneRmKg == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr(context, 'result_title')),
        actions: [
          IconButton(
            tooltip: tr(context, 'share'),
            icon: const Icon(Icons.ios_share_rounded),
            onPressed: () => _share(context),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Row(
              children: [
                Hero(
                  tag: 'glyph-${exercise.id}',
                  child:
                      ExerciseGlyph(exercise: exercise, size: 52, radius: 14),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(exerciseName(context, exercise),
                      style: Theme.of(context).textTheme.titleLarge),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: TierGauge(
                percentile: result.percentile,
                tier: result.tier,
                centerValue: '${result.percentile.round()}%',
                centerLabel: result.tier.label,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                trp(context, 'stronger_than', {'n': result.percentile.round()}),
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 18),
            SecondaryButton(
              label: tr(context, 'share'),
              icon: Icons.ios_share_rounded,
              onPressed: () => _share(context),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                if (isReps)
                  _StatCard(
                    label: tr(context, 'reps'),
                    value: '${result.repCount}',
                    color: tierColor,
                  )
                else ...[
                  _StatCard(
                    label: tr(context, 'est_1rm'),
                    value: _weight(result.oneRmKg!, unit),
                    color: tierColor,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    label: tr(context, 'bw_ratio'),
                    value:
                        '${result.bodyweightRatio!.toStringAsFixed(2)}×',
                    color: tierColor,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            _nextTierCard(context, unit, isReps),
            const SizedBox(height: 16),
            _tierLadder(context),
            const SizedBox(height: 16),
            _worldRecordCard(context, sex, unit),
            _tipsCard(context),
            _notes(context),
          ],
        ),
      ),
    );
  }

  void _share(BuildContext context) {
    ShareResultSheet.show(
      context,
      result: result,
      exercise: exercise,
      unit: context.read<AppState>().unit,
    );
  }

  String _weight(double kg, WeightUnit unit) {
    final v = Units.prettyRound(Units.fromKg(kg, unit), unit);
    final text = v == v.roundToDouble()
        ? v.toStringAsFixed(0)
        : v.toStringAsFixed(1);
    return '$text ${unit.symbol}';
  }

  /// Exact (non plate-snapped) weight — used for world-record figures so the
  /// official numbers aren't rounded to the nearest plate.
  String _exactWeight(double kg, WeightUnit unit) {
    final v = Units.fromKg(kg, unit);
    final text =
        v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
    return '$text ${unit.symbol}';
  }

  Widget _nextTierCard(BuildContext context, WeightUnit unit, bool isReps) {
    final next = result.nextTier;
    if (next == null || result.toNextTierKg == null) {
      return _glassCard(
        child: Row(
          children: [
            const Icon(Icons.emoji_events_rounded, color: Color(0xFFFF9F43)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                tr(context, 'top_tier'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );
    }

    final gap = result.toNextTierKg!;
    final addText = isReps
        ? trp(context, 'more_reps', {'n': gap.ceil()})
        : '+${_weight(gap, unit)}';
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up_rounded, color: Color(next.colorValue)),
              const SizedBox(width: 10),
              Text(trp(context, 'next_tier', {'tier': tierLabel(context, next)}),
                  style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              Text(addText,
                  style: TextStyle(
                      color: Color(next.colorValue),
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _progressWithinTier(),
              minHeight: 8,
              backgroundColor: AppColors.surfaceAlt,
              valueColor:
                  AlwaysStoppedAnimation(Color(result.tier.colorValue)),
            ),
          ),
        ],
      ),
    );
  }

  /// Rough fill of the bar between current tier and the next.
  double _progressWithinTier() {
    final lo = result.tier.minPercentile.toDouble();
    final hi = (result.nextTier?.minPercentile ?? 100).toDouble();
    if (hi <= lo) return 1;
    return ((result.percentile - lo) / (hi - lo)).clamp(0.05, 1.0);
  }

  Widget _tierLadder(BuildContext context) {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr(context, 'tier_ladder'),
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final tier in StrengthTier.ordered)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          height: tier == result.tier ? 12 : 8,
                          decoration: BoxDecoration(
                            color: _tierReached(tier)
                                ? Color(tier.colorValue)
                                : AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          tierLabel(context, tier),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9.5,
                            color: tier == result.tier
                                ? Color(tier.colorValue)
                                : AppColors.textSecondary,
                            fontWeight: tier == result.tier
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  bool _tierReached(StrengthTier tier) =>
      StrengthTier.ordered.indexOf(tier) <=
      StrengthTier.ordered.indexOf(result.tier);

  /// World-record card, shown only for lifts that have a record for [sex].
  Widget _worldRecordCard(BuildContext context, Sex sex, WeightUnit unit) {
    final record = worldRecordFor(exercise.id, sex);
    if (record == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: _glassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFC93C)),
                const SizedBox(width: 10),
                Text(tr(context, 'world_record'),
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              sex.isMale ? tr(context, 'wr_men') : tr(context, 'wr_women'),
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12.5),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _exactWeight(record.weightKg, unit),
                  style: const TextStyle(
                      color: Color(0xFFFFC93C),
                      fontSize: 26,
                      fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                Flexible(
                  child: Text(
                    trp(context, 'wr_held_by',
                        {'holder': record.holder, 'year': record.year}),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              tr(context, record.categoryKey),
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11.5),
            ),
          ],
        ),
      ),
    );
  }

  /// Bullet-point tips for getting stronger on this movement.
  Widget _tipsCard(BuildContext context) {
    final tips = tipsFor(context, exercise);
    if (tips.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: _glassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tips_and_updates_rounded,
                    color: AppColors.accent),
                const SizedBox(width: 10),
                Text(tr(context, 'tips_title'),
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            for (final t in tips)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: _Dot(),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(t,
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13.5,
                              height: 1.35)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _notes(BuildContext context) {
    final notes = <String>[
      if (!result.oneRmKg.isNull) tr(context, 'note_epley'),
      if (result.lowConfidence) tr(context, 'note_high_rep'),
      if (result.isEstimate)
        result.estimateNote ?? tr(context, 'note_estimate'),
    ];
    if (notes.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: _glassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final n in notes)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.info_outline_rounded,
                          size: 15, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(n,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12.5)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _glassCard({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.stroke),
        ),
        child: child,
      );
}

extension on double? {
  bool get isNull => this == null;
}

/// Small accent bullet used in the tips list.
class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 5,
      decoration: const BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.stroke),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 22,
                    fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}
