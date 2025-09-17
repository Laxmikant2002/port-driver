import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';
import '../models/vehicle.dart';

part 'vehicle_event.dart';
part 'vehicle_state.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  VehicleBloc() : super(const VehicleState()) {
    on<VehicleLoadRequested>(_onLoadRequested);
    on<VehicleSelected>(_onVehicleSelected);
    on<VehicleSelectionSubmitted>(_onSubmitted);
  }

  void _onLoadRequested(VehicleLoadRequested event, Emitter<VehicleState> emit) async {
    emit(state.copyWith(status: VehicleStatus.loading));
    try {
      await Future<void>.delayed(const Duration(milliseconds: 500)); // Simulate API call
      final vehicles = _getVehicles();
      emit(state.copyWith(
        status: VehicleStatus.loaded,
        vehicles: vehicles,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: VehicleStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  void _onVehicleSelected(VehicleSelected event, Emitter<VehicleState> emit) {
    final selectedVehicle = VehicleSelectionInput.dirty(event.vehicle);
    emit(state.copyWith(
      selectedVehicle: selectedVehicle,
      isValid: Formz.validate([selectedVehicle]),
    ));
  }

  void _onSubmitted(VehicleSelectionSubmitted event, Emitter<VehicleState> emit) async {
    if (state.isValid) {
      emit(state.copyWith(status: VehicleStatus.loading));
      try {
        // TODO: Implement vehicle selection to API
        await Future<void>.delayed(const Duration(seconds: 1)); // Simulate API call
        emit(state.copyWith(status: VehicleStatus.success));
      } catch (error) {
        emit(
          state.copyWith(
            status: VehicleStatus.failure,
            errorMessage: error.toString(),
          ),
        );
      }
    }
  }

  List<Vehicle> _getVehicles() {
    return [
      const Vehicle(
        id: '3wheeler',
        name: '3 Wheeler',
        imageAsset: 'assets/vehicle_icons/3wheeler.png',
        minPrice: 400,
        maxPrice: 500,
        capacity: 750,
        dimensions: '6ft x 4ft',
      ),
      const Vehicle(
        id: '4wheeler',
        name: '4 Wheeler',
        imageAsset: 'assets/vehicle_icons/Mini.png',
        minPrice: 600,
        maxPrice: 800,
        capacity: 1250,
        dimensions: '8ft x 5ft',
      ),
      const Vehicle(
        id: 'long4wheeler',
        name: 'Long 4 Wheeler',
        imageAsset: 'assets/vehicle_icons/Sedan.png',
        minPrice: 800,
        maxPrice: 1000,
        capacity: 1750,
        dimensions: '10ft x 6ft',
      ),
    ];
  }
}
