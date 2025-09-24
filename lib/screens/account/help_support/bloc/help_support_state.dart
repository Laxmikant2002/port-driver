part of 'help_support_bloc.dart';

/// Help support state containing support contacts
final class HelpSupportState extends Equatable {
  const HelpSupportState({
    this.supportContacts = const [],
    this.emergencyContact,
    this.status = FormzSubmissionStatus.initial,
    this.errorMessage,
  });

  final List<SupportContact> supportContacts;
  final SupportContact? emergencyContact;
  final FormzSubmissionStatus status;
  final String? errorMessage;

  /// Returns true if the form is currently being submitted
  bool get isSubmitting => status == FormzSubmissionStatus.inProgress;

  /// Returns true if the submission was successful
  bool get isSuccess => status == FormzSubmissionStatus.success;

  /// Returns true if the submission failed
  bool get isFailure => status == FormzSubmissionStatus.failure;

  /// Returns true if there's an error
  bool get hasError => isFailure && errorMessage != null;

  /// Returns the current error message if any
  String? get error => errorMessage;

  /// Returns true if help support is currently being loaded
  bool get isLoading => status == FormzSubmissionStatus.inProgress;


  HelpSupportState copyWith({
    List<SupportContact>? supportContacts,
    SupportContact? emergencyContact,
    FormzSubmissionStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HelpSupportState(
      supportContacts: supportContacts ?? this.supportContacts,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        supportContacts,
        emergencyContact,
        status,
        errorMessage,
      ];

  @override
  String toString() {
    return 'HelpSupportState('
        'supportContacts: ${supportContacts.length}, '
        'emergencyContact: $emergencyContact, '
        'status: $status, '
        'errorMessage: $errorMessage'
        ')';
  }
}
