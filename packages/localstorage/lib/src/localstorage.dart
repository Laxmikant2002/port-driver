import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

/// Enhanced local storage with caching, offline support, and type safety
class Localstorage {
  const Localstorage(this.prefs);
  final SharedPreferences prefs;

  /// Save string value with error handling
  Future<bool> saveString(String key, String value) async {
    try {
      return await prefs.setString(key, value);
    } catch (e) {
      log('Error saving string for key $key: $e');
      return false;
    }
  }

  /// Save integer value
  Future<bool> saveInt(String key, int value) async {
    try {
      return await prefs.setInt(key, value);
    } catch (e) {
      log('Error saving int for key $key: $e');
      return false;
    }
  }

  /// Save boolean value
  Future<bool> saveBool(String key, bool value) async {
    try {
      return await prefs.setBool(key, value);
    } catch (e) {
      log('Error saving bool for key $key: $e');
      return false;
    }
  }

  /// Save double value
  Future<bool> saveDouble(String key, double value) async {
    try {
      return await prefs.setDouble(key, value);
    } catch (e) {
      log('Error saving double for key $key: $e');
      return false;
    }
  }

  /// Save list of strings
  Future<bool> saveStringList(String key, List<String> value) async {
    try {
      return await prefs.setStringList(key, value);
    } catch (e) {
      log('Error saving string list for key $key: $e');
      return false;
    }
  }

  /// Save JSON object
  Future<bool> saveJson(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = jsonEncode(value);
      return await prefs.setString(key, jsonString);
    } catch (e) {
      log('Error saving JSON for key $key: $e');
      return false;
    }
  }

  /// Get string value
  String? getString(String key) {
    try {
      return prefs.getString(key);
    } catch (e) {
      log('Error getting string for key $key: $e');
      return null;
    }
  }

  /// Get integer value
  int? getInt(String key) {
    try {
      return prefs.getInt(key);
    } catch (e) {
      log('Error getting int for key $key: $e');
      return null;
    }
  }

  /// Get boolean value
  bool? getBool(String key) {
    try {
      return prefs.getBool(key);
    } catch (e) {
      log('Error getting bool for key $key: $e');
      return null;
    }
  }

  /// Get double value
  double? getDouble(String key) {
    try {
      return prefs.getDouble(key);
    } catch (e) {
      log('Error getting double for key $key: $e');
      return null;
    }
  }

  /// Get list of strings
  List<String>? getStringList(String key) {
    try {
      return prefs.getStringList(key);
    } catch (e) {
      log('Error getting string list for key $key: $e');
      return null;
    }
  }

  /// Get JSON object
  Map<String, dynamic>? getJson(String key) {
    try {
      final jsonString = prefs.getString(key);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      log('Error getting JSON for key $key: $e');
      return null;
    }
  }

  /// Check if key exists
  bool containsKey(String key) {
    return prefs.containsKey(key);
  }

  /// Get all keys
  Set<String> getKeys() {
    return prefs.getKeys();
  }

  /// Remove specific key
  Future<bool> remove(String key) async {
    try {
      return await prefs.remove(key);
    } catch (e) {
      log('Error removing key $key: $e');
      return false;
    }
  }

  /// Clear all data
  Future<bool> clear() async {
    try {
      return await prefs.clear();
    } catch (e) {
      log('Error clearing storage: $e');
      return false;
    }
  }

  /// Get storage size (approximate)
  int getSize() {
    return prefs.getKeys().length;
  }

  /// Check if storage is empty
  bool get isEmpty => prefs.getKeys().isEmpty;

  /// Check if storage is not empty
  bool get isNotEmpty => prefs.getKeys().isNotEmpty;

  // Legacy methods for backward compatibility
  @Deprecated('Use remove instead')
  void deleteString(String key) {
    prefs.remove(key);
  }
}