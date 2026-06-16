import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/models/exercise.dart';
import '../theme/app_colors.dart';

/// A rounded tile showing an exercise's non-human vector illustration on its
/// equipment-coloured gradient.
class ExerciseGlyph extends StatelessWidget {
  const ExerciseGlyph({
    super.key,
    required this.exercise,
    this.size = 56,
    this.radius = 16,
    this.padding = 12,
  });

  final Exercise exercise;
  final double size;
  final double radius;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.equipmentGradient(exercise.equipment),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: AppColors.equipmentGradient(exercise.equipment)
                .colors
                .first
                .withOpacity(0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.all(padding),
      child: SvgPicture.asset(
        exercise.imageAsset,
        fit: BoxFit.contain,
        placeholderBuilder: (_) => const SizedBox.shrink(),
      ),
    );
  }
}
