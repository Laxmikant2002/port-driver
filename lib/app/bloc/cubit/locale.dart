import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

part 'locale_cubit_state.dart';

const englishLocale = Locale('en', 'US');
const hindiLocale = Locale('hi', 'IN');
const marathiLocale = Locale('mr', 'IN');

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

  void selectHindiLocale() {
    emit(hindiLocale);
    // _saveLocale('hi');
  }

  void selectMarathiLocale() {
    emit(marathiLocale);
    // _saveLocale('mr');
  }

  void selectLocale(String languageCode) {
    switch (languageCode) {
      case 'hi':
        selectHindiLocale();
        break;
      case 'mr':
        selectMarathiLocale();
        break;
      default:
        selectEnglishLocale();
        break;
    }
  }
}
