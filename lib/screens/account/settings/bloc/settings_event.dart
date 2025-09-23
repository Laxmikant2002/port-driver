part of 'settings_bloc.dart';

/// Base class for all Settings events
sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered when settings are loaded
final class SettingsLoaded extends SettingsEvent {
  const SettingsLoaded();

  @override
  String toString() => 'SettingsLoaded()';
}

/// Event triggered when language preference is changed
final class LanguageChanged extends SettingsEvent {
  const LanguageChanged(this.language);

  final String language;

  @override
  List<Object> get props => [language];

  @override
  String toString() => 'LanguageChanged(language: $language)';
}


/// Event triggered when notification settings are changed
final class NotificationSettingsChanged extends SettingsEvent {
  const NotificationSettingsChanged(this.enabled);

  final bool enabled;

  @override
  List<Object> get props => [enabled];

  @override
  String toString() => 'NotificationSettingsChanged(enabled: $enabled)';
}

/// Event triggered when location services are toggled
final class LocationServicesToggled extends SettingsEvent {
  const LocationServicesToggled(this.enabled);

  final bool enabled;

  @override
  List<Object> get props => [enabled];

  @override
  String toString() => 'LocationServicesToggled(enabled: $enabled)';
}


/// Event triggered when settings are saved
final class SettingsSaved extends SettingsEvent {
  const SettingsSaved();

  @override
  String toString() => 'SettingsSaved()';
}

/// Event triggered when settings are reset to default
final class SettingsReset extends SettingsEvent {
  const SettingsReset();

  @override
  String toString() => 'SettingsReset()';
}


/// Event triggered when account deletion is requested
final class AccountDeletionRequested extends SettingsEvent {
  const AccountDeletionRequested();

  @override
  String toString() => 'AccountDeletionRequested()';
}