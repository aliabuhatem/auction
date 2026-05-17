import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Events
abstract class LocaleEvent extends Equatable {
  const LocaleEvent();
  @override List<Object?> get props => [];
}
class ChangeLocale extends LocaleEvent {
  final Locale locale;
  const ChangeLocale(this.locale);
  @override List<Object?> get props => [locale];
}

// State
class LocaleState extends Equatable {
  final Locale locale;
  const LocaleState(this.locale);
  @override List<Object?> get props => [locale];
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
