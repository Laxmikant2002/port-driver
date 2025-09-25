import 'package:equatable/equatable.dart';

enum BookingStatus {
  confirmed,
  checkedIn,
  completed,
  noShow,
  cancelled,
}

enum PaymentMode {
  online('ONLINE'),
  cash('CASH');

  const PaymentMode(this.value);
  final String value;
}

enum PaymentStatus {
  paid('PAID'),
  pending('PENDING'),
  failed('FAILED');

  const PaymentStatus(this.value);
  final String value;
}

class Booking extends Equatable {
  final String id;
  final String customerName;
  final String customerPhone;
  final int peopleCount;
  final double amount;
  final BookingStatus status;
  final DateTime createdAt;
  // Payment fields
  final PaymentMode paymentMode;
  final PaymentStatus paymentStatus;
  final double? fare;
  final double? commission;
  final double? netEarnings;
  final double? baseFare;
  final double? perKmRate;
  final double? distanceKm;
  final int? durationMinutes;

  const Booking({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.peopleCount,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.paymentMode = PaymentMode.online,
    this.paymentStatus = PaymentStatus.pending,
    this.fare,
    this.commission,
    this.netEarnings,
    this.baseFare,
    this.perKmRate,
    this.distanceKm,
    this.durationMinutes,
  });

  Booking copyWith({
    String? id,
    String? customerName,
    String? customerPhone,
    int? peopleCount,
    double? amount,
    BookingStatus? status,
    DateTime? createdAt,
    PaymentMode? paymentMode,
    PaymentStatus? paymentStatus,
    double? fare,
    double? commission,
    double? netEarnings,
    double? baseFare,
    double? perKmRate,
    double? distanceKm,
    int? durationMinutes,
  }) {
    return Booking(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      peopleCount: peopleCount ?? this.peopleCount,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      paymentMode: paymentMode ?? this.paymentMode,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      fare: fare ?? this.fare,
      commission: commission ?? this.commission,
      netEarnings: netEarnings ?? this.netEarnings,
      baseFare: baseFare ?? this.baseFare,
      perKmRate: perKmRate ?? this.perKmRate,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMinutes: durationMinutes ?? this.durationMinutes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        customerName,
        customerPhone,
        peopleCount,
        amount,
        status,
        createdAt,
        paymentMode,
        paymentStatus,
        fare,
        commission,
        netEarnings,
        baseFare,
        perKmRate,
        distanceKm,
        durationMinutes,
      ];
}
