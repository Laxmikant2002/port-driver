import 'package:equatable/equatable.dart';

abstract class TripEvent extends Equatable {
  const TripEvent();

  @override
  List<Object?> get props => [];
}

enum TripCategory { all, scheduled, waterSports }

class TripCategorySelected extends TripEvent {
  final TripCategory category;
  const TripCategorySelected(this.category);

  @override
  List<Object?> get props => [category];
}

class PaymentStatusUpdated extends TripEvent {
  final bool isPaid;
  const PaymentStatusUpdated(this.isPaid);

  @override
  List<Object?> get props => [isPaid];
}


class MarkArrivedPressed extends TripEvent {
  final int tripId; 
  const MarkArrivedPressed({required this.tripId});

  @override
  List<Object?> get props => [tripId];
}

class MarkArrivedReleased extends TripEvent {
  final int tripId; 
  const MarkArrivedReleased({required this.tripId});

  @override
  List<Object?> get props => [tripId];
}

class ContactGuestPressed extends TripEvent {
  final int tripId;
  const ContactGuestPressed({required this.tripId});

  @override
  List<Object?> get props => [tripId];
}

class ContactGuestReleased extends TripEvent {
  final int tripId; 
  const ContactGuestReleased({required this.tripId});

  @override
  List<Object?> get props => [tripId];
}

