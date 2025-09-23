import 'package:api_client/api_client.dart';
import 'package:localstorage/localstorage.dart';
import 'package:equatable/equatable.dart';
import 'models/trip.dart';
import 'models/trip_response.dart';

/// Trip repository for managing trip lifecycle and payments
class TripRepo {
  const TripRepo({
    required this.apiClient,
    required this.localStorage,
  });

  final ApiClient apiClient;
  final Localstorage localStorage;

  /// Start a trip
  Future<TripResponse> startTrip(String tripId) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        '/rides/start',
        data: {'tripId': tripId},
      );

      if (response is DataSuccess) {
        final data = response.data!;
        return TripResponse.fromJson(data);
      }

      if (response is DataFailed) {
        return TripResponse(
          success: false,
          message: response.error?.getErrorMessage() ?? 'Failed to start trip',
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

  /// End a trip
  Future<TripResponse> endTrip(String tripId) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        '/rides/end',
        data: {'tripId': tripId},
      );

      if (response is DataSuccess) {
        final data = response.data!;
        return TripResponse.fromJson(data);
      }

      if (response is DataFailed) {
        return TripResponse(
          success: false,
          message: response.error?.getErrorMessage() ?? 'Failed to end trip',
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
        '/rides/payment',
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
        '/rides/rate',
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
      final response = await apiClient.get<Map<String, dynamic>>('/rides/$tripId');

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

  /// Get active trips for driver
  Future<TripResponse> getActiveTrips() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>('/rides/active');

      if (response is DataSuccess) {
        final data = response.data!;
        return TripResponse.fromJson(data);
      }

      if (response is DataFailed) {
        return TripResponse(
          success: false,
          message: response.error?.getErrorMessage() ?? 'Failed to fetch active trips',
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
        '/rides/history',
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