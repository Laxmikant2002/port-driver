import 'package:equatable/equatable.dart';

enum BookingStatus {
  pending,
  accepted,
  started,
  completed,
  cancelled,
}

enum PaymentMode {
  online('ONLINE'),
  cash('CASH'),
  card('CARD'),
  wallet('WALLET');

  const PaymentMode(this.value);
  final String value;
}

enum PaymentStatus {
  completed('COMPLETED'),
  pending('PENDING'),
  failed('FAILED');

  const PaymentStatus(this.value);
  final String value;
}

/// Location model for booking
class BookingLocation extends Equatable {
  const BookingLocation({
    required this.address,
    required this.latitude,
    required this.longitude,
    this.landmark,
  });

  final String address;
  final double latitude;
  final double longitude;
  final String? landmark;

  @override
  List<Object?> get props => [address, latitude, longitude, landmark];
}

class Booking extends Equatable {
  final String id;
  final String? passengerId;
  final String? driverId;
  final BookingStatus status;
  final BookingLocation pickupLocation;
  final BookingLocation dropoffLocation;
  final double fare;
  final double distance;
  final int estimatedDuration;
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
  
  // Derived properties for local model
  final double amount;
  final PaymentMode paymentMode;
  final PaymentStatus paymentStatus;
  final double netEarnings;
  final double commission;
  final double distanceKm;
  final int durationMinutes;
  final String pickupAddress;
  final String dropoffAddress;
  final String customerName;

  const Booking({
    required this.id,
    this.passengerId,
    this.driverId,
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
    // Derived properties
    required this.amount,
    required this.paymentMode,
    required this.paymentStatus,
    required this.netEarnings,
    required this.commission,
    required this.distanceKm,
    required this.durationMinutes,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.customerName,
  });

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
    double? amount,
    PaymentMode? paymentMode,
    PaymentStatus? paymentStatus,
    double? netEarnings,
    double? commission,
    double? distanceKm,
    int? durationMinutes,
    String? pickupAddress,
    String? dropoffAddress,
    String? customerName,
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
      amount: amount ?? this.amount,
      paymentMode: paymentMode ?? this.paymentMode,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      netEarnings: netEarnings ?? this.netEarnings,
      commission: commission ?? this.commission,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      customerName: customerName ?? this.customerName,
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
        amount,
        paymentMode,
        paymentStatus,
        netEarnings,
        commission,
        distanceKm,
        durationMinutes,
        pickupAddress,
        dropoffAddress,
        customerName,
      ];
}
