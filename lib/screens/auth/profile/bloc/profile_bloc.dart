import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';
import 'package:auth_repo/auth_repo.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required String phone,
    required this.authRepo,
  }) : super(ProfileState(phone: phone)) {
    on<ProfileFirstNameChanged>(_onFirstNameChanged);
    on<ProfileLastNameChanged>(_onLastNameChanged);
    on<ProfileEmailChanged>(_onEmailChanged);
    on<ProfileAlternativePhoneChanged>(_onAlternativePhoneChanged);
    on<ProfileSubmitted>(_onSubmitted);
  }

  final AuthRepo authRepo;

  void _onFirstNameChanged(
    ProfileFirstNameChanged event,
    Emitter<ProfileState> emit,
  ) {
    final firstName = FirstName.dirty(event.firstName);
    emit(
      state.copyWith(
        firstName: firstName,
        status: FormzSubmissionStatus.initial,
      ),
    );
  }

  void _onLastNameChanged(
    ProfileLastNameChanged event,
    Emitter<ProfileState> emit,
  ) {
    final lastName = LastName.dirty(event.lastName);
    emit(
      state.copyWith(
        lastName: lastName,
        status: FormzSubmissionStatus.initial,
      ),
    );
  }

  void _onEmailChanged(
    ProfileEmailChanged event,
    Emitter<ProfileState> emit,
  ) {
    final email = Email.dirty(event.email);
    emit(
      state.copyWith(
        email: email,
        status: FormzSubmissionStatus.initial,
      ),
    );
  }

  void _onAlternativePhoneChanged(
    ProfileAlternativePhoneChanged event,
    Emitter<ProfileState> emit,
  ) {
    final alternativePhone = AlternativePhone.dirty(event.alternativePhone);
    emit(
      state.copyWith(
        alternativePhone: alternativePhone,
        status: FormzSubmissionStatus.initial,
      ),
    );
  }

  void _onSubmitted(
    ProfileSubmitted event,
    Emitter<ProfileState> emit,
  ) async {
    // Validate all fields before submission
    final firstName = FirstName.dirty(state.firstName.value);
    final lastName = LastName.dirty(state.lastName.value);
    final email = Email.dirty(state.email.value);
    final alternativePhone = AlternativePhone.dirty(state.alternativePhone.value);

    emit(state.copyWith(
      firstName: firstName,
      lastName: lastName,
      email: email,
      alternativePhone: alternativePhone,
      status: FormzSubmissionStatus.initial,
    ));

    if (!state.isValid) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Please complete all required fields correctly',
      ));
      return;
    }

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      // Create user object with profile data
      final user = AuthUser(
        id: '', // Will be set by backend
        phone: state.phone,
        name: '${firstName.value} ${lastName.value}',
        email: email.value.isNotEmpty ? email.value : null,
        isVerified: true,
        isNewUser: false,
        profileComplete: true,
        documentVerified: false,
      );

      // Update profile using auth repo
      final response = await authRepo.updateProfile(user);
      
      if (response.success) {
        emit(state.copyWith(status: FormzSubmissionStatus.success));
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: response.message ?? 'Failed to create profile. Please try again.',
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Network error. Please try again.',
      ));
    }
  }
}
