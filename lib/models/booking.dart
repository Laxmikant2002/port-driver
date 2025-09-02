import 'package:equatable/equatable.dart';

enum BookingStatus {
  confirmed,
  checkedIn,
  completed,
  noShow,
  cancelled,
}

class Booking extends Equatable {
  final String id;
  final String customerName;
  final String customerPhone;
  final int peopleCount;
  final double amount;
  final BookingStatus status;
  final DateTime createdAt;

  const Booking({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.peopleCount,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  Booking copyWith({
    String? id,
    String? customerName,
    String? customerPhone,
    int? peopleCount,
    double? amount,
    BookingStatus? status,
    DateTime? createdAt,
  }) {
    return Booking(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      peopleCount: peopleCount ?? this.peopleCount,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
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
      ];
}
