import 'package:api_client/api_client.dart';
import 'package:localstorage/localstorage.dart';
import 'package:equatable/equatable.dart';
import 'models/trip.dart';
import 'models/trip_response.dart';
import 'models/booking.dart';
import 'models/booking_response.dart';

/// Trip repository for managing complete ride lifecycle (booking + trip + payments)
class TripRepo {
  const TripRepo({
    required this.apiClient,
    required this.localStorage,
  });

  final ApiClient apiClient;
  final Localstorage localStorage;

  /// Accept a trip request
  Future<TripResponse> acceptTrip(String tripId) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        TripPaths.acceptTrip,
        data: {'tripId': tripId},
      );

      if (response is DataSuccess) {
        final data = response.data!;
        return TripResponse.fromJson(data);
      }

      if (response is DataFailed) {
        return TripResponse(
          success: false,
          message: response.error?.getErrorMessage() ?? 'Failed to accept trip',
        );
      }

      return TripResponse(
        success: false,
        message: 'Unexpected error occurred',
      );
    } catch (e) {
      return TripResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Reject a trip request
  Future<TripResponse> rejectTrip(String tripId, {String? reason}) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        TripPaths.rejectTrip,
        data: {'tripId': tripId, 'reason': reason},
      );

      if (response is DataSuccess) {
        final data = response.data!;
        return TripResponse.fromJson(data);
      }

      if (response is DataFailed) {
        return TripResponse(
          success: false,
          message: response.error?.getErrorMessage() ?? 'Failed to reject trip',
        );
      }

      return TripResponse(
        success: false,
        message: 'Unexpected error occurred',
      );
    } catch (e) {
      return TripResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Update trip status (PICKED_UP, IN_PROGRESS, COMPLETED, etc.)
  Future<TripResponse> updateTripStatus(String tripId, TripStatus status) async {
    try {
      final response = await apiClient.patch<Map<String, dynamic>>(
        TripPaths.updateTripStatus,
        data: {
          'tripId': tripId,
          'status': status.value,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (response is DataSuccess) {
        final data = response.data!;
        return TripResponse.fromJson(data);
      }

      if (response is DataFailed) {
        return TripResponse(
          success: false,
          message: response.error?.getErrorMessage() ?? 'Failed to update trip status',
        );
      }

      return TripResponse(
        success: false,
        message: 'Unexpected error occurred',
      );
    } catch (e) {
      return TripResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Complete a trip
  Future<TripResponse> completeTrip(String tripId) async {
    try {
      final response = await apiClient.patch<Map<String, dynamic>>(
        TripPaths.completeTrip,
        data: {'tripId': tripId},
      );

      if (response is DataSuccess) {
        final data = response.data!;
        return TripResponse.fromJson(data);
      }

      if (response is DataFailed) {
        return TripResponse(
          success: false,
          message: response.error?.getErrorMessage() ?? 'Failed to complete trip',
        );
      }

      return TripResponse(
        success: false,
        message: 'Unexpected error occurred',
      );
    } catch (e) {
      return TripResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Update trip location (for real-time tracking)
  Future<TripResponse> updateTripLocation(String tripId, double lat, double lng) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        TripPaths.updateTripLocation,
        data: {
          'tripId': tripId,
          'lat': lat,
          'lng': lng,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (response is DataSuccess) {
        final data = response.data!;
        return TripResponse.fromJson(data);
      }

      if (response is DataFailed) {
        return TripResponse(
          success: false,
          message: response.error?.getErrorMessage() ?? 'Failed to update trip location',
        );
      }

      return TripResponse(
        success: false,
        message: 'Unexpected error occurred',
      );
    } catch (e) {
      return TripResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get trip earnings
  Future<TripResponse> getTripEarnings(String tripId) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        '${TripPaths.getTripEarnings}/$tripId',
      );

      if (response is DataSuccess) {
        final data = response.data!;
        return TripResponse.fromJson(data);
      }

      if (response is DataFailed) {
        return TripResponse(
          success: false,
          message: response.error?.getErrorMessage() ?? 'Failed to fetch trip earnings',
        );
      }

      return TripResponse(
        success: false,
        message: 'Unexpected error occurred',
      );
    } catch (e) {
      return TripResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Confirm payment for a trip
  Future<TripResponse> confirmPayment({
    required String tripId,
    required PaymentMethod paymentMethod,
    required double amount,
    bool cashReceived = false,
  }) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        TripPaths.confirmPayment,
        data: {
          'tripId': tripId,
          'paymentMethod': paymentMethod.value,
          'amount': amount,
          'cashReceived': cashReceived,
        },
      );

      if (response is DataSuccess) {
        final data = response.data!;
        return TripResponse.fromJson(data);
      }

      if (response is DataFailed) {
        return TripResponse(
          success: false,
          message: response.error?.getErrorMessage() ?? 'Failed to confirm payment',
        );
      }

      return TripResponse(
        success: false,
        message: 'Unexpected error occurred',
      );
    } catch (e) {
      return TripResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Rate a passenger after trip completion
  Future<TripResponse> ratePassenger({
    required String tripId,
    required double rating,
    String? feedback,
  }) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        TripPaths.ratePassenger,
        data: {
          'tripId': tripId,
          'rating': rating,
          'feedback': feedback,
        },
      );

      if (response is DataSuccess) {
        final data = response.data!;
        return TripResponse.fromJson(data);
      }

      if (response is DataFailed) {
        return TripResponse(
          success: false,
          message: response.error?.getErrorMessage() ?? 'Failed to submit rating',
        );
      }

      return TripResponse(
        success: false,
        message: 'Unexpected error occurred',
      );
    } catch (e) {
      return TripResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get trip details
  Future<TripResponse> getTrip(String tripId) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        '${TripPaths.getTripDetails}/$tripId',
      );

      if (response is DataSuccess) {
        final data = response.data!;
        return TripResponse.fromJson(data);
      }

      if (response is DataFailed) {
        return TripResponse(
          success: false,
          message: response.error?.getErrorMessage() ?? 'Failed to fetch trip details',
        );
      }

      return TripResponse(
        success: false,
        message: 'Unexpected error occurred',
      );
    } catch (e) {
      return TripResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get active trip for driver
  Future<TripResponse> getActiveTrip() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        TripPaths.getActiveTrip,
      );

      if (response is DataSuccess) {
        final data = response.data!;
        return TripResponse.fromJson(data);
      }

      if (response is DataFailed) {
        return TripResponse(
          success: false,
          message: response.error?.getErrorMessage() ?? 'Failed to fetch active trip',
        );
      }

      return TripResponse(
        success: false,
        message: 'Unexpected error occurred',
      );
    } catch (e) {
      return TripResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get trip history for driver
  Future<TripResponse> getTripHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        TripPaths.getTripHistory,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response is DataSuccess) {
        final data = response.data!;
        return TripResponse.fromJson(data);
      }

      if (response is DataFailed) {
        return TripResponse(
          success: false,
          message: response.error?.getErrorMessage() ?? 'Failed to fetch trip history',
        );
      }

      return TripResponse(
        success: false,
        message: 'Unexpected error occurred',
      );
    } catch (e) {
      return TripResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // ============ LEGACY BOOKING METHODS (DEPRECATED) ============
  // These methods are kept for backward compatibility but should use trip methods instead

  /// Get available bookings for driver (DEPRECATED - use getActiveTrip instead)
  @Deprecated('Use getActiveTrip() instead')
  Future<BookingResponse> getAvailableBookings() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(TripPaths.getAvailableBookings);

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

  /// Accept a booking (DEPRECATED - use acceptTrip instead)
  @Deprecated('Use acceptTrip() instead')
  Future<BookingResponse> acceptBooking(String bookingId) async {
    return await acceptTrip(bookingId);
  }

  /// Reject a booking (DEPRECATED - use rejectTrip instead)
  @Deprecated('Use rejectTrip() instead')
  Future<BookingResponse> rejectBooking(String bookingId, {String? reason}) async {
    return await rejectTrip(bookingId, reason: reason);
  }

  /// Start a booking (transition from booking to trip)
  Future<BookingResponse> startBooking(String bookingId) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        TripPaths.startBooking,
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
        TripPaths.completeBooking,
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
      final response = await apiClient.get<Map<String, dynamic>>('${TripPaths.getTripDetails}/$bookingId');

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

  /// Mark cash trip as collected by driver
  Future<BookingResponse> markCashCollected(String tripId, double amount) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        TripPaths.markCashCollected,
        data: {
          'tripId': tripId,
          'amount': amount,
          'collectedAt': DateTime.now().toIso8601String(),
        },
      );

      if (response is DataSuccess) {
        final data = response.data!;
        return BookingResponse.fromJson(data);
      }

      if (response is DataFailed) {
        return BookingResponse(
          success: false,
          message: response.error?.getErrorMessage() ?? 'Failed to mark cash collected',
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

  /// Get driver's cash trips
  Future<BookingResponse> getCashTrips({DateTime? date}) async {
    try {
      final queryParams = <String, String>{};
      if (date != null) queryParams['date'] = date.toIso8601String();

      final uri = queryParams.isNotEmpty 
          ? '${TripPaths.getCashTrips}?${Uri(queryParameters: queryParams).query}'
          : TripPaths.getCashTrips;
          
      final response = await apiClient.get<Map<String, dynamic>>(uri);

      if (response is DataSuccess) {
        final data = response.data!;
        return BookingResponse.fromJson(data);
      }

      if (response is DataFailed) {
        return BookingResponse(
          success: false,
          message: response.error?.getErrorMessage() ?? 'Failed to fetch cash trips',
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

/// Trip status enum for modern trip lifecycle
enum TripStatus {
  pending('PENDING', 'Pending'),
  accepted('ACCEPTED', 'Accepted'),
  driverArrived('DRIVER_ARRIVED', 'Driver Arrived'),
  pickedUp('PICKED_UP', 'Picked Up'),
  inProgress('IN_PROGRESS', 'In Progress'),
  completed('COMPLETED', 'Completed'),
  cancelled('CANCELLED', 'Cancelled'),
  rejected('REJECTED', 'Rejected');

  const TripStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  static TripStatus fromString(String value) {
    return TripStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => throw ArgumentError('Unknown trip status: $value'),
    );
  }
}

/// Payment method enum
enum PaymentMethod {
  cash('cash', 'Cash'),
  online('online', 'Online Payment'),
  wallet('wallet', 'Wallet');

  const PaymentMethod(this.value, this.displayName);

  final String value;
  final String displayName;

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (method) => method.value == value,
      orElse: () => throw ArgumentError('Unknown payment method: $value'),
    );
  }
}

/// Fare breakdown model
class FareBreakdown extends Equatable {
  const FareBreakdown({
    required this.baseFare,
    required this.distanceFare,
    required this.timeFare,
    required this.surgeMultiplier,
    required this.commission,
    required this.totalFare,
    required this.netPayout,
    this.tip = 0.0,
    this.discount = 0.0,
  });

  final double baseFare;
  final double distanceFare;
  final double timeFare;
  final double surgeMultiplier;
  final double commission;
  final double totalFare;
  final double netPayout;
  final double tip;
  final double discount;

  factory FareBreakdown.fromJson(Map<String, dynamic> json) {
    return FareBreakdown(
      baseFare: (json['baseFare'] as num).toDouble(),
      distanceFare: (json['distanceFare'] as num).toDouble(),
      timeFare: (json['timeFare'] as num).toDouble(),
      surgeMultiplier: (json['surgeMultiplier'] as num).toDouble(),
      commission: (json['commission'] as num).toDouble(),
      totalFare: (json['totalFare'] as num).toDouble(),
      netPayout: (json['netPayout'] as num).toDouble(),
      tip: (json['tip'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baseFare': baseFare,
      'distanceFare': distanceFare,
      'timeFare': timeFare,
      'surgeMultiplier': surgeMultiplier,
      'commission': commission,
      'totalFare': totalFare,
      'netPayout': netPayout,
      'tip': tip,
      'discount': discount,
    };
  }

  @override
  List<Object?> get props => [
        baseFare,
        distanceFare,
        timeFare,
        surgeMultiplier,
        commission,
        totalFare,
        netPayout,
        tip,
        discount,
      ];
}