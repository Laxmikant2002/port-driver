part of 'addvehicle_bloc.dart';

/// Base class for all AddVehicle events
sealed class AddVehicleEvent extends Equatable {
  const AddVehicleEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered when vehicles are loaded
final class VehiclesLoaded extends AddVehicleEvent {
  const VehiclesLoaded();

  @override
  String toString() => 'VehiclesLoaded()';
}

/// Event triggered when vehicle name is changed
final class VehicleNameChanged extends AddVehicleEvent {
  const VehicleNameChanged(this.vehicleName);

  final String vehicleName;

  @override
  List<Object> get props => [vehicleName];

  @override
  String toString() => 'VehicleNameChanged(vehicleName: $vehicleName)';
}

/// Event triggered when vehicle number is changed
final class VehicleNumberChanged extends AddVehicleEvent {
  const VehicleNumberChanged(this.vehicleNumber);

  final String vehicleNumber;

  @override
  List<Object> get props => [vehicleNumber];

  @override
  String toString() => 'VehicleNumberChanged(vehicleNumber: $vehicleNumber)';
}

/// Event triggered when vehicle year is changed
final class VehicleYearChanged extends AddVehicleEvent {
  const VehicleYearChanged(this.vehicleYear);

  final String vehicleYear;

  @override
  List<Object> get props => [vehicleYear];

  @override
  String toString() => 'VehicleYearChanged(vehicleYear: $vehicleYear)';
}

/// Event triggered when vehicle type is changed
final class VehicleTypeChanged extends AddVehicleEvent {
  const VehicleTypeChanged(this.vehicleType);

  final String vehicleType;

  @override
  List<Object> get props => [vehicleType];

  @override
  String toString() => 'VehicleTypeChanged(vehicleType: $vehicleType)';
}

/// Event triggered when vehicle photo is changed
final class VehiclePhotoChanged extends AddVehicleEvent {
  const VehiclePhotoChanged(this.photoPath);

  final String photoPath;

  @override
  List<Object> get props => [photoPath];

  @override
  String toString() => 'VehiclePhotoChanged(photoPath: $photoPath)';
}

/// Event triggered when vehicle form is submitted
final class VehicleSubmitted extends AddVehicleEvent {
  const VehicleSubmitted({
    required this.name,
    required this.number,
    required this.year,
    required this.type,
    this.photoPath,
  });

  final String name;
  final String number;
  final String year;
  final String type;
  final String? photoPath;

  @override
  List<Object> get props => [name, number, year, type, photoPath ?? ''];

  @override
  String toString() => 'VehicleSubmitted(name: $name, number: $number, year: $year, type: $type)';
}

/// Event triggered when a vehicle is deleted
final class VehicleDeleted extends AddVehicleEvent {
  const VehicleDeleted(this.vehicleId);

  final String vehicleId;

  @override
  List<Object> get props => [vehicleId];

  @override
  String toString() => 'VehicleDeleted(vehicleId: $vehicleId)';
}

/// Event triggered when a vehicle is selected
final class VehicleSelected extends AddVehicleEvent {
  const VehicleSelected(this.vehicle);

  final Vehicle vehicle;

  @override
  List<Object> get props => [vehicle];

  @override
  String toString() => 'VehicleSelected(vehicle: $vehicle)';
}
