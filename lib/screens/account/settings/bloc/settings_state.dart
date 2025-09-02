part of 'settings_bloc.dart';

abstract class SettingsState extends Equatable {
    const SettingsState();

    @override
    List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState{}

class SettingsLoaded extends SettingsState {
    final String appVersion;
    final String currentLanguage;

    const SettingsLoaded ({
        required this.appVersion,
        required this.currentLanguage,
    });

    @override
    List<Object?> get props => [appVersion, currentLanguage];
}

class SettingsError extends SettingsState {
    final String message;

    const SettingsError(this.message);

    @override
    List<Object?> get props => [message];
}

class AccountDeleted extends SettingsState {}