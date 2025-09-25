import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';
import 'package:auth_repo/auth_repo.dart';
import 'package:profile_repo/profile_repo.dart';
import 'package:driver/services/route_flow_service.dart';

part 'otp_event.dart';
part 'otp_state.dart';

/// BLoC responsible for managing OTP verification state and business logic
class OtpBloc extends Bloc<OtpEvent, OtpState> {
  OtpBloc({
    required this.authRepo,
    required this.profileRepo,
    required this.phone,
  }) : super(const OtpState()) {
    on<OtpChanged>(_onOtpChanged);
    on<OtpSubmitted>(_onOtpSubmitted);
    on<OtpResendRequested>(_onOtpResendRequested);
    on<_OtpResendTimerTicked>(_onResendTimerTicked);
  }

  final AuthRepo authRepo;
  final ProfileRepo profileRepo;
  final String phone;
  Timer? _resendTimer;

  /// Handles OTP input changes
  void _onOtpChanged(OtpChanged event, Emitter<OtpState> emit) {
    final otpInput = OtpInput.dirty(event.otp);
    emit(
      state.copyWith(
        otpInput: otpInput,
        status: FormzSubmissionStatus.initial,
        errorMessage: null,
      ),
    );
  }

  /// Handles OTP verification submission
  Future<void> _onOtpSubmitted(OtpSubmitted event, Emitter<OtpState> emit) async {
    // Validate OTP before submission
    final otpInput = OtpInput.dirty(state.otpInput.value);
    
    emit(state.copyWith(
      otpInput: otpInput,
      status: FormzSubmissionStatus.initial,
    ));

    if (!Formz.validate([otpInput])) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: otpInput.errorMessage ?? 'Please enter a valid OTP',
      ));
      return;
    }

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      final response = await authRepo.verifyOtp(state.otpInput.value);
      
      if (response.success && response.user != null) {
        // After successful OTP verification, determine the next route
        final routeDecision = await RouteFlowService.determineInitialRoute(
          user: response.user!,
          profileRepo: profileRepo,
        );
        
        emit(state.copyWith(
          status: FormzSubmissionStatus.success,
          user: response.user,
          routeDecision: routeDecision,
        ));
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: response.message ?? 'OTP verification failed',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Network error. Please try again.',
      ));
    }
  }

  /// Handles OTP resend request
  Future<void> _onOtpResendRequested(OtpResendRequested event, Emitter<OtpState> emit) async {
    if (!state.canResend) return;

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      final response = await authRepo.resendOtp();
      
      if (response.success) {
        emit(state.copyWith(
          status: FormzSubmissionStatus.initial,
          canResend: false,
          resendTimer: 30,
        ));
        _startResendTimer();
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: response.message ?? 'Failed to resend OTP',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Network error. Please try again.',
      ));
    }
  }

  /// Handles resend timer countdown
  void _onResendTimerTicked(_OtpResendTimerTicked event, Emitter<OtpState> emit) {
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

  /// Starts the resend timer countdown
  void _startResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => add(const _OtpResendTimerTicked()),
    );
  }

  @override
  Future<void> close() {
    _resendTimer?.cancel();
    return super.close();
  }
}