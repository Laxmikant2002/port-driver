import 'package:equatable/equatable.dart';
import 'trip.dart';
import '../trip_repo.dart';

/// Trip response model for API responses
class TripResponse extends Equatable {
  const TripResponse({
    required this.success,
    this.message,
    this.trip,
    this.trips,
    this.fareBreakdown,
    this.paymentConfirmed = false,
  });

  final bool success;
  final String? message;
  final Trip? trip;
  final List<Trip>? trips;
  final FareBreakdown? fareBreakdown;
  final bool paymentConfirmed;

  factory TripResponse.fromJson(Map<String, dynamic> json) {
    return TripResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      trip: json['trip'] != null
          ? Trip.fromJson(json['trip'] as Map<String, dynamic>)
          : null,
      trips: json['trips'] != null
          ? (json['trips'] as List<dynamic>)
              .map((e) => Trip.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      fareBreakdown: json['fareBreakdown'] != null
          ? FareBreakdown.fromJson(json['fareBreakdown'] as Map<String, dynamic>)
          : null,
      paymentConfirmed: json['paymentConfirmed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'trip': trip?.toJson(),
      'trips': trips?.map((e) => e.toJson()).toList(),
      'fareBreakdown': fareBreakdown?.toJson(),
      'paymentConfirmed': paymentConfirmed,
    };
  }

  TripResponse copyWith({
    bool? success,
    String? message,
    Trip? trip,
    List<Trip>? trips,
    FareBreakdown? fareBreakdown,
    bool? paymentConfirmed,
  }) {
    return TripResponse(
      success: success ?? this.success,
      message: message ?? this.message,
      trip: trip ?? this.trip,
      trips: trips ?? this.trips,
      fareBreakdown: fareBreakdown ?? this.fareBreakdown,
      paymentConfirmed: paymentConfirmed ?? this.paymentConfirmed,
    );
  }

  @override
  List<Object?> get props => [success, message, trip, trips, fareBreakdown, paymentConfirmed];

  @override
  String toString() {
    return 'TripResponse(success: $success, message: $message, trip: $trip, trips: ${trips?.length}, paymentConfirmed: $paymentConfirmed)';
  }
}
