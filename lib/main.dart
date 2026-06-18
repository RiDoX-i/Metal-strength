import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase only if the project has been configured (see SETUP.md).
  // Until `flutterfire configure` is run, DefaultFirebaseOptions throws — we
  // swallow it here so the app boots in guest mode instead of crashing.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // Firebase not configured yet — authentication runs in guest mode.
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0B0E14),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MetalStrengthApp());
}
