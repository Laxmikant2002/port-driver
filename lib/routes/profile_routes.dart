import 'package:flutter/material.dart';
import 'package:driver/screens/account/profile/view/profile_screen.dart' as AccountProfile;
import 'package:driver/screens/auth/profile/view/profile_screen.dart' as AuthProfile;
import 'package:driver/screens/document_verification/language_choose/view/language_screen.dart';
import 'package:driver/screens/document_verification/vehicle_selection/view/vehicle_screen.dart';
import 'package:driver/screens/document_verification/work_location/view/work_screen.dart';

class ProfileRoutes {
  // Driver profile creation (onboarding)
  static const String profileCreation = '/profile-creation';
  static const String languageSelection = '/language-selection';
  static const String vehicleSelection = '/vehicle-selection';
  static const String workLocation = '/work-location';
  
  // Driver profile management
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      // Profile creation flow (onboarding)
      profileCreation: (context) {
        final phone = ModalRoute.of(context)?.settings.arguments as String? ?? '';
        return AuthProfile.ProfileScreen(phone: phone);
      },
      languageSelection: (context) => const LanguageScreen(),
      vehicleSelection: (context) => const VehicleScreen(),
      workLocation: (context) => const WorkLocationPage(),
      
      // Profile management
      profile: (context) => const AccountProfile.ProfileScreen(phoneNumber: '+1234567890'), // TODO: Get actual phone from auth
    };
  }
}
