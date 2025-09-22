import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';

part 'addvehicle_event.dart';
part 'addvehicle_state.dart';

class AddVehicleBloc extends Bloc<AddVehicleEvent, AddVehicleState> {
  AddVehicleBloc() : super(const AddVehicleState()) {
    on<VehiclesLoaded>(_onVehiclesLoaded);
    on<VehicleNameChanged>(_onVehicleNameChanged);
    on<VehicleNumberChanged>(_onVehicleNumberChanged);
    on<VehicleYearChanged>(_onVehicleYearChanged);
    on<VehicleTypeChanged>(_onVehicleTypeChanged);
    on<VehiclePhotoChanged>(_onVehiclePhotoChanged);
    on<VehicleSubmitted>(_onVehicleSubmitted);
    on<VehicleDeleted>(_onVehicleDeleted);
    on<VehicleSelected>(_onVehicleSelected);
  }


  Future<void> _onVehiclesLoaded(
    VehiclesLoaded event,
    Emitter<AddVehicleState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      // TODO: Implement vehicle management through profile repo
      // For now, simulate with empty list
      emit(state.copyWith(
        vehicles: [],
        status: FormzSubmissionStatus.success,
        clearError: true,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Network error: ${error.toString()}',
      ));
    }
  }

  void _onVehicleNameChanged(
    VehicleNameChanged event,
    Emitter<AddVehicleState> emit,
  ) {
    final vehicleName = VehicleName.dirty(event.vehicleName);
    emit(state.copyWith(
      vehicleName: vehicleName,
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }

  void _onVehicleNumberChanged(
    VehicleNumberChanged event,
    Emitter<AddVehicleState> emit,
  ) {
    final vehicleNumber = VehicleNumber.dirty(event.vehicleNumber);
    emit(state.copyWith(
      vehicleNumber: vehicleNumber,
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }

  void _onVehicleYearChanged(
    VehicleYearChanged event,
    Emitter<AddVehicleState> emit,
  ) {
    final vehicleYear = VehicleYear.dirty(event.vehicleYear);
    emit(state.copyWith(
      vehicleYear: vehicleYear,
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }

  void _onVehicleTypeChanged(
    VehicleTypeChanged event,
    Emitter<AddVehicleState> emit,
  ) {
    final vehicleType = VehicleTypeInput.dirty(event.vehicleType);
    emit(state.copyWith(
      vehicleType: vehicleType,
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }

  void _onVehiclePhotoChanged(
    VehiclePhotoChanged event,
    Emitter<AddVehicleState> emit,
  ) {
    emit(state.copyWith(
      photoPath: event.photoPath,
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }

  Future<void> _onVehicleSubmitted(
    VehicleSubmitted event,
    Emitter<AddVehicleState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      // TODO: Implement vehicle addition through profile repo
      // For now, simulate success
      add(const VehiclesLoaded());
      emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        clearError: true,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Network error. Please try again.',
      ));
    }
  }

  Future<void> _onVehicleDeleted(
    VehicleDeleted event,
    Emitter<AddVehicleState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      // TODO: Implement vehicle deletion through profile repo
      // For now, simulate success
      add(const VehiclesLoaded());
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Delete error: ${error.toString()}',
      ));
    }
  }

  void _onVehicleSelected(
    VehicleSelected event,
    Emitter<AddVehicleState> emit,
  ) {
    emit(state.copyWith(
      selectedVehicle: event.vehicle,
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }
}
