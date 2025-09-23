part of 'booking_bloc.dart';

/// Base class for all Booking events
sealed class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered when booking bloc is initialized
final class BookingInitialized extends BookingEvent {
  const BookingInitialized();

  @override
  String toString() => 'BookingInitialized()';
}

/// Event triggered when a ride request is received
final class RideRequestReceived extends BookingEvent {
  const RideRequestReceived(this.booking);

  final Booking booking;

  @override
  List<Object> get props => [booking];

  @override
  String toString() => 'RideRequestReceived(booking: $booking)';
}

/// Event triggered when a ride is accepted
final class RideAccepted extends BookingEvent {
  const RideAccepted();

  @override
  String toString() => 'RideAccepted()';
}

/// Event triggered when a ride is rejected
final class RideRejected extends BookingEvent {
  const RideRejected();

  @override
  String toString() => 'RideRejected()';
}

/// Event triggered when a trip is started
final class TripStarted extends BookingEvent {
  const TripStarted();

  @override
  String toString() => 'TripStarted()';
}

/// Event triggered when a trip is completed
final class TripCompleted extends BookingEvent {
  const TripCompleted();

  @override
  String toString() => 'TripCompleted()';
}

/// Event triggered when booking form is submitted
final class BookingSubmitted extends BookingEvent {
  const BookingSubmitted(this.action, {this.reason});

  final BookingAction action;
  final String? reason;

  @override
  List<Object> get props => [action, reason ?? ''];

  @override
  String toString() => 'BookingSubmitted(action: $action, reason: $reason)';
}

/// Booking action enum
enum BookingAction {
  accept,
  reject,
  start,
  complete,
}
