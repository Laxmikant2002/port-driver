import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'models/booking.dart';
import 'models/booking_response.dart';

/// Booking repository for managing ride bookings
class BookingRepo {
  const BookingRepo({
    required this.baseUrl,
    required this.client,
    required this.localStorage,
  });

  final String baseUrl;
  final http.Client client;
  final Localstorage localStorage;

  /// Get available bookings for driver
  Future<BookingResponse> getAvailableBookings() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/booking/available'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return BookingResponse.fromJson(json);
      } else {
        return BookingResponse(
          success: false,
          message: 'Failed to fetch available bookings',
        );
      }
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
      final response = await client.post(
        Uri.parse('$baseUrl/booking/$bookingId/accept'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return BookingResponse.fromJson(json);
      } else {
        return BookingResponse(
          success: false,
          message: 'Failed to accept booking',
        );
      }
    } catch (e) {
      return BookingResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Cancel a booking
  Future<BookingResponse> cancelBooking(String bookingId, {String? reason}) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/booking/$bookingId/cancel'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode({'reason': reason}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return BookingResponse.fromJson(json);
      } else {
        return BookingResponse(
          success: false,
          message: 'Failed to cancel booking',
        );
      }
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
      final response = await client.post(
        Uri.parse('$baseUrl/booking/$bookingId/start'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return BookingResponse.fromJson(json);
      } else {
        return BookingResponse(
          success: false,
          message: 'Failed to start booking',
        );
      }
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
      final response = await client.post(
        Uri.parse('$baseUrl/booking/$bookingId/complete'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return BookingResponse.fromJson(json);
      } else {
        return BookingResponse(
          success: false,
          message: 'Failed to complete booking',
        );
      }
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
      final response = await client.get(
        Uri.parse('$baseUrl/booking/$bookingId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return BookingResponse.fromJson(json);
      } else {
        return BookingResponse(
          success: false,
          message: 'Failed to fetch booking details',
        );
      }
    } catch (e) {
      return BookingResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<String> _getAuthToken() async {
    try {
      final token = await localStorage.getItem('auth_token');
      return token ?? '';
    } catch (e) {
      return '';
    }
  }
}
