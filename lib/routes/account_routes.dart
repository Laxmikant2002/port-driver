import 'package:flutter/material.dart';
import 'package:driver/screens/account/addvehicle/view/add_vehicle_screen.dart';
import 'package:driver/screens/account/inbox/view/inbox_screen.dart';
import 'package:driver/screens/account/ratings/view/ratings_screen.dart';
import 'package:driver/screens/account/ride_history/views/history_screen.dart';
import 'package:driver/screens/account/document/views/document_screen.dart';
import 'package:driver/screens/account/wallet/view/payment_overview_screen.dart';
import 'package:driver/screens/account/profile/profile_screen.dart';
import 'package:driver/screens/account/notification/view/notification_settings_screen.dart';


class AccountRoutes {
  static const String profile = '/profile';
  static const String ridesHistory = '/rides-history';
  static const String ratings = '/ratings';
  static const String documentScreen = '/document-screen';
  static const String addvehicle ='/add-vehicle';
  static const String inbox = '/inbox';
  static const String paymentOverview = '/payment-overview';
  static const String notificationSettings = '/notification-settings';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      profile: (context) => const ProfileScreen(phoneNumber: '+1234567890'), // TODO: Get actual phone from auth
      ridesHistory: (context) => const HistoryScreen(),
      ratings: (context) => const RatingsScreen(),
      documentScreen: (context) => const DocumentScreen(),
      addvehicle: (context) => const AddVehicleScreen(),
      inbox: (context) => const InboxScreen(),
      paymentOverview: (context) => const PaymentOverviewScreen(),
      notificationSettings: (context) => const NotificationSettingsScreen(),
    };
  }
}
