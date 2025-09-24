part of 'privacy_bloc.dart';

/// Privacy state containing all privacy preferences
final class PrivacyState extends Equatable {
  const PrivacyState({
    this.status = FormzSubmissionStatus.initial,
    this.dataSharingEnabled = true,
    this.locationTrackingEnabled = true,
    this.analyticsTrackingEnabled = true,
    this.marketingCommunicationsEnabled = false,
    this.profileVisibility = 'Public',
    this.dataRetentionPeriod = '2 years',
    this.cookieConsent = true,
    this.thirdPartySharing = false,
    this.dataEncryption = true,
    this.errorMessage,
  });

  final FormzSubmissionStatus status;
  final bool dataSharingEnabled;
  final bool locationTrackingEnabled;
  final bool analyticsTrackingEnabled;
  final bool marketingCommunicationsEnabled;
  final String profileVisibility;
  final String dataRetentionPeriod;
  final bool cookieConsent;
  final bool thirdPartySharing;
  final bool dataEncryption;
  final String? errorMessage;

  /// Returns true if privacy settings are currently being loaded
  bool get isLoading => status == FormzSubmissionStatus.inProgress;

  /// Returns true if privacy settings were loaded successfully
  bool get isSuccess => status == FormzSubmissionStatus.success;

  /// Returns true if privacy operation failed
  bool get isFailure => status == FormzSubmissionStatus.failure;

  /// Returns true if there's an error message
  bool get hasError => isFailure && errorMessage != null;

  /// Returns true if the form is currently being submitted
  bool get isSubmitting => status == FormzSubmissionStatus.inProgress;

  /// Returns true if any setting has been modified
  bool get hasChanges => dataSharingEnabled != true || 
                        locationTrackingEnabled != true || 
                        analyticsTrackingEnabled != true || 
                        marketingCommunicationsEnabled != false || 
                        profileVisibility != 'Public' ||
                        dataRetentionPeriod != '2 years' ||
                        cookieConsent != true ||
                        thirdPartySharing != false ||
                        dataEncryption != true;

  /// Returns available profile visibility options
  List<String> get profileVisibilityOptions => [
    'Public',
    'Private',
    'Friends Only',
  ];

  /// Returns available data retention periods
  List<String> get dataRetentionOptions => [
    '1 year',
    '2 years',
    '5 years',
    'Indefinitely',
  ];

  /// Returns privacy score (0-100)
  int get privacyScore {
    int score = 0;
    if (!dataSharingEnabled) score += 20;
    if (!locationTrackingEnabled) score += 20;
    if (!analyticsTrackingEnabled) score += 20;
    if (!marketingCommunicationsEnabled) score += 20;
    if (profileVisibility == 'Private') score += 20;
    return score;
  }

  /// Returns privacy level based on score
  String get privacyLevel {
    if (privacyScore >= 80) return 'High';
    if (privacyScore >= 60) return 'Medium';
    return 'Low';
  }

  PrivacyState copyWith({
    FormzSubmissionStatus? status,
    bool? dataSharingEnabled,
    bool? locationTrackingEnabled,
    bool? analyticsTrackingEnabled,
    bool? marketingCommunicationsEnabled,
    String? profileVisibility,
    String? dataRetentionPeriod,
    bool? cookieConsent,
    bool? thirdPartySharing,
    bool? dataEncryption,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PrivacyState(
      status: status ?? this.status,
      dataSharingEnabled: dataSharingEnabled ?? this.dataSharingEnabled,
      locationTrackingEnabled: locationTrackingEnabled ?? this.locationTrackingEnabled,
      analyticsTrackingEnabled: analyticsTrackingEnabled ?? this.analyticsTrackingEnabled,
      marketingCommunicationsEnabled: marketingCommunicationsEnabled ?? this.marketingCommunicationsEnabled,
      profileVisibility: profileVisibility ?? this.profileVisibility,
      dataRetentionPeriod: dataRetentionPeriod ?? this.dataRetentionPeriod,
      cookieConsent: cookieConsent ?? this.cookieConsent,
      thirdPartySharing: thirdPartySharing ?? this.thirdPartySharing,
      dataEncryption: dataEncryption ?? this.dataEncryption,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        dataSharingEnabled,
        locationTrackingEnabled,
        analyticsTrackingEnabled,
        marketingCommunicationsEnabled,
        profileVisibility,
        dataRetentionPeriod,
        cookieConsent,
        thirdPartySharing,
        dataEncryption,
        errorMessage,
      ];

  @override
  String toString() {
    return 'PrivacyState('
        'status: $status, '
        'dataSharingEnabled: $dataSharingEnabled, '
        'locationTrackingEnabled: $locationTrackingEnabled, '
        'analyticsTrackingEnabled: $analyticsTrackingEnabled, '
        'marketingCommunicationsEnabled: $marketingCommunicationsEnabled, '
        'profileVisibility: $profileVisibility, '
        'dataRetentionPeriod: $dataRetentionPeriod, '
        'cookieConsent: $cookieConsent, '
        'thirdPartySharing: $thirdPartySharing, '
        'dataEncryption: $dataEncryption, '
        'errorMessage: $errorMessage'
        ')';
  }
}
