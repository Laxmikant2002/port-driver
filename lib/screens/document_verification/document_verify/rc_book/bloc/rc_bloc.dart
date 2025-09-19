import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';

part 'rc_event.dart';
part 'rc_state.dart';

/// BLoC responsible for managing RC Book verification state and business logic
class RcBloc extends Bloc<RcEvent, RcState> {
  RcBloc() : super(const RcState()) {
    on<RcNumberChanged>(_onRcNumberChanged);
    on<RcImageChanged>(_onRcImageChanged);
    on<VehicleNumberChanged>(_onVehicleNumberChanged);
    on<RcSubmitted>(_onSubmitted);
  }

  /// Handles RC number changes
  void _onRcNumberChanged(
    RcNumberChanged event,
    Emitter<RcState> emit,
  ) {
    final rcNumber = RcNumber.dirty(event.rcNumber);
    emit(
      state.copyWith(
        rcNumber: rcNumber,
        status: FormzSubmissionStatus.initial,
      ),
    );
  }

  /// Handles RC image changes
  void _onRcImageChanged(
    RcImageChanged event,
    Emitter<RcState> emit,
  ) {
    final rcImage = RcImage.dirty(event.rcImage);
    emit(
      state.copyWith(
        rcImage: rcImage,
        status: FormzSubmissionStatus.initial,
      ),
    );
  }

  /// Handles vehicle number changes
  void _onVehicleNumberChanged(
    VehicleNumberChanged event,
    Emitter<RcState> emit,
  ) {
    final vehicleNumber = VehicleNumber.dirty(event.vehicleNumber);
    emit(
      state.copyWith(
        vehicleNumber: vehicleNumber,
        status: FormzSubmissionStatus.initial,
      ),
    );
  }

  /// Handles RC form submission
  Future<void> _onSubmitted(
    RcSubmitted event,
    Emitter<RcState> emit,
  ) async {
    // Validate all fields before submission
    final rcNumber = RcNumber.dirty(state.rcNumber.value);
    final rcImage = RcImage.dirty(state.rcImage.value);
    final vehicleNumber = VehicleNumber.dirty(state.vehicleNumber.value);

    emit(state.copyWith(
      rcNumber: rcNumber,
      rcImage: rcImage,
      vehicleNumber: vehicleNumber,
      status: FormzSubmissionStatus.initial,
    ));

    if (!state.isValid) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: vehicleNumber.errorMessage ??
                     rcNumber.errorMessage ??
                     rcImage.errorMessage ??
                     'Please complete all required fields',
      ));
      return;
    }

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      // TODO: Implement RC submission to API
      await Future<void>.delayed(const Duration(seconds: 2)); // Simulate API call
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Failed to submit RC Book. Please try again.',
      ));
    }
  }
}
