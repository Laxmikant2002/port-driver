part of 'insurance_bloc.dart';

enum InsuranceImageValidationError { empty }

class InsuranceImage extends FormzInput<String, InsuranceImageValidationError> {
  const InsuranceImage.pure() : super.pure('');
  const InsuranceImage.dirty([super.value = '']) : super.dirty();

  @override
  InsuranceImageValidationError? validator(String value) {
    if (value.isEmpty) return InsuranceImageValidationError.empty;
    return null;
  }
}

enum InsurancePolicyNumberValidationError { empty, invalid }

class InsurancePolicyNumber extends FormzInput<String, InsurancePolicyNumberValidationError> {
  const InsurancePolicyNumber.pure() : super.pure('');
  const InsurancePolicyNumber.dirty([super.value = '']) : super.dirty();

  @override
  InsurancePolicyNumberValidationError? validator(String value) {
    if (value.isEmpty) return InsurancePolicyNumberValidationError.empty;
    if (value.length < 6) return InsurancePolicyNumberValidationError.invalid;
    return null;
  }
}

enum InsuranceExpiryDateValidationError { empty, invalid }

class InsuranceExpiryDate extends FormzInput<String, InsuranceExpiryDateValidationError> {
  const InsuranceExpiryDate.pure() : super.pure('');
  const InsuranceExpiryDate.dirty([super.value = '']) : super.dirty();

  @override
  InsuranceExpiryDateValidationError? validator(String value) {
    if (value.isEmpty) return InsuranceExpiryDateValidationError.empty;
    // Simple date format check (DD/MM/YYYY or YYYY-MM-DD)
    final dateRegExp = RegExp(r'^(\d{2}/\d{2}/\d{4}|\d{4}-\d{2}-\d{2})$');
    if (!dateRegExp.hasMatch(value)) return InsuranceExpiryDateValidationError.invalid;
    return null;
  }
}

enum InsuranceStatus { initial, loading, success, failure }

class InsuranceState extends Equatable {
  const InsuranceState({
    this.status = InsuranceStatus.initial,
    this.insuranceImage = const InsuranceImage.pure(),
    this.policyNumber = const InsurancePolicyNumber.pure(),
    this.expiryDate = const InsuranceExpiryDate.pure(),
    this.isValid = false,
    this.errorMessage,
  });

  final InsuranceStatus status;
  final InsuranceImage insuranceImage;
  final InsurancePolicyNumber policyNumber;
  final InsuranceExpiryDate expiryDate;
  final bool isValid;
  final String? errorMessage;

  InsuranceState copyWith({
    InsuranceStatus? status,
    InsuranceImage? insuranceImage,
    InsurancePolicyNumber? policyNumber,
    InsuranceExpiryDate? expiryDate,
    bool? isValid,
    String? errorMessage,
  }) {
    return InsuranceState(
      status: status ?? this.status,
      insuranceImage: insuranceImage ?? this.insuranceImage,
      policyNumber: policyNumber ?? this.policyNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        insuranceImage,
        policyNumber,
        expiryDate,
        isValid,
        errorMessage,
      ];
}
