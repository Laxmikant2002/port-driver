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
}

enum LanguageStatus { initial, loading, success, failure }

class LanguageState extends Equatable {
  const LanguageState({
    this.status = LanguageStatus.initial,
    this.language = const LanguageInput.pure(),
    this.isValid = false,
    this.errorMessage,
  });

  final LanguageStatus status;
  final LanguageInput language;
  final bool isValid;
  final String? errorMessage;

  LanguageState copyWith({
    LanguageStatus? status,
    LanguageInput? language,
    bool? isValid,
    String? errorMessage,
  }) {
    return LanguageState(
      status: status ?? this.status,
      language: language ?? this.language,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, language, isValid, errorMessage];
}
