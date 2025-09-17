part of 'work_bloc.dart';

class WorkState extends Equatable {
  /// {@macro work_state}
  const WorkState({
    this.selectedLocation,
    this.workLocationInput = const WorkLocationInput.pure(),
    this.referralCode = const ReferralCode.pure(),
    this.locations = const [],
    this.status = FormzSubmissionStatus.initial,
    this.isValid = false,
    this.errorMessage,
  });

  /// The currently selected work location.
  final WorkLocation? selectedLocation;

  /// The work location input field with validation.
  final WorkLocationInput workLocationInput;

  /// The referral code field with validation.
  final ReferralCode referralCode;

  /// List of available work locations.
  final List<WorkLocation> locations;

  /// The current form submission status.
  final FormzSubmissionStatus status;

  /// Whether the form is valid and can be submitted.
  final bool isValid;

  /// Error message if form submission fails.
  final String? errorMessage;

  /// Creates a copy of this state with the given fields replaced.
  WorkState copyWith({
    WorkLocation? selectedLocation,
    WorkLocationInput? workLocationInput,
    ReferralCode? referralCode,
    List<WorkLocation>? locations,
    FormzSubmissionStatus? status,
    bool? isValid,
    String? errorMessage,
  }) {
    return WorkState(
      selectedLocation: selectedLocation ?? this.selectedLocation,
      workLocationInput: workLocationInput ?? this.workLocationInput,
      referralCode: referralCode ?? this.referralCode,
      locations: locations ?? this.locations,
      status: status ?? this.status,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        selectedLocation,
        workLocationInput,
        referralCode,
        locations,
        status,
        isValid,
        errorMessage,
      ];
}
