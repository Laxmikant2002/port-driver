import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

class Localstorage {
  const Localstorage(this.prefs);
  final SharedPreferences prefs;

  void saveString(String key, String value) {
    try {
      prefs.setString(key, value);
    } catch (e) {
      log(e.toString());
    }
  }

  void deleteString(String key) {
    prefs.remove(key);
  }

  String? getString(String key) {
    return prefs.getString(key);
  }

  void clear() {
    prefs.clear();
  }
}