import 'package:flutter/material.dart';
import 'package:driver/screens/account/setting_section/settings/view/settings_screen.dart';
import 'package:driver/screens/account/setting_section/settings/views/about.dart';

class SettingsRoutes {
  static const String settings = '/settings';
  static const String language = '/language';
  static const String notifications = '/notifications';
  static const String privacy = '/privacy';
  static const String support = '/support';
  static const String faq = '/faq';
  static const String about = '/about';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      settings: (context) => const SettingsScreen(),
      language: (context) {
        // Placeholder for language selection screen
        return const Scaffold(
          body: Center(
            child: Text('Language Selection - Full screen implementation needed'),
          ),
        );
      },
      notifications: (context) {
        // Placeholder for notifications settings screen
        return const Scaffold(
          body: Center(
            child: Text('Notifications Settings - Full screen implementation needed'),
          ),
        );
      },
      privacy: (context) {
        // Placeholder for privacy screen
        return const Scaffold(
          body: Center(
            child: Text('Privacy Policy - Full screen implementation needed'),
          ),
        );
      },
      support: (context) {
        // Placeholder for support screen
        return const Scaffold(
          body: Center(
            child: Text('Support - Full screen implementation needed'),
          ),
        );
      },
      faq: (context) {
        // Placeholder for FAQ screen
        return const Scaffold(
          body: Center(
            child: Text('FAQ - Full screen implementation needed'),
          ),
        );
      },
      about: (context) => const AboutScreen(),
    };
  }
}