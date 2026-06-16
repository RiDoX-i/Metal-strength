import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/formulas/units.dart';
import '../../core/models/sex.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_widgets.dart';

/// Bottom sheet to edit the lifter profile. Reads/writes [AppState].
class ProfileSheet extends StatefulWidget {
  const ProfileSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const ProfileSheet(),
    );
  }

  @override
  State<ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends State<ProfileSheet> {
  late final TextEditingController _bodyweight;
  late final TextEditingController _age;

  @override
  void initState() {
    super.initState();
    final p = context.read<AppState>().profile;
    _bodyweight = TextEditingController(
      text: _trim(p.bodyweightInUnit),
    );
    _age = TextEditingController(text: p.age?.toString() ?? '');
  }

  String _trim(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  @override
  void dispose() {
    _bodyweight.dispose();
    _age.dispose();
    super.dispose();
  }

  void _saveBodyweight(AppState state) {
    final raw = double.tryParse(_bodyweight.text.replaceAll(',', '.'));
    if (raw != null && raw > 0) {
      state.setBodyweightKg(Units.toKg(raw, state.unit));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final profile = state.profile;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.stroke,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text('Your profile',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          const Text(
            'Used to compare your lifts against population standards.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 20),
          _label('Sex'),
          SegmentedSelector<Sex>(
            options: Sex.values,
            selected: profile.sex,
            labelOf: (s) => s.label,
            onChanged: state.setSex,
          ),
          const SizedBox(height: 18),
          _label('Units'),
          SegmentedSelector<WeightUnit>(
            options: WeightUnit.values,
            selected: profile.unit,
            labelOf: (u) => u.symbol.toUpperCase(),
            onChanged: (u) {
              state.setUnit(u);
              // Re-render the bodyweight field in the new unit.
              _bodyweight.text = _trim(Units.fromKg(profile.bodyweightKg, u));
            },
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Bodyweight (${profile.unit.symbol})'),
                    TextField(
                      controller: _bodyweight,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      onChanged: (_) => _saveBodyweight(state),
                      decoration: const InputDecoration(hintText: '80'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Age (optional)'),
                    TextField(
                      controller: _age,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (v) =>
                          state.setAge(v.isEmpty ? null : int.tryParse(v)),
                      decoration: const InputDecoration(hintText: '—'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Done',
            icon: Icons.check_rounded,
            onPressed: () {
              _saveBodyweight(state);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 2),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}
