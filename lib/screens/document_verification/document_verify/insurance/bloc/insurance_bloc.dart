import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';

part 'insurance_event.dart';
part 'insurance_state.dart';

class InsuranceBloc extends Bloc<InsuranceEvent, InsuranceState> {
  InsuranceBloc() : super(const InsuranceState()) {
    on<InsuranceImageChanged>(_onImageChanged);
    on<InsurancePolicyNumberChanged>(_onPolicyNumberChanged);
    on<InsuranceExpiryDateChanged>(_onExpiryDateChanged);
    on<InsuranceSubmitted>(_onSubmitted);
  }

  void _onImageChanged(
    InsuranceImageChanged event,
    Emitter<InsuranceState> emit,
  ) {
    final insuranceImage = InsuranceImage.dirty(event.imagePath);
    emit(
      state.copyWith(
        insuranceImage: insuranceImage,
        isValid: Formz.validate([
          insuranceImage,
          state.policyNumber,
          state.expiryDate,
        ]),
      ),
    );
  }

  void _onPolicyNumberChanged(
    InsurancePolicyNumberChanged event,
    Emitter<InsuranceState> emit,
  ) {
    final policyNumber = InsurancePolicyNumber.dirty(event.policyNumber);
    emit(
      state.copyWith(
        policyNumber: policyNumber,
        isValid: Formz.validate([
          state.insuranceImage,
          policyNumber,
          state.expiryDate,
        ]),
      ),
    );
  }

  void _onExpiryDateChanged(
    InsuranceExpiryDateChanged event,
    Emitter<InsuranceState> emit,
  ) {
    final expiryDate = InsuranceExpiryDate.dirty(event.expiryDate);
    emit(
      state.copyWith(
        expiryDate: expiryDate,
        isValid: Formz.validate([
          state.insuranceImage,
          state.policyNumber,
          expiryDate,
        ]),
      ),
    );
  }

  void _onSubmitted(
    InsuranceSubmitted event,
    Emitter<InsuranceState> emit,
  ) async {
    if (state.isValid) {
      emit(state.copyWith(status: InsuranceStatus.loading));
      try {
        // TODO: Implement insurance certificate upload to API
        await Future<void>.delayed(const Duration(seconds: 2)); // Simulate API call
        emit(state.copyWith(status: InsuranceStatus.success));
      } catch (error) {
        emit(
          state.copyWith(
            status: InsuranceStatus.failure,
            errorMessage: error.toString(),
          ),
        );
      }
    }
  }
}
