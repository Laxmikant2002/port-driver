part of 'license_bloc.dart';

enum LicenseFrontImageValidationError { empty }

class LicenseFrontImage extends FormzInput<String, LicenseFrontImageValidationError> {
  const LicenseFrontImage.pure() : super.pure('');
  const LicenseFrontImage.dirty([super.value = '']) : super.dirty();

  @override
  LicenseFrontImageValidationError? validator(String value) {
    if (value.isEmpty) return LicenseFrontImageValidationError.empty;
    return null;
  }

  /// Returns a user-friendly error message
  @override
  LicenseFrontImageValidationError? get displayError {
    return error;
  }

  String? get errorMessage {
    if (error == null) return null;
    switch (error!) {
      case LicenseFrontImageValidationError.empty:
        return 'Front image is required';
    }
  }
}

enum LicenseBackImageValidationError { empty }

class LicenseBackImage extends FormzInput<String, LicenseBackImageValidationError> {
  const LicenseBackImage.pure() : super.pure('');
  const LicenseBackImage.dirty([super.value = '']) : super.dirty();

  @override
  LicenseBackImageValidationError? validator(String value) {
    if (value.isEmpty) return LicenseBackImageValidationError.empty;
    return null;
  }

  /// Returns a user-friendly error message
  @override
  LicenseBackImageValidationError? get displayError {
    return error;
  }

  String? get errorMessage {
    if (error == null) return null;
    switch (error!) {
      case LicenseBackImageValidationError.empty:
        return 'Back image is required';
    }
  }
}


/// License state containing form data and submission status
final class LicenseState extends Equatable {
  const LicenseState({
    this.status = FormzSubmissionStatus.initial,
    this.frontImage = const LicenseFrontImage.pure(),
    this.backImage = const LicenseBackImage.pure(),
    this.errorMessage,
  });

  final FormzSubmissionStatus status;
  final LicenseFrontImage frontImage;
  final LicenseBackImage backImage;
  final String? errorMessage;

  /// Returns true if the form is valid and ready for submission
  bool get isValid => Formz.validate([frontImage, backImage]);

  /// Returns true if the form is currently being submitted
  bool get isSubmitting => status == FormzSubmissionStatus.inProgress;

  /// Returns true if the submission was successful
  bool get isSuccess => status == FormzSubmissionStatus.success;

  /// Returns true if the submission failed
  bool get isFailure => status == FormzSubmissionStatus.failure;

  /// Returns true if there's an error
  bool get hasError => isFailure && errorMessage != null;

  LicenseState copyWith({
    FormzSubmissionStatus? status,
    LicenseFrontImage? frontImage,
    LicenseBackImage? backImage,
    String? errorMessage,
  }) {
    return LicenseState(
      status: status ?? this.status,
      frontImage: frontImage ?? this.frontImage,
      backImage: backImage ?? this.backImage,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        frontImage,
        backImage,
        errorMessage,
      ];

  @override
  String toString() {
    return 'LicenseState('
        'status: $status, '
        'frontImage: $frontImage, '
        'backImage: $backImage, '
        'errorMessage: $errorMessage'
        ')';
  }
}
