import 'package:flutter/material.dart';
import 'package:driver/screens/home/view/home_screen.dart';
import 'package:driver/screens/rides/view/ride_screen.dart';
import 'package:driver/screens/summary/view/summary_screen.dart';

class DriverStatusRoutes {
  // Main driver dashboard and status
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String summary = '/summary';
  
  // Driver status management
  static const String goOnline = '/go-online';
  static const String goOffline = '/go-offline';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const HomeScreen(),
      dashboard: (context) => const RideScreen(), // Main driver dashboard with map
      summary: (context) => const SummaryScreen(),
      
      // These routes might be handled by state management rather than navigation
      // but keeping them for potential future use
      goOnline: (context) => const RideScreen(),
      goOffline: (context) => const RideScreen(),
    };
  }
}
