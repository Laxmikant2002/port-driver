import 'package:flutter/material.dart';
import 'package:driver/screens/trips/view/trip_screen.dart';

class TripRoutes {
  // Trip lifecycle management
  static const String trip = '/trip';
  static const String startTrip = '/start-trip';
  static const String completeTrip = '/complete-trip';
  static const String cancelTrip = '/cancel-trip';
  static const String tripInProgress = '/trip-in-progress';
  static const String tripSummary = '/trip-summary';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      trip: (context) => const TripScreen(),
      startTrip: (context) {
        // This would typically be handled by state management
        // but keeping route for potential navigation needs
        return const Scaffold(
          body: Center(
            child: Text('Start Trip - Handled by state management'),
          ),
        );
      },
      completeTrip: (context) {
        // This would typically be handled by state management
        return const Scaffold(
          body: Center(
            child: Text('Complete Trip - Handled by state management'),
          ),
        );
      },
      cancelTrip: (context) {
        // This would typically be handled by state management
        return const Scaffold(
          body: Center(
            child: Text('Cancel Trip - Handled by state management'),
          ),
        );
      },
      tripInProgress: (context) {
        // This could be a full screen for ongoing trip management
        return const Scaffold(
          body: Center(
            child: Text('Trip In Progress - Full screen implementation needed'),
          ),
        );
      },
      tripSummary: (context) {
        // This could be a summary screen after trip completion
        return const Scaffold(
          body: Center(
            child: Text('Trip Summary - Full screen implementation needed'),
          ),
        );
      },
    };
  }
}
