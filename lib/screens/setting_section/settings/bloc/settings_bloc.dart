import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_repo/shared_repo.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc({required this.sharedRepo}) : super(const SettingsState()) {
    on<SettingsLoaded>(_onSettingsLoaded);
    on<LanguageChanged>(_onLanguageChanged);
    on<NotificationSettingsChanged>(_onNotificationSettingsChanged);
    on<PrivacySettingsChanged>(_onPrivacySettingsChanged);
    on<AppearanceSettingsChanged>(_onAppearanceSettingsChanged);
    on<SettingsSaved>(_onSettingsSaved);
    on<SettingsReset>(_onSettingsReset);
    on<AccountDeletionRequested>(_onAccountDeletionRequested);
  }

  final SharedRepo sharedRepo;

  Future<void> _onSettingsLoaded(
    SettingsLoaded event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      // Try to load settings from repository
      final settings = await sharedRepo.getCachedSettings();
      
      if (settings != null) {
        emit(state.copyWith(
          settings: settings,
          status: FormzSubmissionStatus.success,
          clearError: true,
        ));
      } else {
        // Load from API if not cached
        final apiSettings = await sharedRepo.getSettings();
        if (apiSettings != null) {
          await sharedRepo.cacheSettings(apiSettings);
          emit(state.copyWith(
            settings: apiSettings,
            status: FormzSubmissionStatus.success,
            clearError: true,
          ));
        } else {
          // Use default settings
          emit(state.copyWith(
            settings: _getDefaultSettings(),
            status: FormzSubmissionStatus.success,
            clearError: true,
          ));
        }
      }
    } catch (error) {
      // Fallback to default settings
      emit(state.copyWith(
        settings: _getDefaultSettings(),
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Failed to load settings: ${error.toString()}',
      ));
    }
  }

  void _onLanguageChanged(
    LanguageChanged event,
    Emitter<SettingsState> emit,
  ) {
    if (state.settings != null) {
      final updatedSettings = state.settings!.copyWith(
        language: state.settings!.language.copyWith(
          currentLanguage: event.language,
        ),
      );
      emit(state.copyWith(
        settings: updatedSettings,
        status: FormzSubmissionStatus.initial,
        clearError: true,
      ));
    }
  }

  void _onNotificationSettingsChanged(
    NotificationSettingsChanged event,
    Emitter<SettingsState> emit,
  ) {
    if (state.settings != null) {
      final updatedSettings = state.settings!.copyWith(
        notifications: event.notificationSettings,
      );
      emit(state.copyWith(
        settings: updatedSettings,
        status: FormzSubmissionStatus.initial,
        clearError: true,
      ));
    }
  }

  void _onPrivacySettingsChanged(
    PrivacySettingsChanged event,
    Emitter<SettingsState> emit,
  ) {
    if (state.settings != null) {
      final updatedSettings = state.settings!.copyWith(
        privacy: event.privacySettings,
      );
      emit(state.copyWith(
        settings: updatedSettings,
        status: FormzSubmissionStatus.initial,
        clearError: true,
      ));
    }
  }

  void _onAppearanceSettingsChanged(
    AppearanceSettingsChanged event,
    Emitter<SettingsState> emit,
  ) {
    if (state.settings != null) {
      final updatedSettings = state.settings!.copyWith(
        appearance: event.appearanceSettings,
      );
      emit(state.copyWith(
        settings: updatedSettings,
        status: FormzSubmissionStatus.initial,
        clearError: true,
      ));
    }
  }



  Future<void> _onSettingsSaved(
    SettingsSaved event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      if (state.settings != null) {
        // Save to repository
        final success = await sharedRepo.updateSettings(state.settings!);
        
        if (success) {
          // Cache the updated settings
          await sharedRepo.cacheSettings(state.settings!);
          
          emit(state.copyWith(
            status: FormzSubmissionStatus.success,
            clearError: true,
          ));
        } else {
          emit(state.copyWith(
            status: FormzSubmissionStatus.failure,
            errorMessage: 'Failed to save settings to server',
          ));
        }
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: 'No settings to save',
        ));
      }
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
      final defaultSettings = _getDefaultSettings();
      
      // Save default settings
      final success = await sharedRepo.updateSettings(defaultSettings);
      
      if (success) {
        await sharedRepo.cacheSettings(defaultSettings);
        
        emit(SettingsState(
          settings: defaultSettings,
          status: FormzSubmissionStatus.success,
        ));
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: 'Failed to reset settings',
        ));
      }
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
      // In a real implementation, this would call the auth repository to delete the account
      // For now, we'll simulate the process
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

  /// Get default settings
  Settings _getDefaultSettings() {
    return Settings(
      id: 'default',
      driverId: 'current_driver',
      language: const LanguageSettings(
        currentLanguage: 'English',
        availableLanguages: ['English', 'Hindi', 'Tamil', 'Telugu', 'Kannada', 'Malayalam', 'Bengali', 'Gujarati', 'Marathi', 'Punjabi'],
      ),
      notifications: const NotificationSettings(),
      privacy: const PrivacySettings(),
      appearance: const AppearanceSettings(),
      version: '1.0.0',
      lastUpdated: DateTime.now(),
    );
  }
}