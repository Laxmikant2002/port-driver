part of 'rc_bloc.dart';

enum RcNumberValidationError { empty, invalid }

class RcNumber extends FormzInput<String, RcNumberValidationError> {
  const RcNumber.pure() : super.pure('');
  const RcNumber.dirty([super.value = '']) : super.dirty();

  @override
  RcNumberValidationError? validator(String value) {
    if (value.isEmpty) return RcNumberValidationError.empty;
    if (value.length < 6) return RcNumberValidationError.invalid;
    return null;
  }

  /// Returns a user-friendly error message
  @override
  RcNumberValidationError? get displayError {
    return error;
  }

  String? get errorMessage {
    if (error == null) return null;
    switch (error!) {
      case RcNumberValidationError.empty:
        return 'RC number is required';
      case RcNumberValidationError.invalid:
        return 'RC number must be at least 6 characters';
    }
  }
}

enum RcImageValidationError { empty }

class RcImage extends FormzInput<String, RcImageValidationError> {
  const RcImage.pure() : super.pure('');
  const RcImage.dirty([super.value = '']) : super.dirty();

  @override
  RcImageValidationError? validator(String value) {
    if (value.isEmpty) return RcImageValidationError.empty;
    return null;
  }

  /// Returns a user-friendly error message
  @override
  RcImageValidationError? get displayError {
    return error;
  }

  String? get errorMessage {
    if (error == null) return null;
    switch (error!) {
      case RcImageValidationError.empty:
        return 'RC image is required';
    }
  }
}

enum VehicleNumberValidationError { empty, invalid }

class VehicleNumber extends FormzInput<String, VehicleNumberValidationError> {
  const VehicleNumber.pure() : super.pure('');
  const VehicleNumber.dirty([super.value = '']) : super.dirty();

  @override
  VehicleNumberValidationError? validator(String value) {
    if (value.isEmpty) return VehicleNumberValidationError.empty;
    // Indian vehicle number format validation
    final vehicleRegExp = RegExp(r'^[A-Z]{2}[0-9]{2}[A-Z]{2}[0-9]{4}$');
    if (!vehicleRegExp.hasMatch(value.toUpperCase())) {
      return VehicleNumberValidationError.invalid;
    }
    return null;
  }

  /// Returns a user-friendly error message
  @override
  VehicleNumberValidationError? get displayError {
    return error;
  }

  String? get errorMessage {
    if (error == null) return null;
    switch (error!) {
      case VehicleNumberValidationError.empty:
        return 'Vehicle number is required';
      case VehicleNumberValidationError.invalid:
        return 'Please enter a valid vehicle number (e.g., MH12AB1234)';
    }
  }
}


/// RC state containing form data and submission status
final class RcState extends Equatable {
  const RcState({
    this.status = FormzSubmissionStatus.initial,
    this.rcNumber = const RcNumber.pure(),
    this.rcImage = const RcImage.pure(),
    this.vehicleNumber = const VehicleNumber.pure(),
    this.errorMessage,
  });

  final FormzSubmissionStatus status;
  final RcNumber rcNumber;
  final RcImage rcImage;
  final VehicleNumber vehicleNumber;
  final String? errorMessage;

  /// Returns true if the form is valid and ready for submission
  bool get isValid => Formz.validate([rcNumber, rcImage, vehicleNumber]);

  /// Returns true if the form is currently being submitted
  bool get isSubmitting => status == FormzSubmissionStatus.inProgress;

  /// Returns true if the submission was successful
  bool get isSuccess => status == FormzSubmissionStatus.success;

  /// Returns true if the submission failed
  bool get isFailure => status == FormzSubmissionStatus.failure;

  /// Returns true if there's an error
  bool get hasError => isFailure && errorMessage != null;

  RcState copyWith({
    FormzSubmissionStatus? status,
    RcNumber? rcNumber,
    RcImage? rcImage,
    VehicleNumber? vehicleNumber,
    String? errorMessage,
  }) {
    return RcState(
      status: status ?? this.status,
      rcNumber: rcNumber ?? this.rcNumber,
      rcImage: rcImage ?? this.rcImage,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        rcNumber,
        rcImage,
        vehicleNumber,
        errorMessage,
      ];

  @override
  String toString() {
    return 'RcState('
        'status: $status, '
        'rcNumber: $rcNumber, '
        'rcImage: $rcImage, '
        'vehicleNumber: $vehicleNumber, '
        'errorMessage: $errorMessage'
        ')';
  }
}
