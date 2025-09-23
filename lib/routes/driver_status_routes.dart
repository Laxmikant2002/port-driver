import 'package:flutter/material.dart';
import 'package:driver/screens/home/view/home_screen.dart';
import 'package:driver/screens/booking_flow/Driver_Status/driver_status_screen.dart';

class DriverStatusRoutes {
  // Main driver dashboard and status
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  
  // Driver status management
  static const String goOnline = '/go-online';
  static const String goOffline = '/go-offline';
  static const String workAreaSelection = '/work-area-selection';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const HomeScreen(),
      dashboard: (context) => const DashboardScreen(), // Main driver dashboard
      workAreaSelection: (context) => const WorkAreaSelectionScreen(),
      
      // These routes might be handled by state management rather than navigation
      // but keeping them for potential future use
      goOnline: (context) => const DashboardScreen(),
      goOffline: (context) => const DashboardScreen(),
    };
  }
}
