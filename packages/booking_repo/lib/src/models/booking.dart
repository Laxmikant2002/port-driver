import 'package:equatable/equatable.dart';

/// Booking model for ride bookings
class Booking extends Equatable {
  const Booking({
    required this.id,
    required this.passengerId,
    required this.driverId,
    required this.status,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.fare,
    required this.distance,
    required this.estimatedDuration,
    required this.createdAt,
    this.passengerName,
    this.passengerPhone,
    this.passengerPhoto,
    this.vehicleType,
    this.paymentMethod,
    this.scheduledTime,
    this.acceptedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.rating,
    this.metadata,
  });

  final String id;
  final String passengerId;
  final String driverId;
  final BookingStatus status;
  final BookingLocation pickupLocation;
  final BookingLocation dropoffLocation;
  final double fare;
  final double distance;
  final int estimatedDuration; // in minutes
  final DateTime createdAt;
  final String? passengerName;
  final String? passengerPhone;
  final String? passengerPhoto;
  final String? vehicleType;
  final String? paymentMethod;
  final DateTime? scheduledTime;
  final DateTime? acceptedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final double? rating;
  final Map<String, dynamic>? metadata;

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      passengerId: json['passengerId'] as String,
      driverId: json['driverId'] as String,
      status: BookingStatus.fromString(json['status'] as String),
      pickupLocation: BookingLocation.fromJson(json['pickupLocation'] as Map<String, dynamic>),
      dropoffLocation: BookingLocation.fromJson(json['dropoffLocation'] as Map<String, dynamic>),
      fare: (json['fare'] as num).toDouble(),
      distance: (json['distance'] as num).toDouble(),
      estimatedDuration: json['estimatedDuration'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      passengerName: json['passengerName'] as String?,
      passengerPhone: json['passengerPhone'] as String?,
      passengerPhoto: json['passengerPhoto'] as String?,
      vehicleType: json['vehicleType'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      scheduledTime: json['scheduledTime'] != null 
          ? DateTime.parse(json['scheduledTime'] as String) 
          : null,
      acceptedAt: json['acceptedAt'] != null 
          ? DateTime.parse(json['acceptedAt'] as String) 
          : null,
      startedAt: json['startedAt'] != null 
          ? DateTime.parse(json['startedAt'] as String) 
          : null,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String) 
          : null,
      cancelledAt: json['cancelledAt'] != null 
          ? DateTime.parse(json['cancelledAt'] as String) 
          : null,
      cancellationReason: json['cancellationReason'] as String?,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'passengerId': passengerId,
      'driverId': driverId,
      'status': status.value,
      'pickupLocation': pickupLocation.toJson(),
      'dropoffLocation': dropoffLocation.toJson(),
      'fare': fare,
      'distance': distance,
      'estimatedDuration': estimatedDuration,
      'createdAt': createdAt.toIso8601String(),
      'passengerName': passengerName,
      'passengerPhone': passengerPhone,
      'passengerPhoto': passengerPhoto,
      'vehicleType': vehicleType,
      'paymentMethod': paymentMethod,
      'scheduledTime': scheduledTime?.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'cancellationReason': cancellationReason,
      'rating': rating,
      'metadata': metadata,
    };
  }

  Booking copyWith({
    String? id,
    String? passengerId,
    String? driverId,
    BookingStatus? status,
    BookingLocation? pickupLocation,
    BookingLocation? dropoffLocation,
    double? fare,
    double? distance,
    int? estimatedDuration,
    DateTime? createdAt,
    String? passengerName,
    String? passengerPhone,
    String? passengerPhoto,
    String? vehicleType,
    String? paymentMethod,
    DateTime? scheduledTime,
    DateTime? acceptedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    double? rating,
    Map<String, dynamic>? metadata,
  }) {
    return Booking(
      id: id ?? this.id,
      passengerId: passengerId ?? this.passengerId,
      driverId: driverId ?? this.driverId,
      status: status ?? this.status,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      fare: fare ?? this.fare,
      distance: distance ?? this.distance,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      createdAt: createdAt ?? this.createdAt,
      passengerName: passengerName ?? this.passengerName,
      passengerPhone: passengerPhone ?? this.passengerPhone,
      passengerPhoto: passengerPhoto ?? this.passengerPhoto,
      vehicleType: vehicleType ?? this.vehicleType,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      rating: rating ?? this.rating,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        passengerId,
        driverId,
        status,
        pickupLocation,
        dropoffLocation,
        fare,
        distance,
        estimatedDuration,
        createdAt,
        passengerName,
        passengerPhone,
        passengerPhoto,
        vehicleType,
        paymentMethod,
        scheduledTime,
        acceptedAt,
        startedAt,
        completedAt,
        cancelledAt,
        cancellationReason,
        rating,
        metadata,
      ];

  @override
  String toString() {
    return 'Booking('
        'id: $id, '
        'passengerName: $passengerName, '
        'status: $status, '
        'fare: $fare, '
        'createdAt: $createdAt'
        ')';
  }
}

/// Booking location model
class BookingLocation extends Equatable {
  const BookingLocation({
    required this.address,
    required this.latitude,
    required this.longitude,
    this.landmark,
    this.instructions,
  });

  final String address;
  final double latitude;
  final double longitude;
  final String? landmark;
  final String? instructions;

  factory BookingLocation.fromJson(Map<String, dynamic> json) {
    return BookingLocation(
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      landmark: json['landmark'] as String?,
      instructions: json['instructions'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'landmark': landmark,
      'instructions': instructions,
    };
  }

  BookingLocation copyWith({
    String? address,
    double? latitude,
    double? longitude,
    String? landmark,
    String? instructions,
  }) {
    return BookingLocation(
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      landmark: landmark ?? this.landmark,
      instructions: instructions ?? this.instructions,
    );
  }

  @override
  List<Object?> get props => [address, latitude, longitude, landmark, instructions];
}

/// Booking status enum
enum BookingStatus {
  pending('pending', 'Pending'),
  accepted('accepted', 'Accepted'),
  started('started', 'Started'),
  completed('completed', 'Completed'),
  cancelled('cancelled', 'Cancelled');

  const BookingStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  static BookingStatus fromString(String value) {
    return BookingStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => throw ArgumentError('Unknown booking status: $value'),
    );
  }
}
