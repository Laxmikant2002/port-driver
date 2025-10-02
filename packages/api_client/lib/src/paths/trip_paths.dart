import 'package:api_client/src/paths/base_paths.dart';

class TripPaths extends BasePaths {
  // Trip Management
  static final String acceptTrip = "${BasePaths.baseUrl}/driver/trips/accept";
  static final String rejectTrip = "${BasePaths.baseUrl}/driver/trips/reject";
  static final String updateTripStatus = "${BasePaths.baseUrl}/driver/trips/status";
  static final String completeTrip = "${BasePaths.baseUrl}/driver/trips/complete";
  static final String updateTripLocation = "${BasePaths.baseUrl}/driver/trips/location";
  
  // Trip Data
  static final String getTripDetails = "${BasePaths.baseUrl}/driver/trips";
  static final String getActiveTrip = "${BasePaths.baseUrl}/driver/trips/active";
  static final String getTripHistory = "${BasePaths.baseUrl}/driver/trips/history";
  static final String getTripEarnings = "${BasePaths.baseUrl}/driver/trips/earnings";
  
  // Payment & Rating
  static final String confirmPayment = "${BasePaths.baseUrl}/driver/trips/payment";
  static final String ratePassenger = "${BasePaths.baseUrl}/driver/trips/rate";
  
  // Legacy Booking Endpoints (for backward compatibility)
  static final String getAvailableBookings = "${BasePaths.baseUrl}/driver/bookings/available";
  static final String startBooking = "${BasePaths.baseUrl}/driver/bookings/start";
  static final String completeBooking = "${BasePaths.baseUrl}/driver/bookings/complete";
  static final String markCashCollected = "${BasePaths.baseUrl}/driver/bookings/cash-collected";
  static final String getCashTrips = "${BasePaths.baseUrl}/driver/bookings/cash-trips";
}