import 'package:equatable/equatable.dart';

class SummaryState extends Equatable {
  final String guestName;
  final String pickupLocation;
  final String dropLocation;
  final String timeRange;
  final double distance;
  final int durationMinutes;
  final double price;
  final String paymentMethod;
  final bool tripCompleted;

  const SummaryState({
    required this.guestName,
    required this.pickupLocation,
    required this.dropLocation,
    required this.timeRange,
    required this.distance,
    required this.durationMinutes,
    required this.price,
    required this.paymentMethod,
    this.tripCompleted = false,
  });

  factory SummaryState.initial() {
    return const SummaryState(
      guestName: '',
      pickupLocation: '',
      dropLocation: '',
      timeRange: '',
      distance: 0.0,
      durationMinutes: 0,
      price: 0.0,
      paymentMethod: '',
    );
  }

  SummaryState copyWith({
    String? guestName,
    String? pickupLocation,
    String? dropLocation,
    String? timeRange,
    double? distance,
    int? durationMinutes,
    double? price,
    String? paymentMethod,
    bool? tripCompleted,
  }) {
    return SummaryState(
      guestName: guestName ?? this.guestName,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropLocation: dropLocation ?? this.dropLocation,
      timeRange: timeRange ?? this.timeRange,
      distance: distance ?? this.distance,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      price: price ?? this.price,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      tripCompleted: tripCompleted ?? this.tripCompleted,
    );
  }

  @override
  List<Object?> get props => [
        guestName,
        pickupLocation,
        dropLocation,
        timeRange,
        distance,
        durationMinutes,
        price,
        paymentMethod,
        tripCompleted,
      ];
}
