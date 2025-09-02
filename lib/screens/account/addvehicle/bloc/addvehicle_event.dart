part of 'addvehicle_bloc.dart';

abstract class AddVehicleEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadVehicles extends AddVehicleEvent {}

class AddVehicle extends AddVehicleEvent {
  final Vehicle vehicle;

  AddVehicle({required this.vehicle});

  @override
  List<Object?> get props => [vehicle];
}

class DeleteVehicle extends AddVehicleEvent {
  final String vehicleNumber;

  DeleteVehicle({required this.vehicleNumber});

  @override
  List<Object?> get props => [vehicleNumber];
}
