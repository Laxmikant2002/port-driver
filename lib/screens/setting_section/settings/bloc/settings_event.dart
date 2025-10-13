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
  const NotificationSettingsChanged(this.notificationSettings);

  final NotificationSettings notificationSettings;

  @override
  List<Object> get props => [notificationSettings];

  @override
  String toString() => 'NotificationSettingsChanged(notificationSettings: $notificationSettings)';
}

/// Event triggered when privacy settings are changed
final class PrivacySettingsChanged extends SettingsEvent {
  const PrivacySettingsChanged(this.privacySettings);

  final PrivacySettings privacySettings;

  @override
  List<Object> get props => [privacySettings];

  @override
  String toString() => 'PrivacySettingsChanged(privacySettings: $privacySettings)';
}

/// Event triggered when appearance settings are changed
final class AppearanceSettingsChanged extends SettingsEvent {
  const AppearanceSettingsChanged(this.appearanceSettings);

  final AppearanceSettings appearanceSettings;

  @override
  List<Object> get props => [appearanceSettings];

  @override
  String toString() => 'AppearanceSettingsChanged(appearanceSettings: $appearanceSettings)';
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