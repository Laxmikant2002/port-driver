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
final class LoginState extends Equatable {
  const LoginState({
    this.phoneInput = const PhoneInput.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.phoneExists = false,
    this.errorMessage,
  });

  final PhoneInput phoneInput;
  final FormzSubmissionStatus status;
  final bool phoneExists;
  final String? errorMessage;

  /// Returns true if the form is valid and ready for submission
  bool get isValid => Formz.validate([phoneInput]);

  /// Returns true if the form is currently being submitted
  bool get isSubmitting => status == FormzSubmissionStatus.inProgress;

  /// Returns true if the submission was successful
  bool get isSuccess => status == FormzSubmissionStatus.success;

  /// Returns true if the submission failed
  bool get isFailure => status == FormzSubmissionStatus.failure;

  /// Returns true if there's an error
  bool get hasError => isFailure && errorMessage != null;

  LoginState copyWith({
    PhoneInput? phoneInput,
    FormzSubmissionStatus? status,
    bool? phoneExists,
    String? errorMessage,
  }) {
    return LoginState(
      phoneInput: phoneInput ?? this.phoneInput,
      status: status ?? this.status,
      phoneExists: phoneExists ?? this.phoneExists,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        phoneInput,
        status,
        phoneExists,
        errorMessage,
      ];

  @override
  String toString() {
    return 'LoginState('
        'phoneInput: $phoneInput, '
        'status: $status, '
        'phoneExists: $phoneExists, '
        'errorMessage: $errorMessage'
        ')';
  }
}
