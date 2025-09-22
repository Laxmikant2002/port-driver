import 'package:equatable/equatable.dart';
import 'trip.dart';

/// Trip response model for API responses
class TripResponse extends Equatable {
  const TripResponse({
    required this.success,
    this.message,
    this.trip,
    this.trips,
  });

  final bool success;
  final String? message;
  final Trip? trip;
  final List<Trip>? trips;

  factory TripResponse.fromJson(Map<String, dynamic> json) {
    return TripResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      trip: json['trip'] != null
          ? Trip.fromJson(json['trip'] as Map<String, dynamic>)
          : null,
      trips: json['trips'] != null
          ? (json['trips'] as List<dynamic>)
              .map((e) => Trip.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'trip': trip?.toJson(),
      'trips': trips?.map((e) => e.toJson()).toList(),
    };
  }

  TripResponse copyWith({
    bool? success,
    String? message,
    Trip? trip,
    List<Trip>? trips,
  }) {
    return TripResponse(
      success: success ?? this.success,
      message: message ?? this.message,
      trip: trip ?? this.trip,
      trips: trips ?? this.trips,
    );
  }

  @override
  List<Object?> get props => [success, message, trip, trips];

  @override
  String toString() {
    return 'TripResponse(success: $success, message: $message, trip: $trip, trips: ${trips?.length})';
  }
}
