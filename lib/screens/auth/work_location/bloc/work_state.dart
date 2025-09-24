part of 'work_bloc.dart';

/// Work location state containing form data and submission status
final class WorkState extends Equatable {
  const WorkState({
    this.selectedLocation,
    this.workLocationInput = const WorkLocationInput.pure(),
    this.referralCode = const ReferralCode.pure(),
    this.locations = const [],
    this.status = FormzSubmissionStatus.initial,
    this.errorMessage,
  });

  final WorkLocation? selectedLocation;
  final WorkLocationInput workLocationInput;
  final ReferralCode referralCode;
  final List<WorkLocation> locations;
  final FormzSubmissionStatus status;
  final String? errorMessage;

  /// Returns true if the form is valid and ready for submission
  bool get isValid => Formz.validate([workLocationInput, referralCode]);

  /// Returns true if the form is currently being submitted
  bool get isSubmitting => status == FormzSubmissionStatus.inProgress;

  /// Returns true if the submission was successful
  bool get isSuccess => status == FormzSubmissionStatus.success;

  /// Returns true if the submission failed
  bool get isFailure => status == FormzSubmissionStatus.failure;

  /// Returns true if there's an error
  bool get hasError => isFailure && errorMessage != null;

  WorkState copyWith({
    WorkLocation? selectedLocation,
    WorkLocationInput? workLocationInput,
    ReferralCode? referralCode,
    List<WorkLocation>? locations,
    FormzSubmissionStatus? status,
    String? errorMessage,
  }) {
    return WorkState(
      selectedLocation: selectedLocation ?? this.selectedLocation,
      workLocationInput: workLocationInput ?? this.workLocationInput,
      referralCode: referralCode ?? this.referralCode,
      locations: locations ?? this.locations,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        selectedLocation,
        workLocationInput,
        referralCode,
        locations,
        status,
        errorMessage,
      ];

  @override
  String toString() {
    return 'WorkState('
        'selectedLocation: $selectedLocation, '
        'workLocationInput: $workLocationInput, '
        'referralCode: $referralCode, '
        'locations: ${locations.length}, '
        'status: $status, '
        'errorMessage: $errorMessage'
        ')';
  }
}
