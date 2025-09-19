import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';
import '../models/vehicle.dart';

part 'vehicle_event.dart';
part 'vehicle_state.dart';

/// BLoC responsible for managing vehicle selection state and business logic
class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  VehicleBloc() : super(const VehicleState()) {
    on<VehicleLoadRequested>(_onLoadRequested);
    on<VehicleSelected>(_onVehicleSelected);
    on<VehicleSelectionSubmitted>(_onSubmitted);
  }

  /// Handles loading available vehicles
  Future<void> _onLoadRequested(VehicleLoadRequested event, Emitter<VehicleState> emit) async {
    emit(state.copyWith(loadingStatus: VehicleLoadingStatus.loading));
    try {
      await Future<void>.delayed(const Duration(milliseconds: 500)); // Simulate API call
      final vehicles = _getVehicles();
      emit(state.copyWith(
        loadingStatus: VehicleLoadingStatus.loaded,
        vehicles: vehicles,
      ));
    } catch (error) {
      emit(state.copyWith(
        loadingStatus: VehicleLoadingStatus.failure,
        errorMessage: 'Failed to load vehicles. Please try again.',
      ));
    }
  }

  /// Handles vehicle selection
  void _onVehicleSelected(VehicleSelected event, Emitter<VehicleState> emit) {
    final selectedVehicle = VehicleSelectionInput.dirty(event.vehicle);
    emit(state.copyWith(
      selectedVehicle: selectedVehicle,
      status: FormzSubmissionStatus.initial,
    ));
  }

  /// Handles vehicle selection submission
  Future<void> _onSubmitted(VehicleSelectionSubmitted event, Emitter<VehicleState> emit) async {
    // Validate selection before submission
    final selectedVehicle = VehicleSelectionInput.dirty(state.selectedVehicle.value);
    
    emit(state.copyWith(
      selectedVehicle: selectedVehicle,
      status: FormzSubmissionStatus.initial,
    ));

    if (!state.isValid) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: selectedVehicle.displayError?.toString() ?? 'Please select a vehicle',
      ));
      return;
    }

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      // TODO: Implement vehicle selection to API
      await Future<void>.delayed(const Duration(seconds: 1)); // Simulate API call
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Failed to select vehicle. Please try again.',
      ));
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
        imageAsset: 'assets/vehicle_icons/4wheeler.png',
        minPrice: 600,
        maxPrice: 800,
        capacity: 1250,
        dimensions: '8ft x 5ft',
      ),
      const Vehicle(
        id: 'long4wheeler',
        name: 'Long 4 Wheeler',
        imageAsset: 'assets/vehicle_icons/long4wheeler.png',
        minPrice: 800,
        maxPrice: 1000,
        capacity: 1750,
        dimensions: '10ft x 6ft',
      ),
    ];
  }
}
