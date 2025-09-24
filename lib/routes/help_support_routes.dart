import 'package:flutter/material.dart';
import 'package:driver/screens/account/help_support/views/help_support_screen.dart';

class HelpSupportRoutes {
  // Help and support
  static const String helpSupport = '/help-support';
  static const String faq = '/faq';
  static const String contactUs = '/contact-us';
  static const String emergency = '/emergency';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      helpSupport: (context) => const HelpSupportScreen(),
      faq: (context) => const HelpSupportScreen(),
      contactUs: (context) => const HelpSupportScreen(),
      emergency: (context) => const HelpSupportScreen(),
    };
  }
}
