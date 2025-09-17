part of 'vehicle_bloc.dart';

abstract class VehicleEvent extends Equatable {
  const VehicleEvent();

  @override
  List<Object> get props => [];
}

class VehicleLoadRequested extends VehicleEvent {
  const VehicleLoadRequested();
}

class VehicleSelected extends VehicleEvent {
  const VehicleSelected(this.vehicle);

  final Vehicle vehicle;

  @override
  List<Object> get props => [vehicle];
}

class VehicleSelectionSubmitted extends VehicleEvent {
  const VehicleSelectionSubmitted();
}
