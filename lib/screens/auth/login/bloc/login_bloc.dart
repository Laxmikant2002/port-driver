import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';

part 'login_event.dart';
part 'login_state.dart';

/// Bloc responsible for managing login form state and business logic
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginState()) {
    on<PhoneChanged>(_onPhoneChanged);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<ResendOtpRequested>(_onResendOtpRequested);
    on<LoginReset>(_onLoginReset);
  }

  /// Handles phone number changes
  void _onPhoneChanged(PhoneChanged event, Emitter<LoginState> emit) {
    final phoneInput = PhoneInput.dirty(event.phone);
    
    emit(state.copyWith(
      phoneInput: phoneInput,
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }

  /// Handles login form submission
  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (!state.isValid) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Please enter a valid phone number',
      ));
      return;
    }

    emit(state.copyWith(
      status: FormzSubmissionStatus.inProgress,
      clearError: true,
    ));

    try {
      // Simulate API call for sending OTP
      await Future<void>.delayed(const Duration(seconds: 2));
      
      emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        otpSent: true,
        errorMessage: 'OTP sent to ${state.phoneInput.cleanValue}',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Failed to send OTP. Please try again.',
      ));
    }
  }

  /// Handles OTP resend request
  Future<void> _onResendOtpRequested(
    ResendOtpRequested event,
    Emitter<LoginState> emit,
  ) async {
    if (!state.canResend) return;

    emit(state.copyWith(
      status: FormzSubmissionStatus.inProgress,
      clearError: true,
    ));

    try {
      // Simulate API call for resending OTP
      await Future<void>.delayed(const Duration(seconds: 1));
      
      // Start cooldown timer
      _startResendCooldown(emit);
      
      emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        errorMessage: 'OTP resent to ${state.phoneInput.cleanValue}',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Failed to resend OTP. Please try again.',
      ));
    }
  }

  /// Handles form reset
  void _onLoginReset(LoginReset event, Emitter<LoginState> emit) {
    emit(const LoginState());
  }

  /// Starts the resend cooldown timer
  void _startResendCooldown(Emitter<LoginState> emit) {
    const cooldownDuration = 30; // 30 seconds
    int remainingTime = cooldownDuration;
    
    Timer.periodic(const Duration(seconds: 1), (timer) {
      remainingTime--;
      
      if (remainingTime <= 0) {
        timer.cancel();
        emit(state.copyWith(resendCooldown: 0));
      } else {
        emit(state.copyWith(resendCooldown: remainingTime));
      }
    });
  }
}
