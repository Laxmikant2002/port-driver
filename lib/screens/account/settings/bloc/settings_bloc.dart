import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
    SettingsBloc() : super(SettingsInitial()){
        on<LoadSettings>(_onLoadSettings);
        on<ChangeLanguage>(_onChangeLanguage);
        on<DeleteAccountRequested> (_onDeleteAccountRequested);
    }

    Future<void> _onLoadSettings(
        LoadSettings event,
        Emitter<SettingsState> emit,
    ) async {
        try {
            emit(SettingsLoading());

            // Manually define the app version
            const version = '2.5.1';
            const currentLanguage = 'English';
            
            emit(SettingsLoaded(
                appVersion: version,
                currentLanguage: currentLanguage,
            ));
        } catch (error) {
            emit(SettingsError(error.toString()));
        }
    }

    Future<void> _onChangeLanguage(
        ChangeLanguage event,
        Emitter<SettingsState> emit,
    ) async {
        try {
            if (state is SettingsLoaded) {
                final currentState = state as SettingsLoaded;
                emit(SettingsLoading());

                emit(SettingsLoaded(
                    appVersion: currentState.appVersion,
                    currentLanguage: event.language,
                ));
            }
        } catch (error) {
            emit(SettingsError(error.toString()));
        }
    }

    Future<void> _onDeleteAccountRequested(
        DeleteAccountRequested event,
        Emitter<SettingsState> emit,
    ) async {
        try {
            emit(SettingsLoading());
            emit(AccountDeleted());
        } catch (error) {
            emit(SettingsError(error.toString()));
        }
    }
}