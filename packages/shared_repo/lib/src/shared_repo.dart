import 'dart:convert';
import 'dart:io';
import 'package:api_client/api_client.dart';
import 'package:localstorage/localstorage.dart';
import 'models/settings.dart';

/// Shared repository for managing shared data, enums, and common models
class SharedRepo {
  const SharedRepo({
    required this.apiClient,
    required this.localStorage,
  });

  final ApiClient apiClient;
  final Localstorage localStorage;

  /// Get app configuration
  Future<Map<String, dynamic>?> getAppConfig() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        SharedPaths.getAppConfig,
      );

      if (response is DataSuccess) {
        return response.data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Get feature flags
  Future<Map<String, bool>?> getFeatureFlags() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        SharedPaths.getFeatureFlags,
      );

      if (response is DataSuccess) {
        final flags = response.data!['flags'] as Map<String, dynamic>;
        return flags.map((key, value) => MapEntry(key, value as bool));
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Get trip states enum
  Future<List<String>?> getTripStates() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        SharedPaths.getTripStates,
      );

      if (response is DataSuccess) {
        return List<String>.from(response.data!['states'] ?? []);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Get payment methods enum
  Future<List<String>?> getPaymentMethods() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        SharedPaths.getPaymentMethods,
      );

      if (response is DataSuccess) {
        return List<String>.from(response.data!['methods'] ?? []);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Get vehicle types enum
  Future<List<String>?> getVehicleTypes() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        SharedPaths.getVehicleTypes,
      );

      if (response is DataSuccess) {
        return List<String>.from(response.data!['types'] ?? []);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Get document types enum
  Future<List<String>?> getDocumentTypes() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        SharedPaths.getDocumentTypes,
      );

      if (response is DataSuccess) {
        return List<String>.from(response.data!['types'] ?? []);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Get cities list
  Future<List<Map<String, dynamic>>?> getCities() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        SharedPaths.getCities,
      );

      if (response is DataSuccess) {
        return List<Map<String, dynamic>>.from(response.data!['cities'] ?? []);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Get service areas
  Future<List<Map<String, dynamic>>?> getServiceAreas() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        SharedPaths.getServiceAreas,
      );

      if (response is DataSuccess) {
        return List<Map<String, dynamic>>.from(response.data!['areas'] ?? []);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Validate coordinates
  Future<bool> validateCoordinates(double lat, double lng) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        SharedPaths.validateCoordinates,
        queryParameters: {
          'lat': lat,
          'lng': lng,
        },
      );

      if (response is DataSuccess) {
        return response.data!['valid'] as bool? ?? false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Get languages list
  Future<List<Map<String, dynamic>>?> getLanguages() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        SharedPaths.getLanguages,
      );

      if (response is DataSuccess) {
        return List<Map<String, dynamic>>.from(response.data!['languages'] ?? []);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Get countries list
  Future<List<Map<String, dynamic>>?> getCountries() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        SharedPaths.getCountries,
      );

      if (response is DataSuccess) {
        return List<Map<String, dynamic>>.from(response.data!['countries'] ?? []);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Upload file
  Future<String?> uploadFile(String filePath, String fieldName) async {
    try {
      final response = await apiClient.uploadFile<Map<String, dynamic>>(
        SharedPaths.uploadFile,
        file: File(filePath),
        fieldName: fieldName,
      );

      if (response is DataSuccess) {
        return response.data!['fileUrl'] as String?;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Delete file
  Future<bool> deleteFile(String fileUrl) async {
    try {
      final response = await apiClient.delete<Map<String, dynamic>>(
        SharedPaths.deleteFile,
        data: {'fileUrl': fileUrl},
      );

      if (response is DataSuccess) {
        return response.data!['success'] as bool? ?? false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Validate phone number
  Future<bool> validatePhone(String phone) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        SharedPaths.validatePhone,
        queryParameters: {'phone': phone},
      );

      if (response is DataSuccess) {
        return response.data!['valid'] as bool? ?? false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Validate email
  Future<bool> validateEmail(String email) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        SharedPaths.validateEmail,
        queryParameters: {'email': email},
      );

      if (response is DataSuccess) {
        return response.data!['valid'] as bool? ?? false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Get common data (cached)
  Future<Map<String, dynamic>?> getCommonData() async {
    try {
      // Try to get from cache first
      final cached = localStorage.getString('common_data');
      if (cached != null) {
        return Map<String, dynamic>.from(jsonDecode(cached));
      }

      // If not cached, fetch from API
      final response = await apiClient.get<Map<String, dynamic>>(
        SharedPaths.getCommonData,
      );

      if (response is DataSuccess) {
        // Cache the data
        await localStorage.saveString('common_data', jsonEncode(response.data));
        return response.data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Get settings (legacy method for backward compatibility)
  Future<Settings?> getSettings() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        SharedPaths.getAppConfig,
      );

      if (response is DataSuccess) {
        return Settings.fromJson(response.data!);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Update settings (legacy method for backward compatibility)
  Future<bool> updateSettings(Settings settings) async {
    try {
      final response = await apiClient.put<Map<String, dynamic>>(
        SharedPaths.getAppConfig,
        data: settings.toJson(),
      );

      if (response is DataSuccess) {
        return response.data!['success'] as bool? ?? false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Get cached settings
  Future<Settings?> getCachedSettings() async {
    try {
      final cached = localStorage.getString('cached_settings');
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
      localStorage.saveString('cached_settings', jsonEncode(settings.toJson()));
    } catch (e) {
      // Handle error silently
    }
  }
}