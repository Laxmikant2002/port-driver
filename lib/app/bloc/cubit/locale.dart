import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

part 'locale_cubit_state.dart';

const englishLocale = Locale('en', 'US');
const spanishLocale = Locale('es', 'ES');

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(englishLocale) {
    // Load the saved locale when the cubit is created
    // _loadLocale();
  }
  // final Localstorage localstorage = GetIt.instance<Localstorage>();

  void selectEnglishLocale() {
    emit(englishLocale);
    // _saveLocale('en');
  }

  void selectSpanishUsLocale() {
    emit(spanishLocale);
    // _saveLocale('es');
  }
}
