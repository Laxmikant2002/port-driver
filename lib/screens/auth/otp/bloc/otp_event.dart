part of 'otp_bloc.dart';

sealed class OtpEvent extends Equatable {
  const OtpEvent();

  @override
  List<Object?> get props => [];
}

final class ChangeOtp extends OtpEvent {
  const ChangeOtp(this.otp);

  final String otp;

  @override
  List<Object?> get props => [otp];
}

final class VerifyOtp extends OtpEvent {
  const VerifyOtp();
}

final class ResendOtp extends OtpEvent {
  const ResendOtp();
}

final class ResendTimerTick extends OtpEvent {
  const ResendTimerTick();
} 