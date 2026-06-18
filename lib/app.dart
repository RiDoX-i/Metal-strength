import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import 'core/auth/auth_service.dart';
import 'features/auth/login_screen.dart';
import 'features/home/landing_screen.dart';
import 'state/app_state.dart';
import 'state/history_service.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

class MetalStrengthApp extends StatelessWidget {
  const MetalStrengthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()..init()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => HistoryService()..init()),
      ],
      child: Builder(
        builder: (context) {
          // Rebuild MaterialApp when the language changes.
          final locale = context.select<AppState, Locale>((s) => s.locale);
          return MaterialApp(
            title: 'Metal Strength',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dark,
            locale: locale,
            supportedLocales: AppState.supportedLocales,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const _Root(),
          );
        },
      ),
    );
  }
}

/// Plays the MAGNETIC FORCE company logo video on launch, then (once the
/// catalog/profile have loaded) shows the auth gate: login if not authenticated,
/// otherwise the landing screen.
class _Root extends StatefulWidget {
  const _Root();

  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  /// Hard cap so a video that fails to load or runs long can never trap the
  /// user on the splash.
  static const Duration _maxSplash = Duration(seconds: 8);

  bool _introDone = false;
  Timer? _safety;

  @override
  void initState() {
    super.initState();
    _safety = Timer(_maxSplash, _finishIntro);
  }

  @override
  void dispose() {
    _safety?.cancel();
    super.dispose();
  }

  void _finishIntro() {
    if (!_introDone && mounted) setState(() => _introDone = true);
  }

  @override
  Widget build(BuildContext context) {
    final ready = context.select<AppState, bool>((s) => s.ready);
    final authed = context.select<AuthService, bool>((a) => a.isAuthenticated);

    final Widget child;
    if (!ready || !_introDone) {
      child = _Splash(onComplete: _finishIntro);
    } else if (!authed) {
      child = const LoginScreen();
    } else {
      child = const LandingScreen();
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      child: child,
    );
  }
}

/// Full-screen launch splash. Plays the company logo clip once and signals
/// [onComplete] when it finishes; if the video can't be played it falls back to
/// the gradient MAGNETIC FORCE wordmark and still signals so the app proceeds.
class _Splash extends StatefulWidget {
  const _Splash({required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<_Splash> createState() => _SplashState();
}

class _SplashState extends State<_Splash> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _signalled = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    final c = VideoPlayerController.asset('assets/video/logo_intro.mp4');
    _controller = c;
    try {
      await c.initialize();
      await c.setVolume(0); // silent splash — no surprise audio on launch
      await c.setLooping(false);
      c.addListener(_onTick);
      if (!mounted) {
        await c.dispose();
        return;
      }
      setState(() => _initialized = true);
      await c.play();
    } catch (_) {
      // Video unavailable on this platform — show the wordmark fallback and let
      // the parent advance (safety timer also covers this).
      _signalDone();
    }
  }

  void _onTick() {
    final c = _controller;
    if (c == null) return;
    final v = c.value;
    final ended = v.isInitialized &&
        (v.isCompleted ||
            (v.duration > Duration.zero && v.position >= v.duration));
    if (ended) _signalDone();
  }

  void _signalDone() {
    if (_signalled) return;
    _signalled = true;
    widget.onComplete();
  }

  @override
  void dispose() {
    _controller?.removeListener(_onTick);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: _initialized && c != null
            ? AspectRatio(
                aspectRatio: c.value.aspectRatio,
                child: VideoPlayer(c),
              )
            : const _BrandFallback(),
      ),
    );
  }
}

/// Static brand mark shown while the video initializes or if it can't play.
class _BrandFallback extends StatelessWidget {
  const _BrandFallback();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 104,
          height: 104,
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.45),
                blurRadius: 36,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 56),
        ),
        const SizedBox(height: 28),
        ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.brandGradient.createShader(bounds),
          child: const Text(
            'MAGNETIC FORCE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Metal Strength',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 30),
        const SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ],
    );
  }
}
