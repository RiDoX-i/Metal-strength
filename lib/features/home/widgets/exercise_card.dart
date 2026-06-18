import 'package:flutter/material.dart';

import '../../../core/models/exercise.dart';
import '../../../l10n/app_strings.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/exercise_glyph.dart';

/// A single tappable exercise row in the catalog.
class ExerciseCard extends StatelessWidget {
  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.onTap,
  });

  final Exercise exercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.stroke),
          ),
          child: Row(
            children: [
              Hero(
                tag: 'glyph-${exercise.id}',
                child: ExerciseGlyph(exercise: exercise),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exerciseName(context, exercise),
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _tag(equipmentLabel(context, exercise.equipment)),
                        if (exercise.isBodyweight) ...[
                          const SizedBox(width: 6),
                          _tag(tr(context, 'reps')),
                        ],
                        if (exercise.isPowerlift) ...[
                          const SizedBox(width: 6),
                          _tag('Wilks / DOTS'),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tag(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}
