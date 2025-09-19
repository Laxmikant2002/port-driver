part of 'aadhar_bloc.dart';

enum AadharFrontImageValidationError { empty }

class AadharFrontImage extends FormzInput<String, AadharFrontImageValidationError> {
  const AadharFrontImage.pure() : super.pure('');
  const AadharFrontImage.dirty([super.value = '']) : super.dirty();

  @override
  AadharFrontImageValidationError? validator(String value) {
    if (value.isEmpty) return AadharFrontImageValidationError.empty;
    return null;
  }

  /// Returns a user-friendly error message
  String? get displayErrorMessage {
    if (error == null) return null;
    switch (error!) {
      case AadharFrontImageValidationError.empty:
        return 'Aadhaar front image is required';
    }
  }
}

enum AadharBackImageValidationError { empty }

class AadharBackImage extends FormzInput<String, AadharBackImageValidationError> {
  const AadharBackImage.pure() : super.pure('');
  const AadharBackImage.dirty([super.value = '']) : super.dirty();

  @override
  AadharBackImageValidationError? validator(String value) {
    if (value.isEmpty) return AadharBackImageValidationError.empty;
    return null;
  }

  /// Returns a user-friendly error message
  String? get displayErrorMessage {
    if (error == null) return null;
    switch (error!) {
      case AadharBackImageValidationError.empty:
        return 'Aadhaar back image is required';
    }
  }
}

/// Aadhar state containing form data and submission status
final class AadharState extends Equatable {
  const AadharState({
    this.status = FormzSubmissionStatus.initial,
    this.frontImage = const AadharFrontImage.pure(),
    this.backImage = const AadharBackImage.pure(),
    this.errorMessage,
  });

  final FormzSubmissionStatus status;
  final AadharFrontImage frontImage;
  final AadharBackImage backImage;
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

  AadharState copyWith({
    FormzSubmissionStatus? status,
    AadharFrontImage? frontImage,
    AadharBackImage? backImage,
    String? errorMessage,
  }) {
    return AadharState(
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
    return 'AadharState('
        'status: $status, '
        'frontImage: $frontImage, '
        'backImage: $backImage, '
        'errorMessage: $errorMessage'
        ')';
  }
}
