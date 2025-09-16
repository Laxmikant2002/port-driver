part of 'otp_bloc.dart';

class OtpInput extends FormzInput<String, String> {
  const OtpInput.pure() : super.pure('');
  const OtpInput.dirty([super.value = '']) : super.dirty();

  @override
  String? validator(String value) {
    if (value.isEmpty) return 'empty';
    if (value.length != 4) return 'invalidLength';
    return null;
  }

  /// Returns a user-friendly error message
  String? get errorMessage {
    if (error == null) return null;
    switch (error!) {
      case 'empty':
        return 'Please enter OTP';
      case 'invalidLength':
        return 'OTP must be 4 digits';
      default:
        return error;
    }
  }
}

final class OtpState extends Equatable {
  const OtpState({
    this.otpInput = const OtpInput.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.error,
    this.canResend = true,
    this.resendTimer = 24,
  });

  final OtpInput otpInput;
  final FormzSubmissionStatus status;
  final String? error;
  final bool canResend;
  final int resendTimer;

  bool get isValid => Formz.validate([otpInput]);

  OtpState copyWith({
    OtpInput? otpInput,
    FormzSubmissionStatus? status,
    String? error,
    bool? canResend,
    int? resendTimer,
  }) =>
      OtpState(
        otpInput: otpInput ?? this.otpInput,
        status: status ?? this.status,
        error: error ?? this.error,
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