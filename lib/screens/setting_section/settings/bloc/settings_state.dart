part of 'settings_bloc.dart';

/// Settings state containing all user preferences
final class SettingsState extends Equatable {
  const SettingsState({
    this.settings,
    this.status = FormzSubmissionStatus.initial,
    this.errorMessage,
  });

  final Settings? settings;
  final FormzSubmissionStatus status;
  final String? errorMessage;

  /// Returns true if settings are currently being loaded
  bool get isLoading => status == FormzSubmissionStatus.inProgress;

  /// Returns true if settings were loaded successfully
  bool get isSuccess => status == FormzSubmissionStatus.success;

  /// Returns true if settings operation failed
  bool get isFailure => status == FormzSubmissionStatus.failure;

  /// Returns true if there's an error message
  bool get hasError => isFailure && errorMessage != null;

  /// Returns true if the form is currently being submitted
  bool get isSubmitting => status == FormzSubmissionStatus.inProgress;

  /// Returns current language
  String get language => settings?.language.currentLanguage ?? 'English';

  /// Returns available languages
  List<String> get availableLanguages => settings?.language.availableLanguages ?? [
    'English',
    'Hindi',
    'Tamil',
    'Telugu',
    'Kannada',
    'Malayalam',
    'Bengali',
    'Gujarati',
    'Marathi',
    'Punjabi',
  ];

  /// Returns notification settings
  NotificationSettings get notificationSettings => settings?.notifications ?? const NotificationSettings();

  /// Returns privacy settings
  PrivacySettings get privacySettings => settings?.privacy ?? const PrivacySettings();

  /// Returns appearance settings
  AppearanceSettings get appearanceSettings => settings?.appearance ?? const AppearanceSettings();


  SettingsState copyWith({
    Settings? settings,
    FormzSubmissionStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        settings,
        status,
        errorMessage,
      ];

  @override
  String toString() {
    return 'SettingsState('
        'settings: $settings, '
        'status: $status, '
        'errorMessage: $errorMessage'
        ')';
  }
}