import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';

part 'rc_event.dart';
part 'rc_state.dart';

class RcBloc extends Bloc<RcEvent, RcState> {
  RcBloc() : super(const RcState()) {
    on<RcNumberChanged>(_onRcNumberChanged);
    on<RcImageChanged>(_onRcImageChanged);
    on<VehicleNumberChanged>(_onVehicleNumberChanged);
    on<RcSubmitted>(_onSubmitted);
  }

  void _onRcNumberChanged(
    RcNumberChanged event,
    Emitter<RcState> emit,
  ) {
    final rcNumber = RcNumber.dirty(event.rcNumber);
    emit(
      state.copyWith(
        rcNumber: rcNumber,
        isValid: Formz.validate([
          rcNumber,
          state.rcImage,
          state.vehicleNumber,
        ]),
      ),
    );
  }

  void _onRcImageChanged(
    RcImageChanged event,
    Emitter<RcState> emit,
  ) {
    final rcImage = RcImage.dirty(event.rcImage);
    emit(
      state.copyWith(
        rcImage: rcImage,
        isValid: Formz.validate([
          state.rcNumber,
          rcImage,
          state.vehicleNumber,
        ]),
      ),
    );
  }

  void _onVehicleNumberChanged(
    VehicleNumberChanged event,
    Emitter<RcState> emit,
  ) {
    final vehicleNumber = VehicleNumber.dirty(event.vehicleNumber);
    emit(
      state.copyWith(
        vehicleNumber: vehicleNumber,
        isValid: Formz.validate([
          state.rcNumber,
          state.rcImage,
          vehicleNumber,
        ]),
      ),
    );
  }

  void _onSubmitted(
    RcSubmitted event,
    Emitter<RcState> emit,
  ) async {
    if (state.isValid) {
      emit(state.copyWith(status: RcStatus.loading));
      try {
        // TODO: Implement RC submission to API
        await Future<void>.delayed(const Duration(seconds: 2)); // Simulate API call
        emit(state.copyWith(status: RcStatus.success));
      } catch (error) {
        emit(
          state.copyWith(
            status: RcStatus.failure,
            errorMessage: error.toString(),
          ),
        );
      }
    }
  }
}
