import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app_router.dart';
import 'app_theme.dart';
import '../injection_container.dart' as di;

// Imports for Blocs
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_event.dart';
import '../features/auctions/presentation/bloc/auction_list_bloc.dart';
import '../features/profile/presentation/bloc/locale_bloc.dart';

class AuctionApp extends StatelessWidget {
  const AuctionApp({super.key});

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
        BlocProvider<LocaleBloc>(
          create: (_) => di.sl<LocaleBloc>(),
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
      child: BlocBuilder<LocaleBloc, LocaleState>(
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
            scrollBehavior: const _NoGlowScrollBehaviour(),
            builder: (context, child) {
              return Directionality(
                textDirection: localeState.locale.languageCode == 'ar' 
                    ? TextDirection.rtl 
                    : TextDirection.ltr,
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(
                      MediaQuery.of(context).textScaler.scale(1.0).clamp(0.85, 1.15),
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
