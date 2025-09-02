import 'package:flutter/material.dart';
import 'package:driver/screens/account/ride_history/views/history_screen.dart';
import 'package:driver/screens/home/view/home_screen.dart';
import 'package:driver/screens/summary/view/summary_screen.dart';
import 'package:driver/screens/trips/view/trip_screen.dart';
import 'package:driver/screens/rides/wallet/send_to_bank_screen.dart';


class DashboardRoutes {
  static const String home = '/home';
  static const String sendToBank = '/send-to-bank';
  static const String settings = '/settings';
  static const String trip = '/trip';
  static const String summary = '/summary';
  static const String watersports = '/watersports';
  static const String bookings = '/bookings';
  static const String history = '/history';
  

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const HomeScreen(),
      sendToBank: (context) => SendToBank(),
      trip: (context) => const TripScreen(),
      summary: (context) => const SummaryScreen(),
      history: (context) => const HistoryScreen(),
    };
  }
}
