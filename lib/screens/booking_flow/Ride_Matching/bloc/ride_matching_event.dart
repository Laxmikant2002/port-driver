part of 'ride_matching_bloc.dart';

/// Base class for all Ride Matching events
sealed class RideMatchingEvent extends Equatable {
  const RideMatchingEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered when ride matching bloc is initialized
final class RideMatchingInitialized extends RideMatchingEvent {
  const RideMatchingInitialized();

  @override
  String toString() => 'RideMatchingInitialized()';
}

/// Event triggered when a ride request is received
final class RideRequestReceived extends RideMatchingEvent {
  const RideRequestReceived(this.booking);

  final Booking booking;

  @override
  List<Object> get props => [booking];

  @override
  String toString() => 'RideRequestReceived(booking: $booking)';
}

/// Event triggered when driver accepts a ride
final class RideAccepted extends RideMatchingEvent {
  const RideAccepted();

  @override
  String toString() => 'RideAccepted()';
}

/// Event triggered when driver rejects a ride
final class RideRejected extends RideMatchingEvent {
  const RideRejected();

  @override
  String toString() => 'RideRejected()';
}

/// Event triggered when ride request form is submitted
final class RideRequestSubmitted extends RideMatchingEvent {
  const RideRequestSubmitted();

  @override
  String toString() => 'RideRequestSubmitted()';
}

/// Event triggered on timer tick
final class TimerTick extends RideMatchingEvent {
  const TimerTick();

  @override
  String toString() => 'TimerTick()';
}

/// Event triggered when ride request expires
final class RideRequestExpired extends RideMatchingEvent {
  const RideRequestExpired();

  @override
  String toString() => 'RideRequestExpired()';
}
