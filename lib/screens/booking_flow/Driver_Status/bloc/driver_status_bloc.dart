import 'package:driver/services/socket_service.dart';
import 'package:driver_status/driver_status.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'driver_status_event.dart';
part 'driver_status_state.dart';

class DriverStatusBloc extends Bloc<DriverStatusEvent, DriverStatusState> {
  DriverStatusBloc({
    required this.driverStatusRepo,
    required this.socketService,
  }) : super(const DriverStatusState()) {
    on<DriverStatusInitialized>(_onInitialized);
    on<DriverStatusToggled>(_onStatusToggled);
    on<WorkAreaChanged>(_onWorkAreaChanged);
    on<DriverStatusSubmitted>(_onSubmitted);
    on<LocationUpdated>(_onLocationUpdated);
    on<MapControllerUpdated>(_onMapControllerUpdated);
  }

  final DriverStatusRepo driverStatusRepo;
  final SocketService socketService;

  Future<void> _onInitialized(
    DriverStatusInitialized event,
    Emitter<DriverStatusState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      // Get initial driver status and dashboard data
      final statusResponse = await driverStatusRepo.getDriverStatus();
      final dashboardResponse = await driverStatusRepo.getDashboardData();

      if (statusResponse.success && dashboardResponse.success) {
        final driverStatus = DriverStatusField.dirty(
          statusResponse.status?.value ?? 'offline'
        );
        final workArea = WorkAreaField.dirty(
          statusResponse.workArea?.name ?? ''
        );

        emit(state.copyWith(
          status: FormzSubmissionStatus.success,
          driverStatus: driverStatus,
          workArea: workArea,
          earningsToday: dashboardResponse.earningsToday ?? 0.0,
          tripsToday: dashboardResponse.tripsToday ?? 0,
          lastActiveAt: statusResponse.lastActiveAt,
        ));

        // Initialize socket if driver is online
        if (statusResponse.status == DriverStatus.online) {
          socketService.connect();
        }
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: statusResponse.message ?? 'Failed to load driver status',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Network error: ${e.toString()}',
      ));
    }
  }

  void _onStatusToggled(
    DriverStatusToggled event,
    Emitter<DriverStatusState> emit,
  ) {
    final driverStatus = DriverStatusField.dirty(event.newStatus.value);
    emit(
      state.copyWith(
        driverStatus: driverStatus,
        status: FormzSubmissionStatus.initial,
      ),
    );
  }

  void _onWorkAreaChanged(
    WorkAreaChanged event,
    Emitter<DriverStatusState> emit,
  ) {
    final workArea = WorkAreaField.dirty(event.workArea.name);
    emit(
      state.copyWith(
        workArea: workArea,
        status: FormzSubmissionStatus.initial,
      ),
    );
  }


  Future<void> _onSubmitted(
    DriverStatusSubmitted event,
    Emitter<DriverStatusState> emit,
  ) async {
    // Validate all fields before submission
    final driverStatus = DriverStatusField.dirty(state.driverStatus.value);
    final workArea = WorkAreaField.dirty(state.workArea.value);

    emit(state.copyWith(
      driverStatus: driverStatus,
      workArea: workArea,
      status: FormzSubmissionStatus.initial,
    ));

    if (!state.isValid) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Please complete all required fields correctly',
      ));
      return;
    }

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      // Update driver status
      final statusEnum = DriverStatus.fromString(driverStatus.value);
      final statusResponse = await driverStatusRepo.updateDriverStatus(statusEnum);

      if (statusResponse.success) {
        // Update work area if provided
        if (workArea.value.isNotEmpty && state.selectedWorkArea != null) {
          final workAreaResponse = await driverStatusRepo.setWorkArea(state.selectedWorkArea!);
          
          if (!workAreaResponse.success) {
            emit(state.copyWith(
              status: FormzSubmissionStatus.failure,
              errorMessage: workAreaResponse.message ?? 'Failed to set work area',
            ));
            return;
          }
        }

        emit(state.copyWith(status: FormzSubmissionStatus.success));

        // Handle socket connection based on status
        if (statusEnum == DriverStatus.online) {
          socketService.connect();
          add(const LocationUpdated());
        } else {
          socketService.disconnect();
        }
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: statusResponse.message ?? 'Failed to update status',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Network error: ${e.toString()}',
      ));
    }
  }

  void _onLocationUpdated(
    LocationUpdated event,
    Emitter<DriverStatusState> emit,
  ) {
    // Handle location update logic here
    emit(state.copyWith(
      currentStatus: 'Location Updated',
      isLocationLoaded: true,
    ));
  }

  void _onMapControllerUpdated(
    MapControllerUpdated event,
    Emitter<DriverStatusState> emit,
  ) {
    emit(state.copyWith(
      mapController: event.controller,
      currentStatus: 'Map Loaded',
    ));
  }

}