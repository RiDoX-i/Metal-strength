import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/auth/auth_service.dart';
import '../../core/config.dart';
import '../../core/models/user_profile.dart';
import '../../l10n/app_strings.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_widgets.dart';
import '../history/history_screen.dart';
import '../info/strength_info_screen.dart';
import '../profile/profile_sheet.dart';
import 'catalog_screen.dart';

/// First screen after login: brand hero + a button into the catalog, with a
/// small donation button and a language switch pinned to the bottom.
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  void _openCatalog(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CatalogScreen()),
    );
  }

  void _openHistory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HistoryScreen()),
    );
  }

  void _openInfo(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const StrengthInfoScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final auth = context.watch<AuthService>();
    final p = state.profile;
    final who = auth.displayName.isEmpty ? tr(context, 'guest') : auth.displayName;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top bar: who's signed in + sign out.
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      trp(context, 'signed_in_as', {'who': who}),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12.5),
                    ),
                  ),
                  IconButton(
                    tooltip: tr(context, 'sign_out'),
                    icon: const Icon(Icons.logout_rounded,
                        color: AppColors.textSecondary, size: 20),
                    onPressed: auth.signOut,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _hero(context),
                      const SizedBox(height: 22),
                      Text('Metal Strength',
                          style: Theme.of(context).textTheme.displayLarge),
                      const SizedBox(height: 8),
                      Text(
                        tr(context, 'app_tagline'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 14),
                      ),
                      const SizedBox(height: 26),
                      _profileSummary(context, state, p),
                      const SizedBox(height: 18),
                      PrimaryButton(
                        label: tr(context, 'browse_exercises'),
                        icon: Icons.fitness_center_rounded,
                        onPressed: () => _openCatalog(context),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tr(context, 'browse_subtitle'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12.5),
                      ),
                      const SizedBox(height: 14),
                      SecondaryButton(
                        label: tr(context, 'progress'),
                        icon: Icons.timeline_rounded,
                        onPressed: () => _openHistory(context),
                      ),
                      const SizedBox(height: 10),
                      TextButton.icon(
                        onPressed: () => _openInfo(context),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        icon: const Icon(Icons.help_outline_rounded, size: 18),
                        label: Text(
                          tr(context, 'info_button'),
                          style: const TextStyle(fontSize: 13.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom: language switch + small donation button.
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _LanguageButton(),
                  const SizedBox(height: 10),
                  _DonationButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hero(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.4),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: const Icon(Icons.fitness_center_rounded,
          color: Colors.white, size: 52),
    );
  }

  Widget _profileSummary(BuildContext context, AppState state, UserProfile p) {
    return GestureDetector(
      onTap: () => ProfileSheet.show(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.stroke),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_rounded, size: 18, color: AppColors.accent),
            const SizedBox(width: 10),
            Text(
              '${sexLabel(context, p.sex)}  ·  '
              '${p.bodyweightInUnit.toStringAsFixed(0)} ${p.unit.symbol}'
              '${p.age != null ? '  ·  ${p.age} ${tr(context, 'years_short')}' : ''}',
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.edit_rounded,
                size: 15, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

/// Endonym for each shipped language, shown in the language picker (language
/// names are conventionally written in their own language, not translated).
const Map<String, String> _languageNames = {
  'en': 'English',
  'fr': 'Français',
  'es': 'Español',
  'de': 'Deutsch',
  'pt': 'Português',
};

/// Opens a small sheet to pick the UI language.
class _LanguageButton extends StatelessWidget {
  void _pick(BuildContext context) {
    final state = context.read<AppState>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.stroke,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 8),
              for (final entry in _languageNames.entries)
                _langTile(
                    sheetContext, state, Locale(entry.key), entry.value),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _langTile(
      BuildContext context, AppState state, Locale locale, String label) {
    final selected = state.locale.languageCode == locale.languageCode;
    return ListTile(
      leading: Icon(
        selected ? Icons.radio_button_checked_rounded : Icons.language_rounded,
        color: selected ? AppColors.accent : AppColors.textSecondary,
      ),
      title: Text(label,
          style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
      onTap: () {
        state.setLocale(locale);
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final code = context.watch<AppState>().locale.languageCode;
    final current = _languageNames[code] ?? 'English';
    return OutlinedButton.icon(
      onPressed: () => _pick(context),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(46),
        side: const BorderSide(color: AppColors.stroke),
        foregroundColor: AppColors.textPrimary,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      icon: const Icon(Icons.language_rounded, size: 18),
      label: Text('${tr(context, 'language')} · $current'),
    );
  }
}

/// Small "Support the app" button that opens the configured donation link.
class _DonationButton extends StatelessWidget {
  Future<void> _open(BuildContext context) async {
    final uri = Uri.tryParse(AppConfig.donationUrl);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // No browser / bad URL — silently ignore.
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _open(context),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      icon: const Icon(Icons.favorite_rounded,
          size: 16, color: Color(0xFFEC5C7D)),
      label: Text(tr(context, 'support_app'),
          style: const TextStyle(fontSize: 13)),
    );
  }
}
