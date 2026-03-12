import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Events
abstract class LocaleEvent {}
class ChangeLocale extends LocaleEvent {
  final Locale locale;
  ChangeLocale(this.locale);
}

// State
class LocaleState {
  final Locale locale;
  LocaleState(this.locale);
}

// Bloc
class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  final SharedPreferences prefs;

  LocaleBloc(this.prefs) : super(LocaleState(Locale(prefs.getString('language_code') ?? 'nl'))) {
    on<ChangeLocale>((event, emit) async {
      await prefs.setString('language_code', event.locale.languageCode);
      emit(LocaleState(event.locale));
    });
  }
}
