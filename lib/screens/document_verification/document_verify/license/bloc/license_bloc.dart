import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';

part 'license_event.dart';
part 'license_state.dart';

class LicenseBloc extends Bloc<LicenseEvent, LicenseState> {
  LicenseBloc() : super(const LicenseState()) {
    on<LicenseNumberChanged>(_onLicenseNumberChanged);
    on<LicenseImageChanged>(_onLicenseImageChanged);
    on<LicenseDobChanged>(_onLicenseDobChanged);
    on<LicenseSubmitted>(_onSubmitted);
  }

  void _onLicenseNumberChanged(
    LicenseNumberChanged event,
    Emitter<LicenseState> emit,
  ) {
    final licenseNumber = LicenseNumber.dirty(event.licenseNumber);
    emit(
      state.copyWith(
        licenseNumber: licenseNumber,
        isValid: Formz.validate([
          licenseNumber,
          state.licenseImage,
          state.dob,
        ]),
      ),
    );
  }

  void _onLicenseImageChanged(
    LicenseImageChanged event,
    Emitter<LicenseState> emit,
  ) {
    final licenseImage = LicenseImage.dirty(event.licenseImage);
    emit(
      state.copyWith(
        licenseImage: licenseImage,
        isValid: Formz.validate([
          state.licenseNumber,
          licenseImage,
          state.dob,
        ]),
      ),
    );
  }

  void _onLicenseDobChanged(
    LicenseDobChanged event,
    Emitter<LicenseState> emit,
  ) {
    final dob = LicenseDob.dirty(event.dob);
    emit(
      state.copyWith(
        dob: dob,
        isValid: Formz.validate([
          state.licenseNumber,
          state.licenseImage,
          dob,
        ]),
      ),
    );
  }

  void _onSubmitted(
    LicenseSubmitted event,
    Emitter<LicenseState> emit,
  ) async {
    if (state.isValid) {
      emit(state.copyWith(status: LicenseStatus.loading));
      try {
        // TODO: Implement license submission to API
        await Future<void>.delayed(const Duration(seconds: 2)); // Simulate API call
        emit(state.copyWith(status: LicenseStatus.success));
      } catch (error) {
        emit(
          state.copyWith(
            status: LicenseStatus.failure,
            errorMessage: error.toString(),
          ),
        );
      }
    }
  }
}
