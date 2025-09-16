import 'package:flutter/material.dart';
import 'package:driver/screens/auth/login/login.dart';
import 'package:driver/screens/auth/otp/view/otp_screen.dart';

class AuthRoutes {
  static const String otp = '/get-otp';
  static const String login = '/';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginScreen(),
      otp: (context) => const OtpScreen(),
    };
  }
}
