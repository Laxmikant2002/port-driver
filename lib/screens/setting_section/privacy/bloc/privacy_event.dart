part of 'privacy_bloc.dart';

/// Base class for all Privacy events
sealed class PrivacyEvent extends Equatable {
  const PrivacyEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered when privacy settings are loaded
final class PrivacySettingsLoaded extends PrivacyEvent {
  const PrivacySettingsLoaded();

  @override
  String toString() => 'PrivacySettingsLoaded()';
}

/// Event triggered when data sharing preference is changed
final class DataSharingToggled extends PrivacyEvent {
  const DataSharingToggled(this.enabled);

  final bool enabled;

  @override
  List<Object> get props => [enabled];

  @override
  String toString() => 'DataSharingToggled(enabled: $enabled)';
}

/// Event triggered when location tracking is toggled
final class LocationTrackingToggled extends PrivacyEvent {
  const LocationTrackingToggled(this.enabled);

  final bool enabled;

  @override
  List<Object> get props => [enabled];

  @override
  String toString() => 'LocationTrackingToggled(enabled: $enabled)';
}

/// Event triggered when analytics tracking is toggled
final class AnalyticsTrackingToggled extends PrivacyEvent {
  const AnalyticsTrackingToggled(this.enabled);

  final bool enabled;

  @override
  List<Object> get props => [enabled];

  @override
  String toString() => 'AnalyticsTrackingToggled(enabled: $enabled)';
}

/// Event triggered when marketing communications are toggled
final class MarketingCommunicationsToggled extends PrivacyEvent {
  const MarketingCommunicationsToggled(this.enabled);

  final bool enabled;

  @override
  List<Object> get props => [enabled];

  @override
  String toString() => 'MarketingCommunicationsToggled(enabled: $enabled)';
}

/// Event triggered when profile visibility is changed
final class ProfileVisibilityChanged extends PrivacyEvent {
  const ProfileVisibilityChanged(this.visibility);

  final String visibility;

  @override
  List<Object> get props => [visibility];

  @override
  String toString() => 'ProfileVisibilityChanged(visibility: $visibility)';
}

/// Event triggered when privacy settings are saved
final class PrivacySettingsSaved extends PrivacyEvent {
  const PrivacySettingsSaved();

  @override
  String toString() => 'PrivacySettingsSaved()';
}

/// Event triggered when data is requested to be deleted
final class DataDeletionRequested extends PrivacyEvent {
  const DataDeletionRequested();

  @override
  String toString() => 'DataDeletionRequested()';
}

/// Event triggered when privacy policy is viewed
final class PrivacyPolicyViewed extends PrivacyEvent {
  const PrivacyPolicyViewed();

  @override
  String toString() => 'PrivacyPolicyViewed()';
}

/// Event triggered when terms of service are viewed
final class TermsOfServiceViewed extends PrivacyEvent {
  const TermsOfServiceViewed();

  @override
  String toString() => 'TermsOfServiceViewed()';
}
