import 'package:equatable/equatable.dart';

/// Ride model for ride history
class Ride extends Equatable {
  const Ride({
    required this.id,
    required this.driverId,
    required this.passengerId,
    required this.status,
    required this.startLocation,
    required this.endLocation,
    required this.fare,
    required this.distance,
    required this.duration,
    required this.createdAt,
    this.passengerName,
    this.passengerPhone,
    this.passengerPhoto,
    this.vehicleType,
    this.paymentMethod,
    this.rating,
    this.completedAt,
    this.cancelledAt,
    this.metadata,
  });

  final String id;
  final String driverId;
  final String passengerId;
  final RideStatus status;
  final RideLocation startLocation;
  final RideLocation endLocation;
  final double fare;
  final double distance;
  final int duration; // in minutes
  final DateTime createdAt;
  final String? passengerName;
  final String? passengerPhone;
  final String? passengerPhoto;
  final String? vehicleType;
  final String? paymentMethod;
  final double? rating;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final Map<String, dynamic>? metadata;

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      id: json['id'] as String,
      driverId: json['driverId'] as String,
      passengerId: json['passengerId'] as String,
      status: RideStatus.fromString(json['status'] as String),
      startLocation: RideLocation.fromJson(json['startLocation'] as Map<String, dynamic>),
      endLocation: RideLocation.fromJson(json['endLocation'] as Map<String, dynamic>),
      fare: (json['fare'] as num).toDouble(),
      distance: (json['distance'] as num).toDouble(),
      duration: json['duration'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      passengerName: json['passengerName'] as String?,
      passengerPhone: json['passengerPhone'] as String?,
      passengerPhoto: json['passengerPhoto'] as String?,
      vehicleType: json['vehicleType'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String) 
          : null,
      cancelledAt: json['cancelledAt'] != null 
          ? DateTime.parse(json['cancelledAt'] as String) 
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driverId': driverId,
      'passengerId': passengerId,
      'status': status.value,
      'startLocation': startLocation.toJson(),
      'endLocation': endLocation.toJson(),
      'fare': fare,
      'distance': distance,
      'duration': duration,
      'createdAt': createdAt.toIso8601String(),
      'passengerName': passengerName,
      'passengerPhone': passengerPhone,
      'passengerPhoto': passengerPhoto,
      'vehicleType': vehicleType,
      'paymentMethod': paymentMethod,
      'rating': rating,
      'completedAt': completedAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  Ride copyWith({
    String? id,
    String? driverId,
    String? passengerId,
    RideStatus? status,
    RideLocation? startLocation,
    RideLocation? endLocation,
    double? fare,
    double? distance,
    int? duration,
    DateTime? createdAt,
    String? passengerName,
    String? passengerPhone,
    String? passengerPhoto,
    String? vehicleType,
    String? paymentMethod,
    double? rating,
    DateTime? completedAt,
    DateTime? cancelledAt,
    Map<String, dynamic>? metadata,
  }) {
    return Ride(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      passengerId: passengerId ?? this.passengerId,
      status: status ?? this.status,
      startLocation: startLocation ?? this.startLocation,
      endLocation: endLocation ?? this.endLocation,
      fare: fare ?? this.fare,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      passengerName: passengerName ?? this.passengerName,
      passengerPhone: passengerPhone ?? this.passengerPhone,
      passengerPhoto: passengerPhoto ?? this.passengerPhoto,
      vehicleType: vehicleType ?? this.vehicleType,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      rating: rating ?? this.rating,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        driverId,
        passengerId,
        status,
        startLocation,
        endLocation,
        fare,
        distance,
        duration,
        createdAt,
        passengerName,
        passengerPhone,
        passengerPhoto,
        vehicleType,
        paymentMethod,
        rating,
        completedAt,
        cancelledAt,
        metadata,
      ];

  @override
  String toString() {
    return 'Ride('
        'id: $id, '
        'passengerName: $passengerName, '
        'status: $status, '
        'fare: $fare, '
        'createdAt: $createdAt'
        ')';
  }
}

/// Ride location model
class RideLocation extends Equatable {
  const RideLocation({
    required this.address,
    required this.latitude,
    required this.longitude,
    this.landmark,
  });

  final String address;
  final double latitude;
  final double longitude;
  final String? landmark;

  factory RideLocation.fromJson(Map<String, dynamic> json) {
    return RideLocation(
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      landmark: json['landmark'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'landmark': landmark,
    };
  }

  RideLocation copyWith({
    String? address,
    double? latitude,
    double? longitude,
    String? landmark,
  }) {
    return RideLocation(
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      landmark: landmark ?? this.landmark,
    );
  }

  @override
  List<Object?> get props => [address, latitude, longitude, landmark];
}

/// Ride status enum
enum RideStatus {
  requested('requested', 'Requested'),
  accepted('accepted', 'Accepted'),
  started('started', 'Started'),
  completed('completed', 'Completed'),
  cancelled('cancelled', 'Cancelled');

  const RideStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  static RideStatus fromString(String value) {
    return RideStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => throw ArgumentError('Unknown ride status: $value'),
    );
  }
}

/// Ride statistics model
class RideStatistics extends Equatable {
  const RideStatistics({
    required this.totalRides,
    required this.completedRides,
    required this.cancelledRides,
    required this.totalEarnings,
    required this.averageRating,
    required this.totalDistance,
    required this.totalDuration,
    this.period,
  });

  final int totalRides;
  final int completedRides;
  final int cancelledRides;
  final double totalEarnings;
  final double averageRating;
  final double totalDistance;
  final int totalDuration; // in minutes
  final String? period;

  factory RideStatistics.fromJson(Map<String, dynamic> json) {
    return RideStatistics(
      totalRides: json['totalRides'] as int,
      completedRides: json['completedRides'] as int,
      cancelledRides: json['cancelledRides'] as int,
      totalEarnings: (json['totalEarnings'] as num).toDouble(),
      averageRating: (json['averageRating'] as num).toDouble(),
      totalDistance: (json['totalDistance'] as num).toDouble(),
      totalDuration: json['totalDuration'] as int,
      period: json['period'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalRides': totalRides,
      'completedRides': completedRides,
      'cancelledRides': cancelledRides,
      'totalEarnings': totalEarnings,
      'averageRating': averageRating,
      'totalDistance': totalDistance,
      'totalDuration': totalDuration,
      'period': period,
    };
  }

  @override
  List<Object?> get props => [
        totalRides,
        completedRides,
        cancelledRides,
        totalEarnings,
        averageRating,
        totalDistance,
        totalDuration,
        period,
      ];
}
