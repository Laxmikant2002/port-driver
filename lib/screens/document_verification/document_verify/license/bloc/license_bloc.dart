import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';

part 'license_event.dart';
part 'license_state.dart';

/// BLoC responsible for managing License verification state and business logic
class LicenseBloc extends Bloc<LicenseEvent, LicenseState> {
  LicenseBloc() : super(const LicenseState()) {
    on<LicenseFrontImageChanged>(_onFrontImageChanged);
    on<LicenseBackImageChanged>(_onBackImageChanged);
    on<LicenseSubmitted>(_onSubmitted);
  }

  /// Handles license front image changes
  void _onFrontImageChanged(
    LicenseFrontImageChanged event,
    Emitter<LicenseState> emit,
  ) {
    final frontImage = LicenseFrontImage.dirty(event.frontImage);
    emit(
      state.copyWith(
        frontImage: frontImage,
        status: FormzSubmissionStatus.initial,
      ),
    );
  }

  /// Handles license back image changes
  void _onBackImageChanged(
    LicenseBackImageChanged event,
    Emitter<LicenseState> emit,
  ) {
    final backImage = LicenseBackImage.dirty(event.backImage);
    emit(
      state.copyWith(
        backImage: backImage,
        status: FormzSubmissionStatus.initial,
      ),
    );
  }

  /// Handles license form submission
  Future<void> _onSubmitted(
    LicenseSubmitted event,
    Emitter<LicenseState> emit,
  ) async {
    // Validate all fields before submission
    final frontImage = LicenseFrontImage.dirty(state.frontImage.value);
    final backImage = LicenseBackImage.dirty(state.backImage.value);

    emit(state.copyWith(
      frontImage: frontImage,
      backImage: backImage,
      status: FormzSubmissionStatus.initial,
    ));

    if (!state.isValid) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: frontImage.errorMessage ??
                     backImage.errorMessage ??
                     'Please upload both front and back images of your driving license',
      ));
      return;
    }

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      // TODO: Implement license submission to API
      await Future<void>.delayed(const Duration(seconds: 2)); // Simulate API call
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Failed to submit license. Please try again.',
      ));
    }
  }
}
