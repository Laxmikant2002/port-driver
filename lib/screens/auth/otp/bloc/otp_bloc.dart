import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';
import 'package:auth_repo/auth_repo.dart';

part 'otp_event.dart';
part 'otp_state.dart';

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
    final otpInput = OtpInput.dirty(event.otp);
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
    final otpInput = OtpInput.dirty(state.otpInput.value);
    final otpError = otpInput.error;

    // Check for validation errors
    if (otpError != null) {
      emit(state.copyWith(
        otpInput: otpInput,
        status: FormzSubmissionStatus.failure,
        error: otpInput.errorMessage,
      ));
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
          resendTimer: 24,
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