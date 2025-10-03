import 'dart:async';

import 'package:auth_repo/auth_repo.dart';
import 'package:driver/services/system/route_flow_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:profile_repo/profile_repo.dart';

part 'profile_event.dart';
part 'profile_state.dart';

/// BLoC responsible for managing profile creation/update state and business logic
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required this.authRepo,
    required this.profileRepo,
    required this.user,
    this.existingProfile,
    this.isNewUser = true,
  }) : super(const ProfileState()) {
    on<ProfileInitialized>(_onInitialized);
    on<ProfileNameChanged>(_onNameChanged);
    on<ProfileDateOfBirthChanged>(_onDateOfBirthChanged);
    on<ProfileGenderChanged>(_onGenderChanged);
    on<ProfilePhotoChanged>(_onPhotoChanged);
    on<ProfileSubmitted>(_onSubmitted);
  }

  final AuthRepo authRepo;
  final ProfileRepo profileRepo;
  final AuthUser user;
  final DriverProfile? existingProfile;
  final bool isNewUser;

  /// Handles profile initialization
  void _onInitialized(ProfileInitialized event, Emitter<ProfileState> emit) {
    if (existingProfile != null) {
      emit(state.copyWith(
        nameInput: NameInput.dirty(existingProfile!.fullName),
        dateOfBirth: existingProfile!.dateOfBirth,
        gender: existingProfile!.gender,
        profilePhoto: existingProfile!.profilePicture,
        status: FormzSubmissionStatus.initial,
      ));
    }
  }

  /// Handles name input changes
  void _onNameChanged(ProfileNameChanged event, Emitter<ProfileState> emit) {
    final nameInput = NameInput.dirty(event.name);
    emit(state.copyWith(
      nameInput: nameInput,
      status: FormzSubmissionStatus.initial,
      errorMessage: null,
    ));
  }

  /// Handles date of birth changes
  void _onDateOfBirthChanged(ProfileDateOfBirthChanged event, Emitter<ProfileState> emit) {
    emit(state.copyWith(
      dateOfBirth: event.dateOfBirth,
      status: FormzSubmissionStatus.initial,
    ));
  }

  /// Handles gender selection changes
  void _onGenderChanged(ProfileGenderChanged event, Emitter<ProfileState> emit) {
    emit(state.copyWith(
      gender: event.gender,
      status: FormzSubmissionStatus.initial,
    ));
  }

  /// Handles profile photo changes
  void _onPhotoChanged(ProfilePhotoChanged event, Emitter<ProfileState> emit) {
    emit(state.copyWith(
      profilePhoto: event.photoPath,
      status: FormzSubmissionStatus.initial,
    ));
  }

  /// Handles profile form submission
  Future<void> _onSubmitted(ProfileSubmitted event, Emitter<ProfileState> emit) async {
    // Validate form before submission
    final nameInput = NameInput.dirty(state.nameInput.value);
    
    emit(state.copyWith(
      nameInput: nameInput,
      status: FormzSubmissionStatus.initial,
    ));

    if (!Formz.validate([nameInput])) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: nameInput.displayError ?? 'Please enter a valid name',
      ));
      return;
    }

    if (state.dateOfBirth == null) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Please select your date of birth',
      ));
      return;
    }

    if (state.gender == null || state.gender!.isEmpty) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Please select your gender',
      ));
      return;
    }

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      final profileData = ProfileUpdateData(
        fullName: nameInput.value,
        dateOfBirth: state.dateOfBirth,
        gender: state.gender,
        profilePicture: state.profilePhoto,
        languagesSpoken: [], // Will be set in language selection screen
      );

      ProfileResponse response;
      
      if (isNewUser) {
        // Create new profile
        response = await profileRepo.createDriverProfile(user.phone, profileData);
      } else {
        // Update existing profile
        response = await profileRepo.updateDriverProfile(user.id, profileData);
      }

      if (response.success) {
        // Determine next step in onboarding
        final nextStep = RouteFlowService.getNextOnboardingStep(
          currentStep: '/profile-creation',
          completedSteps: ['profile'],
          missingRequirements: <String>[],
        );

        emit(state.copyWith(
          status: FormzSubmissionStatus.success,
          routeDecision: nextStep,
          updatedProfile: response.data,
        ));
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: response.message ?? 'Failed to save profile',
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