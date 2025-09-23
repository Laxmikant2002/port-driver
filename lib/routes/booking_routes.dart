import 'package:booking_repo/booking_repo.dart';
import 'package:flutter/material.dart';
import 'package:driver/screens/booking_flow/Ride_Progress/ride_progress_screen.dart';

class BookingRoutes {
  // Ride matching and booking management
  static const String incomingRideRequest = '/incoming-ride-request';
  static const String bookingDetails = '/booking-details';
  static const String bookingHistory = '/booking-history';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      // Incoming ride request bottom sheet
      incomingRideRequest: (context) {
        // This would typically be shown as a bottom sheet with a booking
        // For now, create a mock booking for demonstration
        final mockBooking = Booking(
          id: '1',
          passengerId: 'passenger_1',
          driverId: 'driver_1',
          status: BookingStatus.pending,
          pickupLocation: const BookingLocation(
            address: '123 Main Street, Downtown',
            latitude: 40.7128,
            longitude: -74.0060,
          ),
          dropoffLocation: const BookingLocation(
            address: '456 Park Avenue, Uptown',
            latitude: 40.7589,
            longitude: -73.9851,
          ),
          fare: 25.50,
          distance: 5.2,
          estimatedDuration: 15,
          createdAt: DateTime.now(),
          passengerName: 'John Doe',
          passengerPhone: '+1234567890',
          passengerPhoto: null,
          vehicleType: 'Sedan',
          paymentMethod: 'Credit Card',
        );
        
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: IncomingRideRequestSheet(booking: mockBooking),
        );
      },
      bookingDetails: (context) {
        // This would typically be shown as a full screen with booking details
        final mockBooking = Booking(
          id: '1',
          passengerId: 'passenger_1',
          driverId: 'driver_1',
          status: BookingStatus.accepted,
          pickupLocation: const BookingLocation(
            address: '123 Main Street, Downtown',
            latitude: 40.7128,
            longitude: -74.0060,
          ),
          dropoffLocation: const BookingLocation(
            address: '456 Park Avenue, Uptown',
            latitude: 40.7589,
            longitude: -73.9851,
          ),
          fare: 25.50,
          distance: 5.2,
          estimatedDuration: 15,
          createdAt: DateTime.now(),
          passengerName: 'John Doe',
          passengerPhone: '+1234567890',
          passengerPhoto: null,
          vehicleType: 'Sedan',
          paymentMethod: 'Credit Card',
        );
        
        return RideDetailScreen(booking: mockBooking);
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
