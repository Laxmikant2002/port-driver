import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:auth_repo/auth_repo.dart';

part 'otp_state.dart';
part 'otp_event.dart';

enum OtpInputError {
  empty,
  invalidLength,
}

class OtpInputField extends FormzInput<String, OtpInputError> {
  const OtpInputField.pure() : super.pure('');
  const OtpInputField.dirty([super.value = '']) : super.dirty();

  @override
  OtpInputError? validator(String value) {
    if (value.isEmpty) return OtpInputError.empty;
    if (value.length != 6) return OtpInputError.invalidLength;
    return null;
  }

  static String getErrorMsg(OtpInputError? error) {
    switch (error) {
      case OtpInputError.empty:
        return 'Please enter OTP';
      case OtpInputError.invalidLength:
        return 'OTP must be 6 digits';
      case null:
        return '';
    }
  }
}

class OtpBloc extends Bloc<OtpEvent, OtpState> {
  OtpBloc(this.authRepo, this.phone) : super(const OtpState()) {
    on<ChangeOtp>(_changeOtp);
    on<VerifyOtp>(_verifyOtp);
    on<ResendOtp>(_resendOtp);
    on<ResendTimerTick>(_onResendTimerTick);
  }

  final AuthRepo authRepo;
  final String phone;
  Timer? _resendTimer;

  void _changeOtp(ChangeOtp event, Emitter<OtpState> emit) {
    final otpInput = OtpInputField.dirty(event.otp);
    emit(
      state.copyWith(
        otpInput: otpInput,
        status: FormzSubmissionStatus.initial,
        error: null,
      ),
    );
  }

  Future<void> _verifyOtp(VerifyOtp event, Emitter<OtpState> emit) async {
    // Validate OTP
    final otpInput = OtpInputField.dirty(state.otpInput.value);
    final otpError = otpInput.error;

    // Update state with validation results
    emit(state.copyWith(
      otpInput: otpInput,
      status: FormzSubmissionStatus.failure,
    ));

    // Check for validation errors
    if (otpError != null) {
      return;
    }

    // If validation passes, proceed with OTP verification
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      final error = await authRepo.verifyOtp(state.otpInput.value);
      
      if (error == null) {
        emit(state.copyWith(status: FormzSubmissionStatus.success));
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          error: error,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        error: 'An unexpected error occurred. Please try again.',
      ));
    }
  }

  Future<void> _resendOtp(ResendOtp event, Emitter<OtpState> emit) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      final error = await authRepo.resendOtp();
      
      if (error == null) {
        emit(state.copyWith(
          status: FormzSubmissionStatus.initial,
          canResend: false,
          resendTimer: 60,
        ));
        _startResendTimer();
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          error: error,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        error: 'An unexpected error occurred. Please try again.',
      ));
    }
  }

  void _onResendTimerTick(ResendTimerTick event, Emitter<OtpState> emit) {
    if (state.resendTimer > 0) {
      emit(state.copyWith(resendTimer: state.resendTimer - 1));
    } else {
      _resendTimer?.cancel();
      emit(state.copyWith(
        canResend: true,
        resendTimer: 0,
      ));
    }
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => add(const ResendTimerTick()),
    );
  }

  @override
  Future<void> close() {
    _resendTimer?.cancel();
    return super.close();
  }
}