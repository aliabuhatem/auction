import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app_router.dart';
import 'app_theme.dart';
import '../injection_container.dart' as di;

// FIX: import auth_bloc from the correct path so AuthBloc resolves as a type
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_event.dart';

class AuctionApp extends StatelessWidget {
  const AuctionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // FIX: AuthBloc is now properly imported, so it resolves as a type
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>()..add(AppStarted()),
        ),
      ],
      child: const _AppView(),
    );
  }
}

class _AppView extends StatefulWidget {
  const _AppView();
  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() => setState(() {
        _themeMode =
            _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
      });

  @override
  Widget build(BuildContext context) {
    return ThemeModeNotifier(
      themeMode:   _themeMode,
      toggleTheme: _toggleTheme,
      child: MaterialApp.router(
        title:                      'Vakantieveilingen',
        debugShowCheckedModeBanner: false,
        routerConfig:               appRouter,
        theme:                      AppTheme.lightTheme,
        darkTheme:                  AppTheme.darkTheme,
        themeMode:                  _themeMode,
        locale: const Locale('nl', 'NL'),
        supportedLocales: const [
          Locale('nl', 'NL'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        scrollBehavior: const _NoGlowScrollBehaviour(),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(
                MediaQuery.of(context).textScaler.scale(1.0).clamp(0.85, 1.15),
              ),
            ),
            child: child!,
          );
        },
      ),
    );
  }
}

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

class _NoGlowScrollBehaviour extends ScrollBehavior {
  const _NoGlowScrollBehaviour();
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) =>
      child;
}
