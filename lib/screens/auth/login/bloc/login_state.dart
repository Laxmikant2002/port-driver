part of 'login_bloc.dart';

/// Form input for phone number validation using Formz
class PhoneInput extends FormzInput<String, String> {
  const PhoneInput.pure() : super.pure('');
  const PhoneInput.dirty([String value = '']) : super.dirty(value);

  @override
  String? validator(String value) {
    // Remove any spaces and non-digit characters for validation
    final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanValue.isEmpty) return 'empty';
    if (cleanValue.length < 10) return 'incomplete';
    if (cleanValue.length > 10) return 'too_long';
    if (!RegExp(r'^[6-9]').hasMatch(cleanValue)) return 'invalid_start';
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(cleanValue)) return 'invalid';
    
    return null;
  }

  /// Returns a user-friendly error message
  @override
  String? get displayError {
    if (error == null) return null;
    
    switch (error) {
      case 'empty':
        return 'Mobile number is required';
      case 'incomplete':
        return 'Please enter a complete 10-digit number';
      case 'too_long':
        return 'Mobile number should be 10 digits only';
      case 'invalid_start':
        return 'Mobile number should start with 6, 7, 8, or 9';
      case 'invalid':
        return 'Please enter a valid mobile number';
      default:
        return 'Invalid mobile number';
    }
  }

  /// Returns true if the phone number is valid
  @override
  bool get isValid => error == null && value.isNotEmpty;
  
  /// Returns true if the phone number is complete (10 digits)
  bool get isComplete => value.replaceAll(RegExp(r'[^\d]'), '').length == 10;
  
  /// Returns the clean phone number (digits only)
  String get cleanValue => value.replaceAll(RegExp(r'[^\d]'), '');
}

/// Login state containing form data and submission status using Equatable
class LoginState extends Equatable {
  const LoginState({
    this.phoneInput = const PhoneInput.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.errorMessage,
    this.otpSent = false,
    this.resendCooldown = 0,
  });

  final PhoneInput phoneInput;
  final FormzSubmissionStatus status;
  final String? errorMessage;
  final bool otpSent;
  final int resendCooldown;

  /// Returns true if the form is valid and ready for submission
  bool get isValid => phoneInput.isValid;

  /// Returns true if the form is currently being submitted
  bool get isSubmitting => status == FormzSubmissionStatus.inProgress;

  /// Returns true if OTP was successfully sent
  bool get isOtpSent => otpSent;

  /// Returns true if resend is available
  bool get canResend => resendCooldown == 0;

  /// Returns the current error message if any
  String? get error => errorMessage;

  /// Returns true if there's an error
  bool get hasError => errorMessage != null;

  LoginState copyWith({
    PhoneInput? phoneInput,
    FormzSubmissionStatus? status,
    String? errorMessage,
    bool? otpSent,
    int? resendCooldown,
    bool clearError = false,
  }) {
    return LoginState(
      phoneInput: phoneInput ?? this.phoneInput,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      otpSent: otpSent ?? this.otpSent,
      resendCooldown: resendCooldown ?? this.resendCooldown,
    );
  }

  @override
  List<Object?> get props => [
        phoneInput,
        status,
        errorMessage,
        otpSent,
        resendCooldown,
      ];

  @override
  String toString() {
    return 'LoginState('
        'phoneInput: $phoneInput, '
        'status: $status, '
        'errorMessage: $errorMessage, '
        'otpSent: $otpSent, '
        'resendCooldown: $resendCooldown'
        ')';
  }
}
