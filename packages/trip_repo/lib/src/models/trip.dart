import 'package:equatable/equatable.dart';

/// Trip model for active trips
class Trip extends Equatable {
  const Trip({
    required this.id,
    required this.bookingId,
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
    this.startedAt,
    this.completedAt,
    this.actualFare,
    this.tip,
    this.rating,
    this.route,
    this.metadata,
  });

  final String id;
  final String bookingId;
  final String driverId;
  final String passengerId;
  final TripStatus status;
  final TripLocation startLocation;
  final TripLocation endLocation;
  final double fare;
  final double distance;
  final int duration; // in minutes
  final DateTime createdAt;
  final String? passengerName;
  final String? passengerPhone;
  final String? passengerPhoto;
  final String? vehicleType;
  final String? paymentMethod;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final double? actualFare;
  final double? tip;
  final double? rating;
  final List<TripLocation>? route;
  final Map<String, dynamic>? metadata;

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      driverId: json['driverId'] as String,
      passengerId: json['passengerId'] as String,
      status: TripStatus.fromString(json['status'] as String),
      startLocation: TripLocation.fromJson(json['startLocation'] as Map<String, dynamic>),
      endLocation: TripLocation.fromJson(json['endLocation'] as Map<String, dynamic>),
      fare: (json['fare'] as num).toDouble(),
      distance: (json['distance'] as num).toDouble(),
      duration: json['duration'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      passengerName: json['passengerName'] as String?,
      passengerPhone: json['passengerPhone'] as String?,
      passengerPhoto: json['passengerPhoto'] as String?,
      vehicleType: json['vehicleType'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      startedAt: json['startedAt'] != null 
          ? DateTime.parse(json['startedAt'] as String) 
          : null,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String) 
          : null,
      actualFare: json['actualFare'] != null ? (json['actualFare'] as num).toDouble() : null,
      tip: json['tip'] != null ? (json['tip'] as num).toDouble() : null,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      route: json['route'] != null
          ? (json['route'] as List<dynamic>)
              .map((e) => TripLocation.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
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
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'actualFare': actualFare,
      'tip': tip,
      'rating': rating,
      'route': route?.map((e) => e.toJson()).toList(),
      'metadata': metadata,
    };
  }

  Trip copyWith({
    String? id,
    String? bookingId,
    String? driverId,
    String? passengerId,
    TripStatus? status,
    TripLocation? startLocation,
    TripLocation? endLocation,
    double? fare,
    double? distance,
    int? duration,
    DateTime? createdAt,
    String? passengerName,
    String? passengerPhone,
    String? passengerPhoto,
    String? vehicleType,
    String? paymentMethod,
    DateTime? startedAt,
    DateTime? completedAt,
    double? actualFare,
    double? tip,
    double? rating,
    List<TripLocation>? route,
    Map<String, dynamic>? metadata,
  }) {
    return Trip(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
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
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      actualFare: actualFare ?? this.actualFare,
      tip: tip ?? this.tip,
      rating: rating ?? this.rating,
      route: route ?? this.route,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        bookingId,
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
        startedAt,
        completedAt,
        actualFare,
        tip,
        rating,
        route,
        metadata,
      ];

  @override
  String toString() {
    return 'Trip('
        'id: $id, '
        'passengerName: $passengerName, '
        'status: $status, '
        'fare: $fare, '
        'createdAt: $createdAt'
        ')';
  }
}

/// Trip location model
class TripLocation extends Equatable {
  const TripLocation({
    required this.latitude,
    required this.longitude,
    this.address,
    this.timestamp,
  });

  final double latitude;
  final double longitude;
  final String? address;
  final DateTime? timestamp;

  factory TripLocation.fromJson(Map<String, dynamic> json) {
    return TripLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'timestamp': timestamp?.toIso8601String(),
    };
  }

  TripLocation copyWith({
    double? latitude,
    double? longitude,
    String? address,
    DateTime? timestamp,
  }) {
    return TripLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props => [latitude, longitude, address, timestamp];
}

/// Trip status enum
enum TripStatus {
  active('active', 'Active'),
  completed('completed', 'Completed'),
  cancelled('cancelled', 'Cancelled');

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
