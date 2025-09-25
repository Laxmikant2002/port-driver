part of 'driver_status_bloc.dart';

/// Base class for all Driver Status events
sealed class DriverStatusEvent extends Equatable {
  const DriverStatusEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered when driver status bloc is initialized
final class DriverStatusInitialized extends DriverStatusEvent {
  const DriverStatusInitialized();

  @override
  String toString() => 'DriverStatusInitialized()';
}

/// Event triggered when driver status is changed
final class DriverStatusToggled extends DriverStatusEvent {
  const DriverStatusToggled(this.newStatus);

  final DriverStatus newStatus;

  @override
  List<Object> get props => [newStatus];

  @override
  String toString() => 'DriverStatusToggled(newStatus: $newStatus)';
}

/// Event triggered when work area is changed
final class WorkAreaChanged extends DriverStatusEvent {
  const WorkAreaChanged(this.workArea);

  final WorkArea workArea;

  @override
  List<Object> get props => [workArea];

  @override
  String toString() => 'WorkAreaChanged(workArea: $workArea)';
}

/// Event triggered when driver status form is submitted
final class DriverStatusSubmitted extends DriverStatusEvent {
  const DriverStatusSubmitted();

  @override
  String toString() => 'DriverStatusSubmitted()';
}

/// Event triggered when location is updated
final class LocationUpdated extends DriverStatusEvent {
  const LocationUpdated();

  @override
  String toString() => 'LocationUpdated()';
}

/// Event triggered when map controller is updated
final class MapControllerUpdated extends DriverStatusEvent {
  const MapControllerUpdated(this.controller);

  final GoogleMapController controller;

  @override
  List<Object> get props => [controller];

  @override
  String toString() => 'MapControllerUpdated(controller: $controller)';
}

/// Event triggered when location tracking should start
final class StartLocationTracking extends DriverStatusEvent {
  const StartLocationTracking();

  @override
  String toString() => 'StartLocationTracking()';
}

/// Event triggered when location tracking should stop
final class StopLocationTracking extends DriverStatusEvent {
  const StopLocationTracking();

  @override
  String toString() => 'StopLocationTracking()';
}