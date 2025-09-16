part of 'login_bloc.dart';

class PhoneInput extends FormzInput<String, String> {
  const PhoneInput.pure() : super.pure('');
  const PhoneInput.dirty([String value = '']) : super.dirty(value);

  @override
  String? validator(String value) {
    // Remove any spaces for validation
    final cleanValue = value.replaceAll(' ', '');
    
    if (cleanValue.isEmpty) return 'empty';
    
    // Enhanced Indian phone number validation
    // Should start with 6-9 and be exactly 10 digits
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(cleanValue)) {
      if (cleanValue.length < 10) {
        return 'incomplete';
      } else if (cleanValue.length > 10) {
        return 'too_long';
      } else if (!RegExp(r'^[6-9]').hasMatch(cleanValue)) {
        return 'invalid_start';
      } else {
        return 'invalid';
      }
    }
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
  bool get isComplete => value.replaceAll(' ', '').length == 10;
}

class LoginState extends Equatable {
  final PhoneInput phoneInput;
  final FormzSubmissionStatus status;
  final String? error;

  const LoginState({
    this.phoneInput = const PhoneInput.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.error,
  });

  LoginState copyWith({
    PhoneInput? phoneInput,
    FormzSubmissionStatus? status,
    String? error,
  }) {
    return LoginState(
      phoneInput: phoneInput ?? this.phoneInput,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [phoneInput, status, error];
}
