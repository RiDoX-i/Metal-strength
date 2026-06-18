import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/data/exercise_repository.dart';
import '../../core/formulas/one_rep_max.dart';
import '../../core/formulas/units.dart';
import '../../core/models/assessment_record.dart';
import '../../core/models/exercise.dart';
import '../../core/models/strength_result.dart';
import '../../core/models/user_profile.dart';
import '../../core/strength_calculator.dart';
import '../../l10n/app_strings.dart';
import '../../state/app_state.dart';
import '../../state/history_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/exercise_glyph.dart';
import '../profile/profile_sheet.dart';
import '../result/result_screen.dart';
import '../result/score_result_screen.dart';

/// How a powerlift is being assessed.
enum _MeasureMode { single, total }

/// Input + method-selection screen for one [exercise].
class MeasureScreen extends StatefulWidget {
  const MeasureScreen({super.key, required this.exercise});

  final Exercise exercise;

  @override
  State<MeasureScreen> createState() => _MeasureScreenState();
}

class _MeasureScreenState extends State<MeasureScreen> {
  final _weight = TextEditingController();
  final _reps = TextEditingController(text: '5');
  final _squat = TextEditingController();
  final _bench = TextEditingController();
  final _deadlift = TextEditingController();

  _MeasureMode _mode = _MeasureMode.single;

  Exercise get exercise => widget.exercise;

  @override
  void dispose() {
    _weight.dispose();
    _reps.dispose();
    _squat.dispose();
    _bench.dispose();
    _deadlift.dispose();
    super.dispose();
  }

  double? _parse(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '.'));

  bool get _canCalculate {
    if (exercise.isBodyweight) {
      final r = int.tryParse(_reps.text);
      return r != null && r > 0;
    }
    if (_mode == _MeasureMode.total) {
      return [_squat, _bench, _deadlift]
          .every((c) => (_parse(c) ?? 0) > 0);
    }
    final w = _parse(_weight) ?? 0;
    final r = int.tryParse(_reps.text) ?? 0;
    return w > 0 && r > 0;
  }

  void _calculate(AppState state) {
    final profile = state.profile;
    const calc = StrengthCalculator();

    if (exercise.isBodyweight) {
      final reps = int.parse(_reps.text);
      final result = calc.assessRepBased(
        exercise: exercise,
        reps: reps,
        repAnchors: ExerciseRepository.repAnchors(exercise.id, profile.sex),
      );
      _record(result, profile);
      _go(ResultScreen(result: result, exercise: exercise));
      return;
    }

    if (_mode == _MeasureMode.total) {
      _go(ScoreResultScreen(
        squatKg: Units.toKg(_parse(_squat)!, state.unit),
        benchKg: Units.toKg(_parse(_bench)!, state.unit),
        deadliftKg: Units.toKg(_parse(_deadlift)!, state.unit),
        profile: profile,
      ));
      return;
    }

    // 1RM is always estimated with Epley — the most widely used real-world
    // formula — so there is no user-facing formula choice.
    final result = calc.assessWeighted(
      exercise: exercise,
      profile: profile,
      weightKg: Units.toKg(_parse(_weight)!, state.unit),
      reps: int.parse(_reps.text),
    );
    _record(result, profile);
    _go(ResultScreen(result: result, exercise: exercise));
  }

  /// Save this assessment to the user's progress history (single-lift results
  /// only — the Wilks/DOTS total is a separate metric and isn't trended here).
  void _record(StrengthResult result, UserProfile profile) {
    context.read<HistoryService>().add(AssessmentRecord.fromResult(
          exercise: exercise,
          result: result,
          profile: profile,
        ));
  }

  void _go(Widget screen) {
    FocusScope.of(context).unfocus();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'measure_title'))),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            _exerciseHeader(),
            const SizedBox(height: 20),
            _profileRow(state),
            const SizedBox(height: 20),
            if (exercise.isPowerlift) ...[
              _methodToggle(),
              const SizedBox(height: 20),
            ],
            if (exercise.isBodyweight)
              _bodyweightInputs()
            else if (_mode == _MeasureMode.total)
              _totalInputs(state)
            else
              _weightedInputs(state),
            const SizedBox(height: 24),
            PrimaryButton(
              label: tr(context, 'calculate_strength'),
              icon: Icons.bolt_rounded,
              enabled: _canCalculate,
              onPressed: () => _calculate(state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _exerciseHeader() {
    return Row(
      children: [
        Hero(
          tag: 'glyph-${exercise.id}',
          child: ExerciseGlyph(exercise: exercise, size: 72, radius: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(exerciseName(context, exercise),
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(
                exercise.isBodyweight
                    ? tr(context, 'rated_by_reps')
                    : '${equipmentLabel(context, exercise.equipment)} · '
                        '${tr(context, 'lift_over_bw')}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _profileRow(AppState state) {
    final p = state.profile;
    return GestureDetector(
      onTap: () => ProfileSheet.show(context),
      child: SectionCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            const Icon(Icons.person_rounded, color: AppColors.accent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${sexLabel(context, p.sex)}  ·  '
                '${p.bodyweightInUnit.toStringAsFixed(0)} ${p.unit.symbol}'
                '${p.age != null ? '  ·  ${p.age} ${tr(context, 'years_short')}' : ''}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(tr(context, 'edit'),
                style: const TextStyle(color: AppColors.accent, fontSize: 13)),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _methodToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(tr(context, 'measure_how')),
        SegmentedSelector<_MeasureMode>(
          options: _MeasureMode.values,
          selected: _mode,
          labelOf: (m) => m == _MeasureMode.single
              ? tr(context, 'single_lift')
              : tr(context, 'total_wilks'),
          onChanged: (m) => setState(() => _mode = m),
        ),
      ],
    );
  }

  Widget _weightedInputs(AppState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(tr(context, 'your_best_set')),
        Row(
          children: [
            Expanded(
              child: _NumberField(
                controller: _weight,
                label: '${tr(context, 'weight')} (${state.unit.symbol})',
                hint: '100',
                decimal: true,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _NumberField(
                controller: _reps,
                label: tr(context, 'reps'),
                hint: '5',
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        if (int.tryParse(_reps.text) != null &&
            OneRepMax.isLowConfidence(int.parse(_reps.text)))
          _hint(trp(context, 'high_reps_hint', {'n': kReliableRepCeiling})),
      ],
    );
  }

  Widget _totalInputs(AppState state) {
    final u = state.unit.symbol;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(tr(context, 'best_single_each')),
        _NumberField(
          controller: _squat,
          label: '${tr(context, 'squat')} ($u)',
          hint: '180',
          decimal: true,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        _NumberField(
          controller: _bench,
          label: '${tr(context, 'bench')} ($u)',
          hint: '120',
          decimal: true,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        _NumberField(
          controller: _deadlift,
          label: '${tr(context, 'deadlift')} ($u)',
          hint: '220',
          decimal: true,
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _bodyweightInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(tr(context, 'how_many_reps')),
        _NumberField(
          controller: _reps,
          label: tr(context, 'max_reps'),
          hint: '12',
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 2),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  Widget _hint(String text) => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline_rounded,
                size: 16, color: AppColors.accent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(text,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
            ),
          ],
        ),
      );
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.onChanged,
    this.decimal = false,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool decimal;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 2),
          child: Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType:
              TextInputType.numberWithOptions(decimal: decimal),
          inputFormatters: [
            decimal
                ? FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))
                : FilteringTextInputFormatter.digitsOnly,
          ],
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}
