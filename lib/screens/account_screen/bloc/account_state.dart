part of 'account_bloc.dart';

enum NameValidationError { empty }

class Name extends FormzInput<String, NameValidationError> {
  const Name.pure() : super.pure('');
  const Name.dirty([super.value = '']) : super.dirty();

  @override
  NameValidationError? validator(String value) {
    if (value.isEmpty) return NameValidationError.empty;
    return null;
  }
}

enum VehicleValidationError { empty }

class Vehicle extends FormzInput<String, VehicleValidationError> {
  const Vehicle.pure() : super.pure('');
  const Vehicle.dirty([super.value = '']) : super.dirty();

  @override
  VehicleValidationError? validator(String value) {
    if (value.isEmpty) return VehicleValidationError.empty;
    return null;
  }
}

/// Account state containing form data and submission status
final class AccountState extends Equatable {
  const AccountState({
    this.status = FormzSubmissionStatus.initial,
    this.name = const Name.pure(),
    this.vehicle = const Vehicle.pure(),
    this.profileImage = '',
    this.errorMessage,
  });

  final FormzSubmissionStatus status;
  final Name name;
  final Vehicle vehicle;
  final String profileImage;
  final String? errorMessage;

  /// Returns true if account data is loaded
  bool get isValid => name.value.isNotEmpty;

  /// Returns true if the form is currently being submitted
  bool get isSubmitting => status == FormzSubmissionStatus.inProgress;

  /// Returns true if the submission was successful
  bool get isSuccess => status == FormzSubmissionStatus.success;

  /// Returns true if the submission failed
  bool get isFailure => status == FormzSubmissionStatus.failure;

  /// Returns true if there's an error
  bool get hasError => isFailure && errorMessage != null;

  /// Returns true if account is loaded
  bool get isLoaded => status == FormzSubmissionStatus.success;

  /// Returns true if account is loading
  bool get isLoading => status == FormzSubmissionStatus.inProgress;

  AccountState copyWith({
    FormzSubmissionStatus? status,
    Name? name,
    Vehicle? vehicle,
    String? profileImage,
    String? errorMessage,
  }) {
    return AccountState(
      status: status ?? this.status,
      name: name ?? this.name,
      vehicle: vehicle ?? this.vehicle,
      profileImage: profileImage ?? this.profileImage,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        name,
        vehicle,
        profileImage,
        errorMessage,
      ];

  @override
  String toString() {
    return 'AccountState('
        'status: $status, '
        'name: $name, '
        'vehicle: $vehicle, '
        'profileImage: $profileImage, '
        'errorMessage: $errorMessage'
        ')';
  }
}
