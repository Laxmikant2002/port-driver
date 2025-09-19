part of 'vehicle_bloc.dart';

/// Base class for all vehicle events
sealed class VehicleEvent extends Equatable {
  const VehicleEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered to load available vehicles
final class VehicleLoadRequested extends VehicleEvent {
  const VehicleLoadRequested();

  @override
  String toString() => 'VehicleLoadRequested()';
}

/// Event triggered when a vehicle is selected
final class VehicleSelected extends VehicleEvent {
  const VehicleSelected(this.vehicle);

  final Vehicle vehicle;

  @override
  List<Object> get props => [vehicle];

  @override
  String toString() => 'VehicleSelected(vehicle: ${vehicle.name})';
}

/// Event triggered when vehicle selection is submitted
final class VehicleSelectionSubmitted extends VehicleEvent {
  const VehicleSelectionSubmitted();

  @override
  String toString() => 'VehicleSelectionSubmitted()';
}
