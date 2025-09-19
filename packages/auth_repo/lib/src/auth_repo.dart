import 'dart:convert';

import 'package:api_client/api_client.dart';
import 'package:auth_repo/src/models/auth_user.dart';
import 'package:auth_repo/src/models/auth_response.dart';
import 'package:auth_repo/src/models/login_request.dart';
import 'package:localstorage/localstorage.dart';

/// Modern Auth Repository with proper error handling and typed responses
class AuthRepo {
  const AuthRepo({
    required this.apiClient,
    required this.localStorage,
  });

  final ApiClient apiClient;
  final Localstorage localStorage;

  /// Check if user is currently signed in
  bool get isSignedIn {
    final token = localStorage.getString(LocalKeys.accessToken);
    return token != null && token.isNotEmpty;
  }

  /// Get current user from local storage
  AuthUser? get currentUser {
    final userJson = localStorage.getString(LocalKeys.userJson);
    if (userJson != null) {
      try {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        return AuthUser.fromJson(userMap);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Get current access token
  String? get accessToken => localStorage.getString(LocalKeys.accessToken);

  /// Get current OTP token
  String? get otpToken => localStorage.getString(LocalKeys.otpToken);

  /// Check if phone number exists in the system
  Future<AuthResponse> checkPhone(String phone) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        AuthPaths.login,
        data: {'phone': phone, 'checkOnly': true},
      );

      if (response is DataSuccess) {
        final data = response.data!;
        return AuthResponse.fromJson(data);
      }

      if (response is DataFailed) {
        return AuthResponse(
          success: false,
          message: response.error?.getErrorMessage() ?? 'Failed to check phone number',
        );
      }

      return AuthResponse(
        success: false,
        message: 'Unexpected error occurred',
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Send OTP to phone number
  Future<AuthResponse> sendOtp(LoginRequest request) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        AuthPaths.login,
        data: request.toJson(),
      );

      if (response is DataSuccess) {
        final data = response.data!;
        final authResponse = AuthResponse.fromJson(data);
        
        // Store OTP token for verification
        if (authResponse.otpToken != null) {
          localStorage.saveString(LocalKeys.otpToken, authResponse.otpToken!);
        }
        
        return authResponse;
      }

      if (response is DataFailed) {
        return AuthResponse(
          success: false,
          message: response.error?.getErrorMessage() ?? 'Failed to send OTP',
        );
      }

      return AuthResponse(
        success: false,
        message: 'Unexpected error occurred',
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Verify OTP and complete authentication
  Future<AuthResponse> verifyOtp(String otp) async {
    final otpToken = localStorage.getString(LocalKeys.otpToken);
    if (otpToken == null) {
      return AuthResponse(
        success: false,
        message: 'OTP token not found. Please request OTP again.',
      );
    }

    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        AuthPaths.verifyOtp,
        data: {
          'otp': otp,
          'otpToken': otpToken,
        },
      );

      if (response is DataSuccess) {
        final data = response.data!;
        final authResponse = AuthResponse.fromJson(data);
        
        if (authResponse.success && authResponse.user != null) {
          // Store access token and user data
          if (authResponse.accessToken != null) {
            localStorage.saveString(LocalKeys.accessToken, authResponse.accessToken!);
          }
          localStorage.saveString(LocalKeys.userJson, jsonEncode(authResponse.user!.toJson()));
          
          // Update API client with new token
          apiClient.updateAuthToken(authResponse.accessToken);
        }
        
        return authResponse;
      }

      if (response is DataFailed) {
        return AuthResponse(
          success: false,
          message: response.error?.getErrorMessage() ?? 'OTP verification failed',
        );
      }

      return AuthResponse(
        success: false,
        message: 'Unexpected error occurred',
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Resend OTP
  Future<AuthResponse> resendOtp() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(AuthPaths.resendOtp);

      if (response is DataSuccess) {
        final data = response.data!;
        final authResponse = AuthResponse.fromJson(data);
        
        // Update OTP token
        if (authResponse.otpToken != null) {
          localStorage.saveString(LocalKeys.otpToken, authResponse.otpToken!);
        }
        
        return authResponse;
      }

      if (response is DataFailed) {
        return AuthResponse(
          success: false,
          message: response.error?.getErrorMessage() ?? 'Failed to resend OTP',
        );
      }

      return AuthResponse(
        success: false,
        message: 'Unexpected error occurred',
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Refresh access token
  Future<AuthResponse> refreshToken() async {
    final refreshToken = localStorage.getString(LocalKeys.refreshToken);
    if (refreshToken == null) {
      return AuthResponse(
        success: false,
        message: 'No refresh token available',
      );
    }

    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        AuthPaths.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      if (response is DataSuccess) {
        final data = response.data!;
        final authResponse = AuthResponse.fromJson(data);
        
        if (authResponse.success && authResponse.accessToken != null) {
          localStorage.saveString(LocalKeys.accessToken, authResponse.accessToken!);
          apiClient.updateAuthToken(authResponse.accessToken);
        }
        
        return authResponse;
      }

      if (response is DataFailed) {
        return AuthResponse(
          success: false,
          message: response.error?.getErrorMessage() ?? 'Token refresh failed',
        );
      }

      return AuthResponse(
        success: false,
        message: 'Unexpected error occurred',
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Logout user and clear all stored data
  Future<void> logout() async {
    try {
      // Call logout API if user is signed in
      if (isSignedIn) {
        await apiClient.post(AuthPaths.logout);
      }
    } catch (e) {
      // Ignore logout API errors, still clear local data
    } finally {
      // Clear all stored data
      localStorage.clear();
      apiClient.clearAuthToken();
    }
  }

  /// Update user profile
  Future<AuthResponse> updateProfile(AuthUser user) async {
    try {
      final response = await apiClient.put<Map<String, dynamic>>(
        AuthPaths.updateProfile,
        data: user.toJson(),
      );

      if (response is DataSuccess) {
        final data = response.data!;
        final authResponse = AuthResponse.fromJson(data);
        
        if (authResponse.success && authResponse.user != null) {
          // Update stored user data
          localStorage.saveString(LocalKeys.userJson, jsonEncode(authResponse.user!.toJson()));
        }
        
        return authResponse;
      }

      if (response is DataFailed) {
        return AuthResponse(
          success: false,
          message: response.error?.getErrorMessage() ?? 'Profile update failed',
        );
      }

      return AuthResponse(
        success: false,
        message: 'Unexpected error occurred',
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }
}
