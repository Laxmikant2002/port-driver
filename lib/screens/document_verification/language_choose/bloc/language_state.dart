part of 'language_bloc.dart';

enum LanguageValidationError { empty }

class LanguageInput extends FormzInput<String, LanguageValidationError> {
  const LanguageInput.pure() : super.pure('English');
  const LanguageInput.dirty([super.value = 'English']) : super.dirty();

  @override
  LanguageValidationError? validator(String value) {
    if (value.isEmpty) return LanguageValidationError.empty;
    return null;
  }

  @override
  LanguageValidationError? get displayError => error;
}

/// Language state containing form data and submission status
final class LanguageState extends Equatable {
  const LanguageState({
    this.status = FormzSubmissionStatus.initial,
    this.language = const LanguageInput.pure(),
    this.errorMessage,
  });

  final FormzSubmissionStatus status;
  final LanguageInput language;
  final String? errorMessage;

  /// Returns true if the form is valid and ready for submission
  bool get isValid => Formz.validate([language]);

  /// Returns true if the form is currently being submitted
  bool get isSubmitting => status == FormzSubmissionStatus.inProgress;

  /// Returns true if the submission was successful
  bool get isSuccess => status == FormzSubmissionStatus.success;

  /// Returns true if the submission failed
  bool get isFailure => status == FormzSubmissionStatus.failure;

  /// Returns true if there's an error
  bool get hasError => isFailure && errorMessage != null;

  LanguageState copyWith({
    FormzSubmissionStatus? status,
    LanguageInput? language,
    String? errorMessage,
  }) {
    return LanguageState(
      status: status ?? this.status,
      language: language ?? this.language,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, language, errorMessage];

  @override
  String toString() {
    return 'LanguageState('
        'status: $status, '
        'language: $language, '
        'errorMessage: $errorMessage'
        ')';
  }
}
