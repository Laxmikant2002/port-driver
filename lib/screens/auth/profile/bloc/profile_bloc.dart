import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({required String phone}) : super(ProfileState(phone: phone)) {
    on<ProfileFirstNameChanged>(_onFirstNameChanged);
    on<ProfileLastNameChanged>(_onLastNameChanged);
    on<ProfileEmailChanged>(_onEmailChanged);
    on<ProfileAlternativePhoneChanged>(_onAlternativePhoneChanged);
    on<ProfileSubmitted>(_onSubmitted);
  }

  void _onFirstNameChanged(
    ProfileFirstNameChanged event,
    Emitter<ProfileState> emit,
  ) {
    final firstName = FirstName.dirty(event.firstName);
    emit(
      state.copyWith(
        firstName: firstName,
        isValid: Formz.validate([
          firstName,
          state.lastName,
          state.email,
          state.alternativePhone,
        ]),
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
        isValid: Formz.validate([
          state.firstName,
          lastName,
          state.email,
          state.alternativePhone,
        ]),
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
        isValid: Formz.validate([
          state.firstName,
          state.lastName,
          email,
          state.alternativePhone,
        ]),
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
        isValid: Formz.validate([
          state.firstName,
          state.lastName,
          state.email,
          alternativePhone,
        ]),
      ),
    );
  }

  void _onSubmitted(
    ProfileSubmitted event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.isValid) {
      emit(state.copyWith(status: ProfileStatus.loading));
      try {
        // TODO: Implement profile submission to API
        await Future<void>.delayed(const Duration(seconds: 2)); // Simulate API call
        emit(state.copyWith(status: ProfileStatus.success));
      } catch (error) {
        emit(
          state.copyWith(
            status: ProfileStatus.failure,
            errorMessage: error.toString(),
          ),
        );
      }
    }
  }
}
