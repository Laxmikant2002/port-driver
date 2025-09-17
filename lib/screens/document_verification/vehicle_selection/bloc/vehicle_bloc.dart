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
        id: '1',
        name: 'Tata 407',
        imageAsset: 'assets/vehicle_icons/Auto.png',
        minPrice: 355,
        maxPrice: 385,
        capacity: 2500,
        dimensions: '9ft x 6ft',
      ),
      const Vehicle(
        id: '3',
        name: '3 Wheeler',
        imageAsset: 'assets/vehicle_icons/Mini.png',
        minPrice: 755,
        maxPrice: 785,
        capacity: 500,
        dimensions: '6ft x 5ft',
      ),
      const Vehicle(
        id: '4',
        name: 'Tata Ace',
        imageAsset: 'assets/vehicle_icons/Sedan.png',
        minPrice: 820,
        maxPrice: 850,
        capacity: 750,
        dimensions: '7ft x 6ft',
      ),
    ];
  }
}
