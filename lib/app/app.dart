// lib/app/app.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_router.dart';
import 'app_theme.dart';
import '../injection_container.dart' as di;

import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_event.dart';
import '../features/auctions/presentation/bloc/auction_list_bloc.dart';
import '../features/my_auctions/presentation/bloc/my_auctions_bloc.dart';
import '../features/profile/presentation/bloc/locale_bloc.dart';

class AuctionApp extends StatelessWidget {
  final ThemeMode initialTheme;
  const AuctionApp({super.key, this.initialTheme = ThemeMode.light});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>()..add(AppStarted()),
        ),
        BlocProvider<AuctionListBloc>(
          create: (_) => di.sl<AuctionListBloc>(),
        ),
        BlocProvider<MyAuctionsBloc>(
          create: (_) => di.sl<MyAuctionsBloc>(),
        ),
        BlocProvider<LocaleBloc>(
          create: (_) => di.sl<LocaleBloc>(),
        ),
      ],
      child: _AppView(initialTheme: initialTheme),
    );
  }
}

class _AppView extends StatefulWidget {
  final ThemeMode initialTheme;
  const _AppView({required this.initialTheme});
  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> {
  late ThemeMode _themeMode;

  static const _prefKey = 'dark_mode';

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialTheme;
  }

  void _toggleTheme() {
    final next = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    setState(() => _themeMode = next);
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setBool(_prefKey, next == ThemeMode.dark),
    );
    if (!kIsWeb) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor:                    Colors.transparent,
        statusBarIconBrightness:           next == ThemeMode.dark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor:          next == ThemeMode.dark ? const Color(0xFF101624) : Colors.white,
        systemNavigationBarIconBrightness: next == ThemeMode.dark ? Brightness.light : Brightness.dark,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemeModeNotifier(
      themeMode:   _themeMode,
      toggleTheme: _toggleTheme,
      child: BlocBuilder<LocaleBloc, LocaleState>(
        // Only rebuild when locale actually changes, not on every state.
        buildWhen: (prev, next) => prev.locale != next.locale,
        builder: (context, localeState) {
          return MaterialApp.router(
            title:                      'Vakantieveilingen',
            debugShowCheckedModeBanner: false,
            routerConfig:               appRouter,
            theme:                      AppTheme.lightTheme,
            darkTheme:                  AppTheme.darkTheme,
            themeMode:                  _themeMode,
            locale:                     localeState.locale,
            supportedLocales: const [
              Locale('nl', 'NL'),
              Locale('en', 'US'),
              Locale('ar', 'SA'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            // Use the correct scroll behaviour for each platform.
            // On web: enable mouse-drag scrolling + thin styled scrollbar.
            // On mobile: remove the overscroll glow (original behaviour).
            scrollBehavior: kIsWeb
                ? const _WebScrollBehavior()
                : const _MobileScrollBehavior(),
            builder: (context, child) {
              return Directionality(
                textDirection: localeState.locale.languageCode == 'ar'
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(
                      MediaQuery.of(context)
                          .textScaler
                          .scale(1.0)
                          .clamp(0.85, 1.15),
                    ),
                  ),
                  child: child!,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ── Scroll behaviours ─────────────────────────────────────────────────────────

/// Desktop web: enable mouse-drag scrolling, styled thin scrollbar.
class _WebScrollBehavior extends MaterialScrollBehavior {
  const _WebScrollBehavior();

  // Without this override, mouse drag does not scroll on web.
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };

  @override
  Widget buildScrollbar(
      BuildContext context, Widget child, ScrollableDetails details) {
    return Scrollbar(
      controller:      details.controller,
      thumbVisibility: false, // only visible while scrolling
      thickness:       5,
      radius:          const Radius.circular(3),
      child:           child,
    );
  }

  @override
  Widget buildOverscrollIndicator(
          BuildContext context, Widget child, ScrollableDetails details) =>
      child;
}

/// Mobile: just remove the glow indicator.
class _MobileScrollBehavior extends ScrollBehavior {
  const _MobileScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
          BuildContext context, Widget child, ScrollableDetails details) =>
      child;
}

// ── Theme mode notifier ───────────────────────────────────────────────────────

class ThemeModeNotifier extends InheritedWidget {
  final ThemeMode    themeMode;
  final VoidCallback toggleTheme;

  const ThemeModeNotifier({
    super.key,
    required this.themeMode,
    required this.toggleTheme,
    required super.child,
  });

  static ThemeModeNotifier? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ThemeModeNotifier>();

  @override
  bool updateShouldNotify(ThemeModeNotifier old) =>
      old.themeMode != themeMode;
}
