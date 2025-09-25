import 'dart:async';

import 'package:auth_repo/auth_repo.dart';
import 'package:driver/services/route_flow_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:profile_repo/profile_repo.dart';

part 'language_selection_event.dart';
part 'language_selection_state.dart';

/// BLoC responsible for managing language selection state and business logic
class LanguageSelectionBloc extends Bloc<LanguageSelectionEvent, LanguageSelectionState> {
  LanguageSelectionBloc({
    required this.authRepo,
    required this.profileRepo,
    required this.user,
    this.profile,
  }) : super(const LanguageSelectionState()) {
    on<LanguageToggled>(_onLanguageToggled);
    on<LanguageSelectionSubmitted>(_onSubmitted);
  }

  final AuthRepo authRepo;
  final ProfileRepo profileRepo;
  final AuthUser user;
  final DriverProfile? profile;

  /// Handles language toggle
  void _onLanguageToggled(LanguageToggled event, Emitter<LanguageSelectionState> emit) {
    final currentLanguages = List<String>.from(state.selectedLanguages);
    
    if (currentLanguages.contains(event.languageCode)) {
      currentLanguages.remove(event.languageCode);
    } else {
      currentLanguages.add(event.languageCode);
    }

    emit(state.copyWith(
      selectedLanguages: currentLanguages,
      status: FormzSubmissionStatus.initial,
      errorMessage: null,
    ));
  }

  /// Handles language selection submission
  Future<void> _onSubmitted(
    LanguageSelectionSubmitted event,
    Emitter<LanguageSelectionState> emit,
  ) async {
    if (state.selectedLanguages.isEmpty) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Please select at least one language',
      ));
      return;
    }

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      // Update profile with selected languages
      if (profile != null) {
        final profileData = ProfileUpdateData(
          fullName: profile!.fullName,
          dateOfBirth: profile!.dateOfBirth,
          gender: profile!.gender,
          profilePicture: profile!.profilePicture,
          languagesSpoken: state.selectedLanguages,
        );

        final response = await profileRepo.updateDriverProfile(user.id, profileData);

        if (response.success) {
          // Determine next step in onboarding
          final nextStep = RouteFlowService.getNextOnboardingStep(
            currentStep: '/language-selection',
            completedSteps: ['profile', 'language'],
            missingRequirements: <String>[],
          );

          emit(state.copyWith(
            status: FormzSubmissionStatus.success,
            routeDecision: nextStep,
          ));
        } else {
          emit(state.copyWith(
            status: FormzSubmissionStatus.failure,
            errorMessage: response.message ?? 'Failed to save language preferences',
          ));
        }
      } else {
        // If no profile exists, continue to next step
        final nextStep = RouteFlowService.getNextOnboardingStep(
          currentStep: '/language-selection',
          completedSteps: ['profile', 'language'],
          missingRequirements: <String>[],
        );

        emit(state.copyWith(
          status: FormzSubmissionStatus.success,
          routeDecision: nextStep,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Network error. Please try again.',
      ));
    }
  }
}

/// Language option model
class LanguageOption {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });

  static const List<LanguageOption> availableLanguages = [
    LanguageOption(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      flag: '🇺🇸',
    ),
    LanguageOption(
      code: 'hi',
      name: 'Hindi',
      nativeName: 'हिन्दी',
      flag: '🇮🇳',
    ),
    LanguageOption(
      code: 'mr',
      name: 'Marathi',
      nativeName: 'मराठी',
      flag: '🇮🇳',
    ),
    LanguageOption(
      code: 'bn',
      name: 'Bengali',
      nativeName: 'বাংলা',
      flag: '🇮🇳',
    ),
    LanguageOption(
      code: 'te',
      name: 'Telugu',
      nativeName: 'తెలుగు',
      flag: '🇮🇳',
    ),
    LanguageOption(
      code: 'ta',
      name: 'Tamil',
      nativeName: 'தமிழ்',
      flag: '🇮🇳',
    ),
    LanguageOption(
      code: 'gu',
      name: 'Gujarati',
      nativeName: 'ગુજરાતી',
      flag: '🇮🇳',
    ),
    LanguageOption(
      code: 'kn',
      name: 'Kannada',
      nativeName: 'ಕನ್ನಡ',
      flag: '🇮🇳',
    ),
  ];
}
