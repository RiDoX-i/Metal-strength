import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../config.dart';

/// Thrown by the auth methods when Firebase has not been configured yet
/// (no `flutterfire configure` run). The UI catches this to offer guest mode.
class AuthNotConfigured implements Exception {
  const AuthNotConfigured();
}

/// Wraps [FirebaseAuth] + Google sign-in and exposes a single source of truth
/// for "is the user allowed past the login gate?".
///
/// When Firebase is not configured (see [isConfigured]) every real auth call
/// throws [AuthNotConfigured]; the only way in is [continueAsGuest], so the app
/// remains fully usable before the client wires their Firebase project.
class AuthService extends ChangeNotifier {
  AuthService() {
    if (isConfigured) {
      _user = FirebaseAuth.instance.currentUser;
      _sub = FirebaseAuth.instance.authStateChanges().listen((user) {
        _user = user;
        notifyListeners();
      });
    }
  }

  StreamSubscription<User?>? _sub;
  User? _user;
  bool _guest = false;
  bool _googleInitialized = false;

  /// True once `Firebase.initializeApp` succeeded in `main()`.
  bool get isConfigured => Firebase.apps.isNotEmpty;

  User? get user => _user;

  /// Browsing without a real account.
  bool get isGuest => _guest && _user == null;

  /// Whether the user may pass the login gate.
  bool get isAuthenticated => _user != null || _guest;

  /// A human label for the current user, or empty for a guest (the UI then
  /// shows a localized "Guest").
  String get displayName {
    final u = _user;
    if (u != null) {
      if ((u.displayName ?? '').trim().isNotEmpty) return u.displayName!.trim();
      if ((u.email ?? '').trim().isNotEmpty) return u.email!.trim();
    }
    return '';
  }

  void continueAsGuest() {
    _guest = true;
    notifyListeners();
  }

  Future<void> signUpEmail(String email, String password) async {
    _ensureConfigured();
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signInEmail(String email, String password) async {
    _ensureConfigured();
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Interactive Google sign-in (google_sign_in v7 API).
  Future<void> signInGoogle() async {
    _ensureConfigured();
    final google = GoogleSignIn.instance;
    if (!_googleInitialized) {
      await google.initialize(
        serverClientId: AppConfig.googleServerClientId.isEmpty
            ? null
            : AppConfig.googleServerClientId,
      );
      _googleInitialized = true;
    }
    final account = await google.authenticate();
    final idToken = account.authentication.idToken;
    final credential = GoogleAuthProvider.credential(idToken: idToken);
    await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    _guest = false;
    if (isConfigured) {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {
        // Not signed in with Google / not initialized — ignore.
      }
      await FirebaseAuth.instance.signOut();
    }
    notifyListeners();
  }

  void _ensureConfigured() {
    if (!isConfigured) throw const AuthNotConfigured();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
