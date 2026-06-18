import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../../core/auth/auth_service.dart';
import '../../l10n/app_strings.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_widgets.dart';

/// Account creation / sign-in gate. Offers email-password, Google, and a guest
/// fallback (the only path that works before Firebase is configured).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _createMode = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit(AuthService auth) async {
    final email = _email.text.trim();
    final pw = _password.text;
    if (!email.contains('@') || email.length < 5) {
      setState(() => _error = tr(context, 'err_email_required'));
      return;
    }
    if (pw.length < 6) {
      setState(() => _error = tr(context, 'err_password_short'));
      return;
    }
    await _run(() =>
        _createMode ? auth.signUpEmail(email, pw) : auth.signInEmail(email, pw));
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      // On success the AuthService stream updates and _Root swaps screens.
    } on AuthNotConfigured {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr(context, 'auth_not_configured'))),
      );
      context.read<AuthService>().continueAsGuest();
    } on GoogleSignInException catch (e) {
      // A user-cancelled Google prompt isn't an error worth showing.
      if (e.code != GoogleSignInExceptionCode.canceled && mounted) {
        setState(() => _error = tr(context, 'err_generic_auth'));
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _error = _mapFirebaseError(e));
    } catch (_) {
      if (mounted) setState(() => _error = tr(context, 'err_generic_auth'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return tr(context, 'err_email_required');
      case 'weak-password':
        return tr(context, 'err_password_short');
      default:
        return tr(context, 'err_generic_auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _brand(context),
                const SizedBox(height: 28),
                Text(tr(context, 'welcome'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 6),
                Text(
                  tr(context, 'login_subtitle'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 24),
                _field(
                  controller: _email,
                  label: tr(context, 'email'),
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),
                _field(
                  controller: _password,
                  label: tr(context, 'password'),
                  hint: '••••••',
                  obscure: true,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    _error!,
                    style: const TextStyle(
                        color: Color(0xFFFF6B6B), fontSize: 13),
                  ),
                ],
                const SizedBox(height: 22),
                PrimaryButton(
                  label: _busy
                      ? '…'
                      : tr(context,
                          _createMode ? 'create_account' : 'sign_in'),
                  icon: Icons.arrow_forward_rounded,
                  enabled: !_busy,
                  onPressed: () => _submit(auth),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _busy
                      ? null
                      : () => setState(() => _createMode = !_createMode),
                  child: Text(
                    tr(context,
                        _createMode ? 'toggle_to_sign_in' : 'toggle_to_create'),
                    style: const TextStyle(color: AppColors.accent),
                  ),
                ),
                const SizedBox(height: 8),
                _orDivider(context),
                const SizedBox(height: 16),
                _GoogleButton(
                  label: tr(context, 'continue_google'),
                  onPressed:
                      _busy ? null : () => _run(() => auth.signInGoogle()),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _busy ? null : auth.continueAsGuest,
                  child: Text(
                    tr(context, 'continue_guest'),
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _brand(BuildContext context) {
    return Center(
      child: Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          gradient: AppColors.brandGradient,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.4),
              blurRadius: 26,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Icon(Icons.fitness_center_rounded,
            color: Colors.white, size: 42),
      ),
    );
  }

  Widget _orDivider(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.stroke)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(tr(context, 'or'),
              style: const TextStyle(color: AppColors.textSecondary)),
        ),
        const Expanded(child: Divider(color: AppColors.stroke)),
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
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
          obscureText: obscure,
          keyboardType: keyboardType,
          autocorrect: false,
          enableSuggestions: !obscure,
          style: const TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}

/// White, outlined "Continue with Google" button.
class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.stroke),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _GoogleGlyph(size: 20),
              const SizedBox(width: 12),
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Minimal multi-colour "G" mark drawn with text so we ship no image asset.
class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Text(
        'G',
        style: TextStyle(
          fontSize: size * 0.72,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF4285F4),
          height: 1,
        ),
      ),
    );
  }
}
