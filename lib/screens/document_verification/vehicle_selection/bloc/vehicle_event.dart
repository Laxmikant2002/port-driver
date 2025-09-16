import 'package:equatable/equatable.dart';
import '../models/vehicle.dart';

abstract class VehicleEvent extends Equatable {
  const VehicleEvent();
  @override
  List<Object?> get props => [];
}

class VehicleLoadRequested extends VehicleEvent {
  const VehicleLoadRequested();
}

class VehicleSelected extends VehicleEvent {
  final Vehicle vehicle;
  const VehicleSelected(this.vehicle);
  @override
  List<Object?> get props => [vehicle];
}

class VehicleSelectionSubmitted extends VehicleEvent {
  const VehicleSelectionSubmitted();
}
