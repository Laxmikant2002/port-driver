part of 'settings_bloc.dart';

/// Settings state containing all user preferences
final class SettingsState extends Equatable {
  const SettingsState({
    this.status = FormzSubmissionStatus.initial,
    this.language = 'English',
    this.notificationsEnabled = true,
    this.locationServicesEnabled = true,
    this.errorMessage,
  });

  final FormzSubmissionStatus status;
  final String language;
  final bool notificationsEnabled;
  final bool locationServicesEnabled;
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

  /// Returns true if any setting has been modified
  bool get hasChanges => language != 'English' || 
                        !notificationsEnabled || 
                        !locationServicesEnabled;

  /// Returns available languages
  List<String> get availableLanguages => [
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


  SettingsState copyWith({
    FormzSubmissionStatus? status,
    String? language,
    bool? notificationsEnabled,
    bool? locationServicesEnabled,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SettingsState(
      status: status ?? this.status,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      locationServicesEnabled: locationServicesEnabled ?? this.locationServicesEnabled,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        language,
        notificationsEnabled,
        locationServicesEnabled,
        errorMessage,
      ];

  @override
  String toString() {
    return 'SettingsState('
        'status: $status, '
        'language: $language, '
        'notificationsEnabled: $notificationsEnabled, '
        'locationServicesEnabled: $locationServicesEnabled, '
        'errorMessage: $errorMessage'
        ')';
  }
}