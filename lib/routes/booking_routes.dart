import 'package:flutter/material.dart';

class BookingRoutes {
  // Booking management
  static const String bookingRequest = '/booking-request';
  static const String bookingDetails = '/booking-details';
  static const String acceptBooking = '/accept-booking';
  static const String rejectBooking = '/reject-booking';
  static const String bookingHistory = '/booking-history';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      // These are typically shown as bottom sheets or modals
      // rather than full screens, but keeping routes for consistency
      bookingRequest: (context) {
        // This would typically be shown as a bottom sheet
        return const Scaffold(
          body: Center(
            child: Text('Booking Request - Usually shown as bottom sheet'),
          ),
        );
      },
      bookingDetails: (context) {
        // This would typically be shown as a bottom sheet
        return const Scaffold(
          body: Center(
            child: Text('Booking Details - Usually shown as bottom sheet'),
          ),
        );
      },
      acceptBooking: (context) {
        // This would typically be handled by state management
        return const Scaffold(
          body: Center(
            child: Text('Accept Booking - Handled by state management'),
          ),
        );
      },
      rejectBooking: (context) {
        // This would typically be handled by state management
        return const Scaffold(
          body: Center(
            child: Text('Reject Booking - Handled by state management'),
          ),
        );
      },
      bookingHistory: (context) {
        // This could be a full screen showing past booking requests
        return const Scaffold(
          body: Center(
            child: Text('Booking History - Full screen implementation needed'),
          ),
        );
      },
    };
  }
}
