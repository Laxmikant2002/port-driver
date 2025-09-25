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

/// Event triggered when an incoming ride request is received
final class IncomingRideRequest extends RideMatchingEvent {
  const IncomingRideRequest(this.booking);

  final Booking booking;

  @override
  List<Object> get props => [booking];

  @override
  String toString() => 'IncomingRideRequest(booking: $booking)';
}

/// Event triggered when a ride request is accepted
final class RideRequestAccepted extends RideMatchingEvent {
  const RideRequestAccepted();

  @override
  String toString() => 'RideRequestAccepted()';
}

/// Event triggered when a ride request is rejected
final class RideRequestRejected extends RideMatchingEvent {
  const RideRequestRejected(this.reason);

  final String reason;

  @override
  List<Object> get props => [reason];

  @override
  String toString() => 'RideRequestRejected(reason: $reason)';
}

/// Event triggered when a ride request times out
final class RideRequestTimeout extends RideMatchingEvent {
  const RideRequestTimeout();

  @override
  String toString() => 'RideRequestTimeout()';
}

/// Event triggered when driver arrives at pickup location
final class DriverArrivedAtPickup extends RideMatchingEvent {
  const DriverArrivedAtPickup();

  @override
  String toString() => 'DriverArrivedAtPickup()';
}

/// Event triggered when trip is started
final class TripStarted extends RideMatchingEvent {
  const TripStarted();

  @override
  String toString() => 'TripStarted()';
}

/// Event triggered when trip is completed
final class TripCompleted extends RideMatchingEvent {
  const TripCompleted();

  @override
  String toString() => 'TripCompleted()';
}

/// Event triggered when location is updated
final class LocationUpdated extends RideMatchingEvent {
  const LocationUpdated(this.location);

  final LatLng location;

  @override
  List<Object> get props => [location];

  @override
  String toString() => 'LocationUpdated(location: $location)';
}