import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';

part 'insurance_event.dart';
part 'insurance_state.dart';

/// BLoC responsible for managing Insurance verification state and business logic
class InsuranceBloc extends Bloc<InsuranceEvent, InsuranceState> {
  InsuranceBloc() : super(const InsuranceState()) {
    on<InsuranceImageChanged>(_onImageChanged);
    on<InsuranceSubmitted>(_onSubmitted);
  }

  /// Handles insurance image changes
  void _onImageChanged(
    InsuranceImageChanged event,
    Emitter<InsuranceState> emit,
  ) {
    final insuranceImage = InsuranceImage.dirty(event.imagePath);
    emit(
      state.copyWith(
        insuranceImage: insuranceImage,
        status: FormzSubmissionStatus.initial,
      ),
    );
  }

  /// Handles insurance form submission
  Future<void> _onSubmitted(
    InsuranceSubmitted event,
    Emitter<InsuranceState> emit,
  ) async {
    // Validate image before submission
    final insuranceImage = InsuranceImage.dirty(state.insuranceImage.value);

    emit(state.copyWith(
      insuranceImage: insuranceImage,
      status: FormzSubmissionStatus.initial,
    ));

    if (!state.isValid) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: insuranceImage.errorMessage ?? 'Please upload a valid insurance document',
      ));
      return;
    }

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      // TODO: Implement insurance certificate upload to API
      // The API will extract policy number and expiry date from the uploaded image
      await Future<void>.delayed(const Duration(seconds: 2)); // Simulate API call
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Failed to upload insurance document. Please try again.',
      ));
    }
  }
}
