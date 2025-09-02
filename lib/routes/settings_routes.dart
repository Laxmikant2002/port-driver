import 'package:flutter/material.dart';
import 'package:driver/screens/account/settings/views/about.dart';
import 'package:driver/screens/account/settings/views/faq_screen.dart';
import 'package:driver/screens/account/settings/views/language_screen.dart';
import 'package:driver/screens/account/settings/views/privacy.dart';
import 'package:driver/screens/account/settings/views/settings_screen.dart';
import 'package:driver/screens/account/settings/views/support_screen.dart';
import 'package:driver/screens/account/settings/views/notifications_screen.dart';

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
      language: (context) => const LanguageSelectionScreen(),
      notifications: (context) => const NotificationsScreen(),
      privacy: (context) => const PrivacyScreen(),
      support: (context) => const SupportScreen(),
      faq: (context) => const FaqScreen(),
      about: (context) => const AboutScreen(),
    };
  }
}