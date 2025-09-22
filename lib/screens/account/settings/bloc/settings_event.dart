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

/// Event triggered when language is changed
final class LanguageChanged extends SettingsEvent {
  const LanguageChanged(this.language);

  final String language;

  @override
  List<Object> get props => [language];

  @override
  String toString() => 'LanguageChanged(language: $language)';
}

/// Event triggered when notification setting is changed
final class NotificationSettingChanged extends SettingsEvent {
  const NotificationSettingChanged({
    required this.settingType,
    required this.value,
  });

  final NotificationSettingType settingType;
  final bool value;

  @override
  List<Object> get props => [settingType, value];

  @override
  String toString() => 'NotificationSettingChanged(type: $settingType, value: $value)';
}

/// Event triggered when privacy setting is changed
final class PrivacySettingChanged extends SettingsEvent {
  const PrivacySettingChanged({
    required this.settingType,
    required this.value,
  });

  final PrivacySettingType settingType;
  final bool value;

  @override
  List<Object> get props => [settingType, value];

  @override
  String toString() => 'PrivacySettingChanged(type: $settingType, value: $value)';
}

/// Event triggered when appearance setting is changed
final class AppearanceSettingChanged extends SettingsEvent {
  const AppearanceSettingChanged({
    required this.settingType,
    required this.value,
  });

  final AppearanceSettingType settingType;
  final String value;

  @override
  List<Object> get props => [settingType, value];

  @override
  String toString() => 'AppearanceSettingChanged(type: $settingType, value: $value)';
}

/// Event triggered when settings form is submitted
final class SettingsSubmitted extends SettingsEvent {
  const SettingsSubmitted();

  @override
  String toString() => 'SettingsSubmitted()';
}

/// Event triggered when account is deleted
final class AccountDeleted extends SettingsEvent {
  const AccountDeleted();

  @override
  String toString() => 'AccountDeleted()';
}

/// Notification setting types
enum NotificationSettingType {
  rideNotifications,
  paymentNotifications,
  systemNotifications,
  promotionNotifications,
  emergencyNotifications,
  soundEnabled,
  vibrationEnabled,
}

/// Privacy setting types
enum PrivacySettingType {
  shareLocation,
  allowDataCollection,
  analyticsEnabled,
  crashReportingEnabled,
  marketingEmails,
}

/// Appearance setting types
enum AppearanceSettingType {
  theme,
  fontSize,
  colorScheme,
}