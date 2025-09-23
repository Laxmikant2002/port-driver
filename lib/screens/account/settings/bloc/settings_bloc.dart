import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState()) {
    on<SettingsLoaded>(_onSettingsLoaded);
    on<LanguageChanged>(_onLanguageChanged);
    on<NotificationSettingsChanged>(_onNotificationSettingsChanged);
    on<LocationServicesToggled>(_onLocationServicesToggled);
    on<SettingsSaved>(_onSettingsSaved);
    on<SettingsReset>(_onSettingsReset);
    on<AccountDeletionRequested>(_onAccountDeletionRequested);
  }

  Future<void> _onSettingsLoaded(
    SettingsLoaded event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      // In a real implementation, this would load settings from storage
      // For now, we'll use default values
      await Future.delayed(const Duration(milliseconds: 500));
      
      emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        clearError: true,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Failed to load settings: ${error.toString()}',
      ));
    }
  }

  void _onLanguageChanged(
    LanguageChanged event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(
      language: event.language,
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }


  void _onNotificationSettingsChanged(
    NotificationSettingsChanged event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(
      notificationsEnabled: event.enabled,
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }

  void _onLocationServicesToggled(
    LocationServicesToggled event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(
      locationServicesEnabled: event.enabled,
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }



  Future<void> _onSettingsSaved(
    SettingsSaved event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      // In a real implementation, this would save settings to storage
      await Future.delayed(const Duration(milliseconds: 500));
      
      emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        clearError: true,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Failed to save settings: ${error.toString()}',
      ));
    }
  }

  Future<void> _onSettingsReset(
    SettingsReset event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      // Reset to default values
      await Future.delayed(const Duration(milliseconds: 500));
      
      emit(const SettingsState(
        status: FormzSubmissionStatus.success,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Failed to reset settings: ${error.toString()}',
      ));
    }
  }

  Future<void> _onAccountDeletionRequested(
    AccountDeletionRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      // In a real implementation, this would delete the account
      await Future.delayed(const Duration(milliseconds: 1000));
      
      emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        clearError: true,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Failed to delete account: ${error.toString()}',
      ));
    }
  }
}