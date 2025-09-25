import 'dart:async';

import 'package:auth_repo/auth_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

part 'login_event.dart';
part 'login_state.dart';

/// Bloc responsible for managing login form state and business logic
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({required this.authRepo}) : super(const LoginState()) {
    on<LoginPhoneChanged>(_onPhoneChanged);
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  final AuthRepo authRepo;

  /// Handles phone number changes
  void _onPhoneChanged(LoginPhoneChanged event, Emitter<LoginState> emit) {
    final phoneInput = PhoneInput.dirty(event.phone);
    
    emit(state.copyWith(
      phoneInput: phoneInput,
      status: FormzSubmissionStatus.initial,
      errorMessage: null,
    ));
  }

  /// Handles login form submission
  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    // Validate form before submission
    final phoneInput = PhoneInput.dirty(state.phoneInput.value);
    
    emit(state.copyWith(
      phoneInput: phoneInput,
      status: FormzSubmissionStatus.initial,
    ));

    if (!Formz.validate([phoneInput])) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: phoneInput.displayError ?? 'Please enter a valid phone number',
      ));
      return;
    }

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      // First check if phone exists
      final checkResponse = await authRepo.checkPhone(phoneInput.cleanValue);
      
      if (!checkResponse.success) {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: checkResponse.message ?? 'Failed to check phone number',
        ));
        return;
      }

      // Send OTP
      final request = LoginRequest(
        phone: phoneInput.cleanValue,
        countryCode: '+91',
      );
      
      final response = await authRepo.sendOtp(request);
      
      if (response.success && response.otpSent) {
        emit(state.copyWith(
          status: FormzSubmissionStatus.success,
          phoneExists: checkResponse.user?.isNewUser == false,
        ));
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: response.message ?? 'Failed to send OTP. Please try again.',
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
