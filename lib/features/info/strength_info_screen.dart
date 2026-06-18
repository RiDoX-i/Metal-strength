import 'package:flutter/material.dart';

import '../../core/formulas/tiers.dart';
import '../../l10n/app_strings.dart';
import '../../theme/app_colors.dart';

/// A plain-language walkthrough of how the app turns a lift into a strength
/// level: 1RM estimate → bodyweight ratio → tier → percentile, plus the age
/// adjustment, bodyweight-exercise scoring and the powerlifting total.
class StrengthInfoScreen extends StatelessWidget {
  const StrengthInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'info_title'))),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            _hero(context),
            const SizedBox(height: 18),
            Text(
              tr(context, 'info_intro'),
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 20),
            _StepCard(
              icon: Icons.calculate_rounded,
              title: tr(context, 'info_step1_title'),
              body: tr(context, 'info_step1_body'),
              formula: tr(context, 'info_formula_1rm'),
            ),
            _StepCard(
              icon: Icons.balance_rounded,
              title: tr(context, 'info_step2_title'),
              body: tr(context, 'info_step2_body'),
            ),
            _StepCard(
              icon: Icons.military_tech_rounded,
              title: tr(context, 'info_step3_title'),
              body: tr(context, 'info_step3_body'),
              child: _tierLadder(context),
            ),
            _StepCard(
              icon: Icons.leaderboard_rounded,
              title: tr(context, 'info_step4_title'),
              body: tr(context, 'info_step4_body'),
            ),
            const SizedBox(height: 4),
            _StepCard(
              icon: Icons.cake_rounded,
              title: tr(context, 'info_age_title'),
              body: tr(context, 'info_age_body'),
            ),
            _StepCard(
              icon: Icons.accessibility_new_rounded,
              title: tr(context, 'info_bw_title'),
              body: tr(context, 'info_bw_body'),
            ),
            _StepCard(
              icon: Icons.emoji_events_rounded,
              title: tr(context, 'info_total_title'),
              body: tr(context, 'info_total_body'),
            ),
            const SizedBox(height: 4),
            _disclaimer(context),
          ],
        ),
      ),
    );
  }

  Widget _hero(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.insights_rounded, color: Colors.white, size: 32),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            tr(context, 'info_title'),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ],
    );
  }

  /// A compact, coloured tier ladder mirroring the result screen so the five
  /// levels named in step 3 are visible at a glance.
  Widget _tierLadder(BuildContext context) {
    return Row(
      children: [
        for (final tier in StrengthTier.ordered)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Color(tier.colorValue),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tierLabel(context, tier),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9.5,
                      color: Color(tier.colorValue),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _disclaimer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tr(context, 'info_disclaimer'),
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12.5, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

/// One explanatory section: an accent icon + title, a body paragraph, and an
/// optional formula chip or extra child (e.g. the tier ladder).
class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.icon,
    required this.title,
    required this.body,
    this.formula,
    this.child,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? formula;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.accent, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 13.5, height: 1.45),
          ),
          if (formula != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.stroke),
              ),
              child: Text(
                formula!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
          if (child != null) ...[
            const SizedBox(height: 14),
            child!,
          ],
        ],
      ),
    );
  }
}
