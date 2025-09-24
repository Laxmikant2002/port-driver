import 'package:flutter/material.dart';
import 'package:driver/screens/account/setting_section/notification_settings/view/notification_settings_screen.dart';

class NotificationsRoutes {
  // Driver notifications
  static const String notificationSettings = '/notification-settings';
  static const String bookingNotifications = '/booking-notifications';
  static const String earningsNotifications = '/earnings-notifications';
  static const String systemNotifications = '/system-notifications';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      notificationSettings: (context) => const NotificationSettingsScreen(),
      bookingNotifications: (context) {
        // This could be a dedicated booking notifications screen
        return const Scaffold(
          body: Center(
            child: Text('Booking Notifications - Full screen implementation needed'),
          ),
        );
      },
      earningsNotifications: (context) {
        // This could be a dedicated earnings notifications screen
        return const Scaffold(
          body: Center(
            child: Text('Earnings Notifications - Full screen implementation needed'),
          ),
        );
      },
      systemNotifications: (context) {
        // This could be a dedicated system notifications screen
        return const Scaffold(
          body: Center(
            child: Text('System Notifications - Full screen implementation needed'),
          ),
        );
      },
    };
  }
}
