part of 'addvehicle_bloc.dart';

class Vehicle extends Equatable {
  final String name;
  final String number;
  final String year;
  final String type;
  final String photoPath;

  const Vehicle({
    required this.name,
    required this.number,
    required this.year,
    required this.type,
    required this.photoPath,
  });

  @override
  List<Object?> get props => [name, number, year, type, photoPath];
}

abstract class AddVehicleState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddVehicleInitial extends AddVehicleState {}

class AddVehicleLoading extends AddVehicleState {}

class AddVehicleLoaded extends AddVehicleState {
  final List<Vehicle> vehicles;

  AddVehicleLoaded({required this.vehicles});

  @override
  List<Object?> get props => [vehicles];
}

class AddVehicleError extends AddVehicleState {
  final String message;

  AddVehicleError({required this.message});

  @override
  List<Object?> get props => [message];
}
