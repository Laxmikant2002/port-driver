part of 'license_bloc.dart';

enum LicenseNumberValidationError { empty, invalid }

class LicenseNumber extends FormzInput<String, LicenseNumberValidationError> {
  const LicenseNumber.pure() : super.pure('');
  const LicenseNumber.dirty([super.value = '']) : super.dirty();

  @override
  LicenseNumberValidationError? validator(String value) {
    if (value.isEmpty) return LicenseNumberValidationError.empty;
    if (value.length < 6) {
      return LicenseNumberValidationError.invalid;
    }
    return null;
  }
}

enum LicenseImageValidationError { empty }

class LicenseImage extends FormzInput<String, LicenseImageValidationError> {
  const LicenseImage.pure() : super.pure('');
  const LicenseImage.dirty([super.value = '']) : super.dirty();

  @override
  LicenseImageValidationError? validator(String value) {
    if (value.isEmpty) return LicenseImageValidationError.empty;
    return null;
  }
}

enum LicenseDobValidationError { empty, invalid }

class LicenseDob extends FormzInput<String, LicenseDobValidationError> {
  const LicenseDob.pure() : super.pure('');
  const LicenseDob.dirty([super.value = '']) : super.dirty();

  @override
  LicenseDobValidationError? validator(String value) {
    if (value.isEmpty) return LicenseDobValidationError.empty;
    // Simple date format check (YYYY-MM-DD or DD/MM/YYYY)
    final dateRegExp = RegExp(r'^(\d{2}/\d{2}/\d{4}|\d{4}-\d{2}-\d{2})$');
    if (!dateRegExp.hasMatch(value)) return LicenseDobValidationError.invalid;
    return null;
  }
}

enum LicenseStatus { initial, loading, success, failure }

class LicenseState extends Equatable {
  const LicenseState({
    this.status = LicenseStatus.initial,
    this.licenseNumber = const LicenseNumber.pure(),
    this.licenseImage = const LicenseImage.pure(),
    this.dob = const LicenseDob.pure(),
    this.isValid = false,
    this.errorMessage,
  });

  final LicenseStatus status;
  final LicenseNumber licenseNumber;
  final LicenseImage licenseImage;
  final LicenseDob dob;
  final bool isValid;
  final String? errorMessage;

  LicenseState copyWith({
    LicenseStatus? status,
    LicenseNumber? licenseNumber,
    LicenseImage? licenseImage,
    LicenseDob? dob,
    bool? isValid,
    String? errorMessage,
  }) {
    return LicenseState(
      status: status ?? this.status,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseImage: licenseImage ?? this.licenseImage,
      dob: dob ?? this.dob,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        licenseNumber,
        licenseImage,
        dob,
        isValid,
        errorMessage,
      ];
}
