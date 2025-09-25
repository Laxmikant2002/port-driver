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

/// OTP state containing form data and submission status
final class OtpState extends Equatable {
  const OtpState({
    this.otpInput = const OtpInput.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.user,
    this.errorMessage,
    this.canResend = true,
    this.resendTimer = 30,
    this.routeDecision,
  });

  final OtpInput otpInput;
  final FormzSubmissionStatus status;
  final AuthUser? user;
  final String? errorMessage;
  final bool canResend;
  final int resendTimer;
  final RouteDecision? routeDecision;

  /// Returns true if the form is valid and ready for submission
  bool get isValid => Formz.validate([otpInput]);

  /// Returns true if the form is currently being submitted
  bool get isSubmitting => status == FormzSubmissionStatus.inProgress;

  /// Returns true if the submission was successful
  bool get isSuccess => status == FormzSubmissionStatus.success;

  /// Returns true if the submission failed
  bool get isFailure => status == FormzSubmissionStatus.failure;

  /// Returns true if there's an error
  bool get hasError => isFailure && errorMessage != null;

  OtpState copyWith({
    OtpInput? otpInput,
    FormzSubmissionStatus? status,
    AuthUser? user,
    String? errorMessage,
    bool? canResend,
    int? resendTimer,
    RouteDecision? routeDecision,
  }) =>
      OtpState(
        otpInput: otpInput ?? this.otpInput,
        status: status ?? this.status,
        user: user ?? this.user,
        errorMessage: errorMessage,
        canResend: canResend ?? this.canResend,
        resendTimer: resendTimer ?? this.resendTimer,
        routeDecision: routeDecision ?? this.routeDecision,
      );

  @override
  List<Object?> get props => [
        otpInput,
        status,
        user,
        errorMessage,
        canResend,
        resendTimer,
        routeDecision,
      ];

  @override
  String toString() {
    return 'OtpState('
        'otpInput: $otpInput, '
        'status: $status, '
        'user: $user, '
        'errorMessage: $errorMessage, '
        'canResend: $canResend, '
        'resendTimer: $resendTimer, '
        'routeDecision: $routeDecision'
        ')';
  }
}