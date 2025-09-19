part of 'insurance_bloc.dart';

enum InsuranceImageValidationError { empty, invalidFormat }

class InsuranceImage extends FormzInput<String, InsuranceImageValidationError> {
  const InsuranceImage.pure() : super.pure('');
  const InsuranceImage.dirty([super.value = '']) : super.dirty();

  @override
  InsuranceImageValidationError? validator(String value) {
    if (value.isEmpty) return InsuranceImageValidationError.empty;
    
    // Check if it's a valid image file (PDF, PNG, JPG, JPEG)
    final validExtensions = ['.pdf', '.png', '.jpg', '.jpeg'];
    final hasValidExtension = validExtensions.any((ext) => 
        value.toLowerCase().endsWith(ext));
    
    if (!hasValidExtension) {
      return InsuranceImageValidationError.invalidFormat;
    }
    
    return null;
  }

  /// Returns a user-friendly error message for the current error
  @override
  InsuranceImageValidationError? get displayError {
    return error;
  }

  /// Returns a user-friendly error message string
  String? get errorMessage {
    if (error == null) return null;
    switch (error!) {
      case InsuranceImageValidationError.empty:
        return 'Insurance document is required';
      case InsuranceImageValidationError.invalidFormat:
        return 'Please upload a valid document (PDF, PNG, JPG)';
    }
  }
}

/// Insurance state containing form data and submission status
final class InsuranceState extends Equatable {
  const InsuranceState({
    this.status = FormzSubmissionStatus.initial,
    this.insuranceImage = const InsuranceImage.pure(),
    this.errorMessage,
  });

  final FormzSubmissionStatus status;
  final InsuranceImage insuranceImage;
  final String? errorMessage;

  /// Returns true if the form is valid and ready for submission
  bool get isValid => Formz.validate([insuranceImage]);

  /// Returns true if the form is currently being submitted
  bool get isSubmitting => status == FormzSubmissionStatus.inProgress;

  /// Returns true if the submission was successful
  bool get isSuccess => status == FormzSubmissionStatus.success;

  /// Returns true if the submission failed
  bool get isFailure => status == FormzSubmissionStatus.failure;

  /// Returns true if there's an error
  bool get hasError => isFailure && errorMessage != null;

  InsuranceState copyWith({
    FormzSubmissionStatus? status,
    InsuranceImage? insuranceImage,
    String? errorMessage,
  }) {
    return InsuranceState(
      status: status ?? this.status,
      insuranceImage: insuranceImage ?? this.insuranceImage,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        insuranceImage,
        errorMessage,
      ];

  @override
  String toString() {
    return 'InsuranceState('
        'status: $status, '
        'insuranceImage: $insuranceImage, '
        'errorMessage: $errorMessage'
        ')';
  }
}
