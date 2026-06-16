import 'package:flutter/material.dart';

import '../core/models/exercise.dart';

/// Centralised palette for the dark, modern Metal Strength look.
class AppColors {
  const AppColors._();

  static const Color background = Color(0xFF0B0E14);
  static const Color surface = Color(0xFF161B26);
  static const Color surfaceAlt = Color(0xFF1E2533);
  static const Color stroke = Color(0xFF2A3242);

  static const Color textPrimary = Color(0xFFEAF2FF);
  static const Color textSecondary = Color(0xFF8A94A6);

  static const Color accent = Color(0xFF3D9BE9);
  static const Color accent2 = Color(0xFF9B6DFF);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accent2],
  );

  /// A distinct gradient per equipment type for the exercise cards.
  static LinearGradient equipmentGradient(Equipment equipment) {
    switch (equipment) {
      case Equipment.barbell:
        return const LinearGradient(
          colors: [Color(0xFF3D9BE9), Color(0xFF2A6FD6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case Equipment.dumbbell:
        return const LinearGradient(
          colors: [Color(0xFF9B6DFF), Color(0xFF6C4BD6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case Equipment.machine:
        return const LinearGradient(
          colors: [Color(0xFF4FB477), Color(0xFF2F8C57)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case Equipment.cable:
        return const LinearGradient(
          colors: [Color(0xFFFF9F43), Color(0xFFE07B2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case Equipment.bodyweight:
        return const LinearGradient(
          colors: [Color(0xFFEC5C7D), Color(0xFFC23E5E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }
}
