import 'base_paths.dart';

class AuthPaths extends BasePaths {
  static final String login = "${BasePaths.baseUrl}/driver/login";
  static final String verifyOtp = "${BasePaths.baseUrl}/driver/verify-otp";
  static final String refreshToken = "${BasePaths.baseUrl}/driver/refresh-token";
  static final String driverProfile = "${BasePaths.baseUrl}/driver/profile";
  static final String updateStatus = "${BasePaths.baseUrl}/driver/status";
  static final String updateLocation = "${BasePaths.baseUrl}/driver/location";
  static final String activeTrips = "${BasePaths.baseUrl}/driver/trips/active";
  static final String tripHistory = "${BasePaths.baseUrl}/driver/trips/history";
  static final String earnings = "${BasePaths.baseUrl}/driver/earnings";
  static final String logout = "${BasePaths.baseUrl}/driver/logout";
  static final String updateProfile = "${BasePaths.baseUrl}/driver/profile/update";
  static final String resendOtp = "${BasePaths.baseUrl}/auth/resend-otp";
}