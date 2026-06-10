// Smoke tests for the app's localization system (AppStrings).
//
// Replaces the default counter boilerplate (which referenced a counter UI this
// app never had). These tests verify that strings resolve per-locale and that
// the Dutch plural handling no longer leaks the literal "{s}" placeholder.

import 'package:auction/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps a minimal localized app and hands the descendant [BuildContext] back
/// to [onContext] so AppStrings can be resolved against [locale].
Future<void> _withLocale(
  WidgetTester tester,
  Locale locale,
  void Function(BuildContext context) onContext,
) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: const [Locale('nl'), Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Builder(
        builder: (context) {
          onContext(context);
          return const SizedBox.shrink();
        },
      ),
    ),
  );
}

void main() {
  testWidgets('resolves strings per active locale', (tester) async {
    await _withLocale(tester, const Locale('nl'), (context) {
      expect(AppStrings.navAuctions(context), 'Veilingen');
    });
    await _withLocale(tester, const Locale('en'), (context) {
      expect(AppStrings.navAuctions(context), 'Auctions');
    });
    await _withLocale(tester, const Locale('ar'), (context) {
      expect(AppStrings.navAuctions(context), 'المزادات');
    });
  });

  testWidgets('falls back gracefully for an unsupported locale', (tester) async {
    await _withLocale(tester, const Locale('fr'), (context) {
      // No French map -> falls through to Dutch (the base language).
      expect(AppStrings.navHome(context), 'Home');
    });
  });

  testWidgets('Dutch daysAgo pluralizes without leaking {s}', (tester) async {
    await _withLocale(tester, const Locale('nl'), (context) {
      expect(AppStrings.daysAgo(context, 1), '1 dag geleden');
      expect(AppStrings.daysAgo(context, 3), '3 dagen geleden');
      // The placeholder must never survive into the rendered string.
      expect(AppStrings.daysAgo(context, 3).contains('{s}'), isFalse);
    });
  });
}
