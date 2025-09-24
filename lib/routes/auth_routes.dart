import 'package:flutter/material.dart';
import 'package:driver/screens/auth/login/login.dart';
import 'package:driver/screens/auth/otp/view/otp_screen.dart';
import 'route_constants.dart';

/// Authentication routes for login and OTP verification
class AuthRoutes {
  // Route constants
  static const String login = RouteConstants.login;
  static const String otp = RouteConstants.otp;

  /// Returns all authentication routes
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginScreen(),
      otp: (context) => const OtpScreen(),
    };
  }
}
