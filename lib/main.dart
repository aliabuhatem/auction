// lib/main.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'injection_container.dart' as di;
import 'firebase_options.dart';
import 'features/notifications/notification_service.dart';

void _applySystemUi({required bool isDark}) {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor:                    Colors.transparent,
    statusBarIconBrightness:           isDark ? Brightness.light : Brightness.dark,
    systemNavigationBarColor:          isDark ? const Color(0xFF101624) : Colors.white,
    systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
  ));
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Image cache ───────────────────────────────────────────────────────────
  PaintingBinding.instance.imageCache.maximumSize      = 80;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 50 * 1024 * 1024;

  // ── Portrait lock (mobile only) ───────────────────────────────────────────
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // Nav bar color is updated again in app.dart when theme toggles.
    _applySystemUi(isDark: false);
  }

  // ── Firebase ──────────────────────────────────────────────────────────────
  // Wrap in try/catch — if Firebase fails to init (no network on first cold
  // start before local cache is seeded) we show the app anyway; the router
  // will keep the user on the splash/login screen until retry succeeds.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init failed: $e');
    // App continues — FirebaseApp will be unavailable, error surfaces per-feature.
  }

  // ── Dependency injection ──────────────────────────────────────────────────
  await di.init();

  // Read persisted dark-mode preference synchronously (prefs already loaded).
  final isDark = di.sl<SharedPreferences>().getBool('dark_mode') ?? false;

  // Apply correct system UI for the persisted theme before first frame.
  if (!kIsWeb) _applySystemUi(isDark: isDark);

  runApp(AuctionApp(initialTheme: isDark ? ThemeMode.dark : ThemeMode.light));

  // ── Notification service ──────────────────────────────────────────────────
  // Deferred so the first frame paints before FCM token negotiation begins.
  // FCM + local notifications don't need to be ready before the UI appears.
  di.sl<NotificationService>().initialize().catchError(
    (e) => debugPrint('NotificationService init error: $e'),
  );
}
