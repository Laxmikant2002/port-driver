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
    on<NotificationSettingChanged>(_onNotificationSettingChanged);
    on<PrivacySettingChanged>(_onPrivacySettingChanged);
    on<AppearanceSettingChanged>(_onAppearanceSettingChanged);
    on<SettingsSubmitted>(_onSettingsSubmitted);
    on<AccountDeleted>(_onAccountDeleted);
  }

  final SharedRepo sharedRepo;

  Future<void> _onSettingsLoaded(
    SettingsLoaded event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      final settings = await sharedRepo.getSettings();
      
      if (settings != null) {
        await sharedRepo.cacheSettings(settings);
        
        emit(state.copyWith(
          settings: settings,
          status: FormzSubmissionStatus.success,
          clearError: true,
        ));
      } else {
        // Fallback to cached settings
        final cachedSettings = await sharedRepo.getCachedSettings();
        
        emit(state.copyWith(
          settings: cachedSettings,
          status: FormzSubmissionStatus.success,
          clearError: true,
        ));
      }
    } catch (error) {
      // Fallback to cached settings
      final cachedSettings = await sharedRepo.getCachedSettings();
      
      emit(state.copyWith(
        settings: cachedSettings,
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Network error: ${error.toString()}',
      ));
    }
  }

  void _onLanguageChanged(
    LanguageChanged event,
    Emitter<SettingsState> emit,
  ) {
    final language = LanguageInput.dirty(event.language);
    emit(state.copyWith(
      language: language,
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }

  void _onNotificationSettingChanged(
    NotificationSettingChanged event,
    Emitter<SettingsState> emit,
  ) {
    final currentSettings = state.settings;
    if (currentSettings == null) return;

    NotificationSettings updatedNotifications;
    switch (event.settingType) {
      case NotificationSettingType.rideNotifications:
        updatedNotifications = currentSettings.notifications.copyWith(
          rideNotifications: event.value,
        );
        break;
      case NotificationSettingType.paymentNotifications:
        updatedNotifications = currentSettings.notifications.copyWith(
          paymentNotifications: event.value,
        );
        break;
      case NotificationSettingType.systemNotifications:
        updatedNotifications = currentSettings.notifications.copyWith(
          systemNotifications: event.value,
        );
        break;
      case NotificationSettingType.promotionNotifications:
        updatedNotifications = currentSettings.notifications.copyWith(
          promotionNotifications: event.value,
        );
        break;
      case NotificationSettingType.emergencyNotifications:
        updatedNotifications = currentSettings.notifications.copyWith(
          emergencyNotifications: event.value,
        );
        break;
      case NotificationSettingType.soundEnabled:
        updatedNotifications = currentSettings.notifications.copyWith(
          soundEnabled: event.value,
        );
        break;
      case NotificationSettingType.vibrationEnabled:
        updatedNotifications = currentSettings.notifications.copyWith(
          vibrationEnabled: event.value,
        );
        break;
    }

    final updatedSettings = currentSettings.copyWith(
      notifications: updatedNotifications,
    );

    emit(state.copyWith(
      settings: updatedSettings,
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }

  void _onPrivacySettingChanged(
    PrivacySettingChanged event,
    Emitter<SettingsState> emit,
  ) {
    final currentSettings = state.settings;
    if (currentSettings == null) return;

    PrivacySettings updatedPrivacy;
    switch (event.settingType) {
      case PrivacySettingType.shareLocation:
        updatedPrivacy = currentSettings.privacy.copyWith(
          shareLocation: event.value,
        );
        break;
      case PrivacySettingType.allowDataCollection:
        updatedPrivacy = currentSettings.privacy.copyWith(
          allowDataCollection: event.value,
        );
        break;
      case PrivacySettingType.analyticsEnabled:
        updatedPrivacy = currentSettings.privacy.copyWith(
          analyticsEnabled: event.value,
        );
        break;
      case PrivacySettingType.crashReportingEnabled:
        updatedPrivacy = currentSettings.privacy.copyWith(
          crashReportingEnabled: event.value,
        );
        break;
      case PrivacySettingType.marketingEmails:
        updatedPrivacy = currentSettings.privacy.copyWith(
          marketingEmails: event.value,
        );
        break;
    }

    final updatedSettings = currentSettings.copyWith(
      privacy: updatedPrivacy,
    );

    emit(state.copyWith(
      settings: updatedSettings,
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }

  void _onAppearanceSettingChanged(
    AppearanceSettingChanged event,
    Emitter<SettingsState> emit,
  ) {
    final currentSettings = state.settings;
    if (currentSettings == null) return;

    AppearanceSettings updatedAppearance;
    switch (event.settingType) {
      case AppearanceSettingType.theme:
        updatedAppearance = currentSettings.appearance.copyWith(
          theme: event.value,
        );
        break;
      case AppearanceSettingType.fontSize:
        updatedAppearance = currentSettings.appearance.copyWith(
          fontSize: event.value,
        );
        break;
      case AppearanceSettingType.colorScheme:
        updatedAppearance = currentSettings.appearance.copyWith(
          colorScheme: event.value,
        );
        break;
    }

    final updatedSettings = currentSettings.copyWith(
      appearance: updatedAppearance,
    );

    emit(state.copyWith(
      settings: updatedSettings,
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }

  Future<void> _onSettingsSubmitted(
    SettingsSubmitted event,
    Emitter<SettingsState> emit,
  ) async {
    final currentSettings = state.settings;
    if (currentSettings == null) return;

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress, clearError: true));
    
    try {
      final success = await sharedRepo.updateSettings(currentSettings);
      
      if (success) {
        await sharedRepo.cacheSettings(currentSettings);
        emit(state.copyWith(
          status: FormzSubmissionStatus.success,
          clearError: true,
        ));
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: 'Failed to update settings',
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Settings update error: ${error.toString()}',
      ));
    }
  }

  Future<void> _onAccountDeleted(
    AccountDeleted event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress, clearError: true));
    
    try {
      // Account deletion would be handled by a separate endpoint
      // For now, we'll simulate it
      emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        clearError: true,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Account deletion error: ${error.toString()}',
      ));
    }
  }
}