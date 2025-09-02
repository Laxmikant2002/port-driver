import 'dart:convert';

import 'package:api_client/api_client.dart';
import 'package:auth_repo/auth_repo.dart';
import 'package:auth_repo/src/models/login_request.dart';
import 'package:auth_repo/src/models/login_response.dart';
import 'package:auth_repo/src/models/resend_otp_response.dart';
import 'package:auth_repo/src/models/verify_response.dart';
import 'package:localstorage/localstorage.dart';

class AuthRepo {
  AuthRepo(this.apiClient, this.localStorage);

  final ApiClient apiClient;
  final Localstorage localStorage;

  bool isSignedIn() {
    final token = localStorage.getString(LocalKeys.accessToken);
    return token != null;
  }

  String? getUserName() {
    final userJson = localStorage.getString(LocalKeys.userJson);
    if (userJson != null) {
      final user = jsonDecode(userJson) as Map<String, dynamic>;
      return user['name'] as String?;
    }
    return null;
  }

  void logout() {
    localStorage.clear();
  }

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await apiClient.postReq(
        AuthPaths.login,
        bodyJson: request.toJson(),
      );

      if (response is DataFailed) {
        final error = response.error?.error as Map<String, dynamic>?;
        return AuthResponse(
          message: error?['error'] ?? 'Login failed',
          otpSent: false,
        );
      }

      if (response is DataSuccess) {
        final data = response.data?.data as Map<String, dynamic>;
        // Store OTP token for verification
        localStorage.saveString(LocalKeys.otpToken, data['otpToken']);
        return AuthResponse(
          otpSent: data['otpSent'] == true,
          message: data['otpSent'] == true ? null : 'OTP not sent',
        );
      }

      return AuthResponse(
        message: 'Unexpected error occurred',
        otpSent: false,
      );
    } catch (e) {
      return AuthResponse(
        message: 'Unexpected error occurred: $e',
        otpSent: false,
      );
    }
  }

  Future<String?> verifyOtp(String otp) async {
    final otpToken = localStorage.getString(LocalKeys.otpToken);
    if (otpToken == null) {
      return 'OTP token not found. Please login again.';
    }

    final request = {'otp': otp, 'otpToken': otpToken};

    try {
      final response = await apiClient.postReq(
        AuthPaths.verifyOtp,
        bodyJson: request,
      );

      if (response is DataSuccess) {
        final data = response.data?.data as Map<String, dynamic>;
        // Store access token and user data after successful verification
        localStorage.saveString(LocalKeys.accessToken, data['accessToken']);
        localStorage.saveString(LocalKeys.userJson, jsonEncode(data['user']));
        return null; // Success
      }

      if (response is DataFailed) {
        final error = response.error?.error as Map<String, dynamic>?;
        return error?['error'] ?? 'OTP verification failed';
      }
    } catch (e) {
      return 'Unexpected error occurred: $e';
    }
    return 'Unexpected error occurred';
  }

  Future<String?> resendOtp() async {
    try {
      final response = await apiClient.getReq(AuthPaths.resendOtp);

      if (response is DataSuccess) {
        final data = ResendOtpResponse.fromJson(response.data?.data as Map<String, dynamic>);
        localStorage.saveString(LocalKeys.otp, data.otp);
        localStorage.saveString(LocalKeys.otpToken, data.otpToken);
        return null; // Success
      }

      if (response is DataFailed) {
        final error = response.error?.error as Map<String, dynamic>?;
        return error?['error'] ?? 'Failed to resend OTP';
      }
    } catch (e) {
      return 'Unexpected error occurred: $e';
    }
    return 'Unexpected error occurred';
  }
}
