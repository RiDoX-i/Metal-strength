import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formulas/scoring.dart';
import '../../core/formulas/units.dart';
import '../../core/models/user_profile.dart';
import '../../l10n/app_strings.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_widgets.dart';

/// Shows bodyweight-adjusted powerlifting scores for a squat/bench/deadlift
/// total (`refrence` Section 5). All inputs arrive in kilograms.
class ScoreResultScreen extends StatefulWidget {
  const ScoreResultScreen({
    super.key,
    required this.squatKg,
    required this.benchKg,
    required this.deadliftKg,
    required this.profile,
  });

  final double squatKg;
  final double benchKg;
  final double deadliftKg;
  final UserProfile profile;

  @override
  State<ScoreResultScreen> createState() => _ScoreResultScreenState();
}

class _ScoreResultScreenState extends State<ScoreResultScreen> {
  ScoreSystem _system = ScoreSystem.dots;

  double get _totalKg =>
      widget.squatKg + widget.benchKg + widget.deadliftKg;

  double _scoreFor(ScoreSystem s) => Scoring.score(
        s,
        _totalKg,
        widget.profile.bodyweightKg,
        widget.profile.sex,
      );

  @override
  Widget build(BuildContext context) {
    final unit = context.watch<AppState>().unit;
    final selected = _scoreFor(_system);
    final level = Scoring.interpret(selected);

    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'pl_score_title'))),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(_system.label.toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white70,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w700,
                          fontSize: 12)),
                  const SizedBox(height: 6),
                  Text(selected.toStringAsFixed(1),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 56,
                          fontWeight: FontWeight.w800,
                          height: 1)),
                  const SizedBox(height: 4),
                  Text(level,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SegmentedSelector<ScoreSystem>(
              options: ScoreSystem.values,
              selected: _system,
              labelOf: (s) => s.label,
              onChanged: (s) => setState(() => _system = s),
            ),
            const SizedBox(height: 20),
            SectionCard(
              child: Column(
                children: [
                  _liftRow(tr(context, 'squat'), widget.squatKg, unit),
                  _divider(),
                  _liftRow(tr(context, 'bench'), widget.benchKg, unit),
                  _divider(),
                  _liftRow(tr(context, 'deadlift'), widget.deadliftKg, unit),
                  _divider(),
                  _liftRow(tr(context, 'total'), _totalKg, unit, bold: true),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr(context, 'all_scoring'),
                      style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  for (final s in ScoreSystem.values)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(s.label,
                                style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600)),
                          ),
                          Text(_scoreFor(s).toStringAsFixed(1),
                              style: TextStyle(
                                  color: s == _system
                                      ? AppColors.accent
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                tr(context, 'pl_note'),
                style:
                    const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _liftRow(String name, double kg, WeightUnit unit,
      {bool bold = false}) {
    final v = Units.prettyRound(Units.fromKg(kg, unit), unit);
    final text = v == v.roundToDouble()
        ? v.toStringAsFixed(0)
        : v.toStringAsFixed(1);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(name,
                style: TextStyle(
                    color: bold
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                    fontSize: bold ? 16 : 15)),
          ),
          Text('$text ${unit.symbol}',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                  fontSize: bold ? 18 : 15)),
        ],
      ),
    );
  }

  Widget _divider() =>
      const Divider(height: 1, color: AppColors.stroke);
}
