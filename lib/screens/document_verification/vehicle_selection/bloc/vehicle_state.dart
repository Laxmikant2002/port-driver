import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import '../models/vehicle.dart';

class VehicleSelectionInput extends FormzInput<Vehicle?, String> {
  const VehicleSelectionInput.pure() : super.pure(null);
  const VehicleSelectionInput.dirty([super.value]) : super.dirty();
  
  @override
  String? validator(Vehicle? value) {
    if (value == null) return 'Please select a vehicle';
    return null;
  }
}

enum VehicleStatus { initial, loading, loaded, success, failure }

class VehicleState extends Equatable {
  const VehicleState({
    this.status = VehicleStatus.initial,
    this.vehicles = const [],
    this.selectedVehicle = const VehicleSelectionInput.pure(),
    this.isValid = false,
    this.errorMessage,
  });

  final VehicleStatus status;
  final List<Vehicle> vehicles;
  final VehicleSelectionInput selectedVehicle;
  final bool isValid;
  final String? errorMessage;

  VehicleState copyWith({
    VehicleStatus? status,
    List<Vehicle>? vehicles,
    VehicleSelectionInput? selectedVehicle,
    bool? isValid,
    String? errorMessage,
  }) {
    return VehicleState(
      status: status ?? this.status,
      vehicles: vehicles ?? this.vehicles,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, vehicles, selectedVehicle, isValid, errorMessage];
}
