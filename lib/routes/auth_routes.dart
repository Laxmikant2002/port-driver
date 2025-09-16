import 'package:flutter/material.dart';
import 'package:driver/screens/auth/login/login.dart';
import 'package:driver/screens/auth/otp/view/otp_screen.dart';
import 'package:driver/screens/auth/profile/view/profile_screen.dart';

class AuthRoutes {
  static const String otp = '/get-otp';
  static const String login = '/';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginScreen(),
      otp: (context) => const OtpScreen(),
      profile: (context) => const ProfileScreen(),
    };
  }
}
