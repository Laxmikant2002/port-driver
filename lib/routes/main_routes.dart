import 'package:flutter/material.dart';
import 'package:booking_repo/booking_repo.dart';
import 'package:driver/screens/home/view/home_screen.dart';
import 'package:driver/screens/booking_flow/Driver_Status/driver_status_screen.dart';
import 'package:driver/screens/booking_flow/Ride_Progress/ride_progress_screen.dart';
import 'package:driver/screens/booking_flow/Driver_Status/view/dashboard_screen.dart';
import 'package:driver/screens/booking_flow/Driver_Status/view/work_area_selection_screen.dart';
import 'package:driver/screens/booking_flow/Ride_Progress/view/incoming_ride_request_sheet.dart';
import 'package:driver/screens/booking_flow/Ride_Progress/view/ride_detail_screen.dart';
import 'package:driver/screens/testing/test_navigator_screen.dart';
import 'route_constants.dart';

/// Main application routes for driver status, booking, and trip management
class MainRoutes {
  // Route constants
  static const String home = RouteConstants.home;
  static const String dashboard = RouteConstants.dashboard;
  static const String goOnline = RouteConstants.goOnline;
  static const String goOffline = RouteConstants.goOffline;
  static const String workAreaSelection = RouteConstants.workAreaSelection;

  // Booking routes
  static const String incomingRideRequest = RouteConstants.incomingRideRequest;
  static const String bookingDetails = RouteConstants.bookingDetails;
  static const String bookingHistory = RouteConstants.bookingHistory;

  // Trip routes
  static const String trip = RouteConstants.trip;
  static const String startTrip = RouteConstants.startTrip;
  static const String completeTrip = RouteConstants.completeTrip;
  static const String cancelTrip = RouteConstants.cancelTrip;
  static const String tripInProgress = RouteConstants.tripInProgress;
  static const String tripSummary = RouteConstants.tripSummary;
  static const String fareBreakdown = RouteConstants.fareBreakdown;

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      // Driver status routes
      home: (context) => const HomeScreen(),
      dashboard: (context) => const DashboardScreen(),
      workAreaSelection: (context) => const WorkAreaSelectionScreen(),
      goOnline: (context) => const DashboardScreen(),
      goOffline: (context) => const DashboardScreen(),

      // Booking routes
      incomingRideRequest: (context) {
        final booking = ModalRoute.of(context)?.settings.arguments;
        if (booking == null || booking is! Booking) {
          return const Scaffold(
            body: Center(
              child: Text('No booking data provided'),
            ),
          );
        }
        return IncomingRideRequestSheet(booking: booking);
      },
      bookingDetails: (context) {
        final booking = ModalRoute.of(context)?.settings.arguments;
        if (booking == null || booking is! Booking) {
          return const Scaffold(
            body: Center(
              child: Text('No booking data provided'),
            ),
          );
        }
        return RideDetailScreen(booking: booking);
      },
      bookingHistory: (context) {
        return const Scaffold(
          body: Center(
            child: Text('Booking History - Full screen implementation needed'),
          ),
        );
      },

      // Trip routes
      trip: (context) {
        return const Scaffold(
          body: Center(
            child: Text('Trip List - Implementation needed'),
          ),
        );
      },
      startTrip: (context) {
        return const Scaffold(
          body: Center(
            child: Text('Start Trip - Handled by state management'),
          ),
        );
      },
      completeTrip: (context) {
        return const Scaffold(
          body: Center(
            child: Text('Complete Trip - Handled by state management'),
          ),
        );
      },
      cancelTrip: (context) {
        return const Scaffold(
          body: Center(
            child: Text('Cancel Trip - Handled by state management'),
          ),
        );
      },
      tripInProgress: (context) {
        return const Scaffold(
          body: Center(
            child: Text('Trip In Progress - Full screen implementation needed'),
          ),
        );
      },
      tripSummary: (context) {
        return const Scaffold(
          body: Center(
            child: Text('Trip Summary - Full screen implementation needed'),
          ),
        );
      },
      fareBreakdown: (context) {
        final tripId = ModalRoute.of(context)?.settings.arguments as String? ?? 'trip_123';
        return Scaffold(
          appBar: AppBar(title: const Text('Fare Breakdown')),
          body: Center(
            child: Text('Fare Breakdown for Trip: $tripId'),
          ),
        );
      },
      
      // Testing route (only available in testing mode)
      '/test-navigator': (context) => const TestNavigatorScreen(),
    };
  }
}
