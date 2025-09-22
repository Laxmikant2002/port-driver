import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'models/settings.dart';

/// Shared repository for managing shared data and settings
class SharedRepo {
  const SharedRepo({
    required this.baseUrl,
    required this.client,
    required this.localStorage,
  });

  final String baseUrl;
  final http.Client client;
  final Localstorage localStorage;

  /// Get settings
  Future<Settings?> getSettings() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/settings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return Settings.fromJson(json);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Update settings
  Future<bool> updateSettings(Settings settings) async {
    try {
      final response = await client.put(
        Uri.parse('$baseUrl/settings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode(settings.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get cached settings
  Future<Settings?> getCachedSettings() async {
    try {
      final cached = await localStorage.getItem('cached_settings');
      if (cached != null) {
        final json = jsonDecode(cached) as Map<String, dynamic>;
        return Settings.fromJson(json);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Cache settings
  Future<void> cacheSettings(Settings settings) async {
    try {
      await localStorage.setItem('cached_settings', jsonEncode(settings.toJson()));
    } catch (e) {
      // Handle error silently
    }
  }

  Future<String> _getAuthToken() async {
    try {
      final token = await localStorage.getItem('auth_token');
      return token ?? '';
    } catch (e) {
      return '';
    }
  }
}