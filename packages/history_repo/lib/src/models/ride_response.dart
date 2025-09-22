import 'package:equatable/equatable.dart';
import 'ride.dart';

/// Ride response model for API responses
class RideResponse extends Equatable {
  const RideResponse({
    required this.success,
    this.message,
    this.rides,
    this.singleRide,
    this.statistics,
  });

  final bool success;
  final String? message;
  final List<Ride>? rides;
  final Ride? singleRide;
  final RideStatistics? statistics;

  factory RideResponse.fromJson(Map<String, dynamic> json) {
    return RideResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      rides: json['rides'] != null
          ? (json['rides'] as List<dynamic>)
              .map((e) => Ride.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      singleRide: json['singleRide'] != null
          ? Ride.fromJson(json['singleRide'] as Map<String, dynamic>)
          : null,
      statistics: json['statistics'] != null
          ? RideStatistics.fromJson(json['statistics'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'rides': rides?.map((e) => e.toJson()).toList(),
      'singleRide': singleRide?.toJson(),
      'statistics': statistics?.toJson(),
    };
  }

  RideResponse copyWith({
    bool? success,
    String? message,
    List<Ride>? rides,
    Ride? singleRide,
    RideStatistics? statistics,
  }) {
    return RideResponse(
      success: success ?? this.success,
      message: message ?? this.message,
      rides: rides ?? this.rides,
      singleRide: singleRide ?? this.singleRide,
      statistics: statistics ?? this.statistics,
    );
  }

  @override
  List<Object?> get props => [success, message, rides, singleRide, statistics];

  @override
  String toString() {
    return 'RideResponse(success: $success, message: $message, rides: ${rides?.length}, statistics: $statistics)';
  }
}
