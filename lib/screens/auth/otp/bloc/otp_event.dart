part of 'otp_bloc.dart';

/// Base class for all OTP events
sealed class OtpEvent extends Equatable {
  const OtpEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when OTP input changes
final class OtpChanged extends OtpEvent {
  const OtpChanged(this.otp);

  final String otp;

  @override
  List<Object> get props => [otp];

  @override
  String toString() => 'OtpChanged(otp: $otp)';
}

/// Event triggered when user submits OTP for verification
final class OtpSubmitted extends OtpEvent {
  const OtpSubmitted();

  @override
  String toString() => 'OtpSubmitted()';
}

/// Event triggered when user requests OTP resend
final class OtpResendRequested extends OtpEvent {
  const OtpResendRequested();

  @override
  String toString() => 'OtpResendRequested()';
}

/// Event triggered for resend timer countdown
final class _OtpResendTimerTicked extends OtpEvent {
  const _OtpResendTimerTicked();

  @override
  String toString() => '_OtpResendTimerTicked()';
} 