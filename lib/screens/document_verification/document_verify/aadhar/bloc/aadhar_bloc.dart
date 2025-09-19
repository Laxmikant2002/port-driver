import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';

part 'aadhar_event.dart';
part 'aadhar_state.dart';

/// BLoC responsible for managing Aadhar verification state and business logic
class AadharBloc extends Bloc<AadharEvent, AadharState> {
  AadharBloc() : super(const AadharState()) {
    on<AadharFrontImageChanged>(_onFrontImageChanged);
    on<AadharBackImageChanged>(_onBackImageChanged);
    on<AadharSubmitted>(_onSubmitted);
  }

  /// Handles Aadhar front image changes
  void _onFrontImageChanged(
    AadharFrontImageChanged event,
    Emitter<AadharState> emit,
  ) {
    final frontImage = AadharFrontImage.dirty(event.frontImage);
    emit(
      state.copyWith(
        frontImage: frontImage,
        status: FormzSubmissionStatus.initial,
      ),
    );
  }

  /// Handles Aadhar back image changes
  void _onBackImageChanged(
    AadharBackImageChanged event,
    Emitter<AadharState> emit,
  ) {
    final backImage = AadharBackImage.dirty(event.backImage);
    emit(
      state.copyWith(
        backImage: backImage,
        status: FormzSubmissionStatus.initial,
      ),
    );
  }

  /// Handles Aadhar form submission
  Future<void> _onSubmitted(
    AadharSubmitted event,
    Emitter<AadharState> emit,
  ) async {
    // Validate all fields before submission
    final frontImage = AadharFrontImage.dirty(state.frontImage.value);
    final backImage = AadharBackImage.dirty(state.backImage.value);

    emit(state.copyWith(
      frontImage: frontImage,
      backImage: backImage,
      status: FormzSubmissionStatus.initial,
    ));

    if (!state.isValid) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: frontImage.displayErrorMessage ??
                     backImage.displayErrorMessage ??
                     'Please upload both front and back images of your Aadhaar card',
      ));
      return;
    }

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      // TODO: Implement Aadhaar submission to API
      await Future<void>.delayed(const Duration(seconds: 2)); // Simulate API call
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Failed to submit Aadhaar. Please try again.',
      ));
    }
  }
}
