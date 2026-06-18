import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/exercise.dart';
import '../../l10n/app_strings.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../measure/measure_screen.dart';
import '../profile/profile_sheet.dart';
import 'widgets/exercise_card.dart';

/// The catalog / exercise-selection screen (reached from the landing screen).
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TextEditingController _search = TextEditingController();
  Equipment? _filter; // null == All
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Exercise> _visible(AppState state) {
    var list = state.exercises;
    if (_filter != null) {
      list = list.where((e) => e.equipment == _filter).toList();
    }
    if (_query.trim().isNotEmpty) {
      list = list.where((e) => exerciseMatchesQuery(e, _query)).toList();
    }
    return list;
  }

  void _openExercise(Exercise exercise) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MeasureScreen(exercise: exercise)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final exercises = _visible(state);
    final p = state.profile;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr(context, 'browse_exercises')),
        actions: [
          _ProfileChip(
            label: '${sexLabel(context, p.sex)} · '
                '${p.bodyweightInUnit.toStringAsFixed(0)}${p.unit.symbol}',
            onTap: () => ProfileSheet.show(context),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _subtitle(context)),
            SliverToBoxAdapter(child: _searchField()),
            SliverToBoxAdapter(child: _categoryChips()),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            if (exercises.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(message: tr(context, 'empty_search')),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                sliver: SliverList.separated(
                  itemCount: exercises.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => ExerciseCard(
                    exercise: exercises[i],
                    onTap: () => _openExercise(exercises[i]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _subtitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
      child: Text(
        tr(context, 'catalog_subtitle'),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  Widget _searchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: TextField(
        controller: _search,
        onChanged: (v) => setState(() => _query = v),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: tr(context, 'search_hint'),
          prefixIcon:
              const Icon(Icons.search_rounded, color: AppColors.textSecondary),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.textSecondary),
                  onPressed: () {
                    _search.clear();
                    setState(() => _query = '');
                  },
                ),
        ),
      ),
    );
  }

  Widget _categoryChips() {
    final entries = <(String, Equipment?)>[
      (tr(context, 'filter_all'), null),
      for (final e in Equipment.values) (equipmentLabel(context, e), e),
    ];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: entries.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (label, value) = entries[i];
          final selected = _filter == value;
          return GestureDetector(
            onTap: () => setState(() => _filter = value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: selected ? AppColors.brandGradient : null,
                color: selected ? null : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? Colors.transparent : AppColors.stroke,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileChip extends StatelessWidget {
  const _ProfileChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.stroke),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_rounded,
                  size: 16, color: AppColors.accent),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.fitness_center_rounded,
                size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
