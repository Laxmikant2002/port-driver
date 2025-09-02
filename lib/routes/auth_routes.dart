import 'package:flutter/material.dart';
import 'package:driver/screens/auth/login/login.dart';
import 'package:driver/screens/auth/otp/view/otp_screen.dart';
import 'package:driver/screens/splash_screen/view/splash_screen.dart';

class AuthRoutes {
  static const String login = '/login';
  static const String otp = '/get-otp';
  static const String splash = '/';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      otp: (context) => const OtpScreen(),
    };
  }
}
