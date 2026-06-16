import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formulas/tiers.dart';
import '../../core/formulas/units.dart';
import '../../core/models/exercise.dart';
import '../../core/models/strength_result.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/exercise_glyph.dart';
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
    final unit = context.watch<AppState>().unit;
    final tierColor = Color(result.tier.colorValue);
    final isReps = result.oneRmKg == null;

    return Scaffold(
      appBar: AppBar(title: const Text('Result')),
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
                  child: Text(exercise.name,
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
                'Stronger than ${result.percentile.round()}% of lifters',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                if (isReps)
                  _StatCard(
                    label: 'Reps',
                    value: '${result.repCount}',
                    color: tierColor,
                  )
                else ...[
                  _StatCard(
                    label: 'Est. 1RM',
                    value: _weight(result.oneRmKg!, unit),
                    color: tierColor,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    label: 'Bodyweight ratio',
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
            _tierLadder(),
            const SizedBox(height: 16),
            _notes(),
          ],
        ),
      ),
    );
  }

  String _weight(double kg, WeightUnit unit) {
    final v = Units.prettyRound(Units.fromKg(kg, unit), unit);
    final text = v == v.roundToDouble()
        ? v.toStringAsFixed(0)
        : v.toStringAsFixed(1);
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
                "You're at the top tier — Elite. Outstanding.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );
    }

    final gap = result.toNextTierKg!;
    final addText = isReps
        ? '${gap.ceil()} more reps'
        : '+${_weight(gap, unit)}';
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up_rounded, color: Color(next.colorValue)),
              const SizedBox(width: 10),
              Text('Next: ${next.label}',
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

  Widget _tierLadder() {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tier ladder',
              style: TextStyle(
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
                          tier.label,
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

  Widget _notes() {
    final notes = <String>[
      if (!result.oneRmKg.isNull)
        'Estimated with the ${result.formula.label} formula.',
      if (result.lowConfidence)
        'High-rep estimate — treat the 1RM as approximate.',
      if (result.isEstimate)
        result.estimateNote ??
            'Standards are ratio-based estimates, not dataset percentiles.',
    ];
    if (notes.isEmpty) return const SizedBox.shrink();
    return _glassCard(
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
