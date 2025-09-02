import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'addvehicle_event.dart';
part 'addvehicle_state.dart';

class AddVehicleBloc extends Bloc<AddVehicleEvent, AddVehicleState> {
  AddVehicleBloc() : super(AddVehicleInitial()) {
    on<LoadVehicles>(_onLoadVehicles);
    on<AddVehicle>(_onAddVehicle);
    on<DeleteVehicle>(_onDeleteVehicle);
  }

  Future<void> _onLoadVehicles(
    LoadVehicles event,
    Emitter<AddVehicleState> emit,
  ) async {
    try {
      emit(AddVehicleLoading());

      // Simulate fetching vehicles (in real app, fetch from API/db)
      await Future.delayed(const Duration(seconds: 1));
      final vehicles = [
        Vehicle(
          name: 'Honda City',
          number: 'MH 12 AB 1234',
          year: '2022',
          type: 'Sedan',
          photoPath: '',
        ),
        Vehicle(
          name: 'Piaggio Auto',
          number: 'KA 05 XY 9876',
          year: '2020',
          type: 'Auto',
          photoPath: '',
        ),
      ];

      emit(AddVehicleLoaded(vehicles: vehicles));
    } catch (e) {
      emit(AddVehicleError(message: e.toString()));
    }
  }

  Future<void> _onAddVehicle(
    AddVehicle event,
    Emitter<AddVehicleState> emit,
  ) async {
    if (state is AddVehicleLoaded) {
      final currentState = state as AddVehicleLoaded;
      final updatedVehicles = List<Vehicle>.from(currentState.vehicles)
        ..add(event.vehicle);

      emit(AddVehicleLoaded(vehicles: updatedVehicles));
    }
  }

  Future<void> _onDeleteVehicle(
    DeleteVehicle event,
    Emitter<AddVehicleState> emit,
  ) async {
    if (state is AddVehicleLoaded) {
      final currentState = state as AddVehicleLoaded;
      final updatedVehicles = currentState.vehicles
          .where((v) => v.number != event.vehicleNumber)
          .toList();

      emit(AddVehicleLoaded(vehicles: updatedVehicles));
    }
  }
}
