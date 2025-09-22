part of 'settings_bloc.dart';

// Validation error enums
enum LanguageValidationError { empty }

// Formz input classes
class LanguageInput extends FormzInput<String, LanguageValidationError> {
  const LanguageInput.pure() : super.pure('');
  const LanguageInput.dirty([super.value = '']) : super.dirty();

  @override
  LanguageValidationError? validator(String value) {
    if (value.isEmpty) return LanguageValidationError.empty;
    return null;
  }
}

/// Settings state containing settings data and submission status
final class SettingsState extends Equatable {
  const SettingsState({
    this.settings,
    this.language = const LanguageInput.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.errorMessage,
  });

  final Settings? settings;
  final LanguageInput language;
  final FormzSubmissionStatus status;
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

  /// Returns the current error message if any
  String? get error => errorMessage;

  /// Returns true if settings are currently being loaded
  bool get isLoading => status == FormzSubmissionStatus.inProgress;

  /// Returns current language
  String get currentLanguage => settings?.language.currentLanguage ?? 'English';

  /// Returns available languages
  List<String> get availableLanguages => settings?.language.availableLanguages ?? ['English', 'Hindi'];

  /// Returns notification settings
  NotificationSettings get notificationSettings => 
      settings?.notifications ?? const NotificationSettings();

  /// Returns privacy settings
  PrivacySettings get privacySettings => 
      settings?.privacy ?? const PrivacySettings();

  /// Returns appearance settings
  AppearanceSettings get appearanceSettings => 
      settings?.appearance ?? const AppearanceSettings();

  SettingsState copyWith({
    Settings? settings,
    LanguageInput? language,
    FormzSubmissionStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      language: language ?? this.language,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        settings,
        language,
        status,
        errorMessage,
      ];

  @override
  String toString() {
    return 'SettingsState('
        'settings: $settings, '
        'language: $language, '
        'status: $status, '
        'errorMessage: $errorMessage'
        ')';
  }
}