part of 'otp_bloc.dart';

final class OtpState extends Equatable {
  const OtpState({
    this.otpInput = const OtpInputField.pure(), // Updated reference
    this.status = FormzSubmissionStatus.initial,
    this.error,
    this.canResend = true,
    this.resendTimer = 0,
  });

  final OtpInputField otpInput; // Updated reference
  final FormzSubmissionStatus status;
  final String? error;
  final bool canResend;
  final int resendTimer;

  bool get isValid => Formz.validate([otpInput]);

  OtpState copyWith({
    OtpInputField? otpInput, // Updated reference
    FormzSubmissionStatus? status,
    String? error,
    bool? canResend,
    int? resendTimer,
  }) =>
      OtpState(
        otpInput: otpInput ?? this.otpInput, // Updated reference
        status: status ?? this.status,
        error: error,
        canResend: canResend ?? this.canResend,
        resendTimer: resendTimer ?? this.resendTimer,
      );

  @override
  List<Object?> get props => [
        otpInput,
        status,
        error,
        canResend,
        resendTimer,
      ];
}