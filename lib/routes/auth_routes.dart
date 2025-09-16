import 'package:flutter/material.dart';
import 'package:driver/screens/auth/login/login.dart';
import 'package:driver/screens/auth/otp/view/otp_screen.dart';
import 'package:driver/screens/auth/profile/view/profile_screen.dart';
import 'package:driver/screens/document_verification/language_choose/view/language_screen.dart';
import 'package:driver/screens/document_verification/vehicle_selection/view/vehicle_screen.dart';
import 'package:driver/screens/document_verification/work_location/view/work_screen.dart';
import 'package:driver/screens/document_verification/document_verify/docs_list/view/docs_screen.dart';

class AuthRoutes {
  static const String otp = '/get-otp';
  static const String login = '/';
  static const String profile = '/profile';
  static const String language = '/language';
  static const String vehicleSelection = '/vehicle-selection';
  static const String workLocation = '/work-location';
  static const String docsVerification = '/docs-verification';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginScreen(),
      otp: (context) => const OtpScreen(),
      profile: (context) => const ProfileScreen(),
      language: (context) => const LanguageScreen(),
      vehicleSelection: (context) => const VehicleScreen(),
      workLocation: (context) => const WorkLocationPage(),
      docsVerification: (context) => const DocsPage(),
    };
  }
}
