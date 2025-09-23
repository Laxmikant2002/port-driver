import 'package:api_client/api_client.dart';
import 'package:localstorage/localstorage.dart';
import 'models/booking.dart';
import 'models/booking_response.dart';

/// Booking repository for managing ride bookings
class BookingRepo {
  const BookingRepo({
    required this.apiClient,
    required this.localStorage,
  });

  final ApiClient apiClient;
  final Localstorage localStorage;

  /// Get available bookings for driver
  Future<BookingResponse> getAvailableBookings() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>('/rides/request');

      if (response is DataSuccess) {
        final data = response.data!;
        return BookingResponse.fromJson(data);
      }

      if (response is DataFailed) {
        return BookingResponse(
          success: false,
          message: response.error?.getErrorMessage() ?? 'Failed to fetch available bookings',
        );
      }

      return BookingResponse(
        success: false,
        message: 'Unexpected error occurred',
      );
    } catch (e) {
      return BookingResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Accept a booking
  Future<BookingResponse> acceptBooking(String bookingId) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        '/rides/accept',
        data: {'bookingId': bookingId},
      );

      if (response is DataSuccess) {
        final data = response.data!;
        return BookingResponse.fromJson(data);
      }

      if (response is DataFailed) {
        return BookingResponse(
          success: false,
          message: response.error?.getErrorMessage() ?? 'Failed to accept booking',
        );
      }

      return BookingResponse(
        success: false,
        message: 'Unexpected error occurred',
      );
    } catch (e) {
      return BookingResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Reject a booking
  Future<BookingResponse> rejectBooking(String bookingId, {String? reason}) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        '/rides/reject',
        data: {'bookingId': bookingId, 'reason': reason},
      );

      if (response is DataSuccess) {
        final data = response.data!;
        return BookingResponse.fromJson(data);
      }

      if (response is DataFailed) {
        return BookingResponse(
          success: false,
          message: response.error?.getErrorMessage() ?? 'Failed to reject booking',
        );
      }

      return BookingResponse(
        success: false,
        message: 'Unexpected error occurred',
      );
    } catch (e) {
      return BookingResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Start a booking
  Future<BookingResponse> startBooking(String bookingId) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        '/rides/start',
        data: {'bookingId': bookingId},
      );

      if (response is DataSuccess) {
        final data = response.data!;
        return BookingResponse.fromJson(data);
      }

      if (response is DataFailed) {
        return BookingResponse(
          success: false,
          message: response.error?.getErrorMessage() ?? 'Failed to start booking',
        );
      }

      return BookingResponse(
        success: false,
        message: 'Unexpected error occurred',
      );
    } catch (e) {
      return BookingResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Complete a booking
  Future<BookingResponse> completeBooking(String bookingId) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        '/rides/complete',
        data: {'bookingId': bookingId},
      );

      if (response is DataSuccess) {
        final data = response.data!;
        return BookingResponse.fromJson(data);
      }

      if (response is DataFailed) {
        return BookingResponse(
          success: false,
          message: response.error?.getErrorMessage() ?? 'Failed to complete booking',
        );
      }

      return BookingResponse(
        success: false,
        message: 'Unexpected error occurred',
      );
    } catch (e) {
      return BookingResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get booking details
  Future<BookingResponse> getBooking(String bookingId) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>('/booking/$bookingId');

      if (response is DataSuccess) {
        final data = response.data!;
        return BookingResponse.fromJson(data);
      }

      if (response is DataFailed) {
        return BookingResponse(
          success: false,
          message: response.error?.getErrorMessage() ?? 'Failed to fetch booking details',
        );
      }

      return BookingResponse(
        success: false,
        message: 'Unexpected error occurred',
      );
    } catch (e) {
      return BookingResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }
}
