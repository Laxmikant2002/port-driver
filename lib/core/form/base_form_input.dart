import 'package:formz/formz.dart';

/// Base form input for common validation patterns
abstract class BaseFormInput<T, E> extends FormzInput<T, E> {
  const BaseFormInput.pure(T value) : super.pure(value);
  const BaseFormInput.dirty(T value) : super.dirty(value);
  
  /// Returns a user-friendly error message
  String? get displayErrorMessage;
  
  /// Returns true if the input is valid
  @override
  bool get isValid => error == null;
  
  /// Returns true if the input has been modified
  bool get isDirty => isPure == false;
  
  /// Returns true if the input is empty (for string inputs)
  bool get isEmpty {
    if (value is String) {
      return (value as String).isEmpty;
    }
    return value == null;
  }
}

/// Base phone input with common validation
abstract class BasePhoneInput extends BaseFormInput<String, String> {
  const BasePhoneInput.pure() : super.pure('');
  const BasePhoneInput.dirty([String value = '']) : super.dirty(value);
  
  /// Returns clean phone number (digits only)
  String get cleanValue => value.replaceAll(RegExp(r'[^\d]'), '');
  
  /// Returns true if phone number is complete
  bool get isComplete => cleanValue.length >= 10;
  
  @override
  String? validator(String value) {
    final clean = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (clean.isEmpty) return 'empty';
    if (clean.length < 10) return 'incomplete';
    if (clean.length > 10) return 'too_long';
    if (!RegExp(r'^[6-9]').hasMatch(clean)) return 'invalid_start';
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(clean)) return 'invalid';
    
    return null;
  }
  
  @override
  String? get displayErrorMessage {
    if (error == null) return null;
    
    switch (error) {
      case 'empty':
        return 'Phone number is required';
      case 'incomplete':
        return 'Please enter a complete 10-digit number';
      case 'too_long':
        return 'Phone number should be 10 digits only';
      case 'invalid_start':
        return 'Phone number should start with 6, 7, 8, or 9';
      case 'invalid':
        return 'Please enter a valid phone number';
      default:
        return 'Invalid phone number';
    }
  }
}

/// Base text input with common validation
abstract class BaseTextInput extends BaseFormInput<String, String> {
  const BaseTextInput.pure() : super.pure('');
  const BaseTextInput.dirty([String value = '']) : super.dirty(value);
  
  /// Minimum length for validation
  int get minLength;
  
  /// Maximum length for validation
  int get maxLength;
  
  /// Field name for error messages
  String get fieldName;
  
  @override
  String? validator(String value) {
    if (value.isEmpty) return 'empty';
    if (value.length < minLength) return 'too_short';
    if (value.length > maxLength) return 'too_long';
    
    return customValidator(value);
  }
  
  /// Override for custom validation logic
  String? customValidator(String value) => null;
  
  @override
  String? get displayErrorMessage {
    if (error == null) return null;
    
    switch (error) {
      case 'empty':
        return '$fieldName is required';
      case 'too_short':
        return '$fieldName must be at least $minLength characters';
      case 'too_long':
        return '$fieldName must be less than $maxLength characters';
      default:
        return error;
    }
  }
}

/// Base email input with validation
abstract class BaseEmailInput extends BaseFormInput<String, String> {
  const BaseEmailInput.pure() : super.pure('');
  const BaseEmailInput.dirty([String value = '']) : super.dirty(value);
  
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );
  
  @override
  String? validator(String value) {
    if (value.isEmpty) return null; // Email is usually optional
    if (!_emailRegExp.hasMatch(value)) return 'invalid';
    
    return null;
  }
  
  @override
  String? get displayErrorMessage {
    if (error == null) return null;
    
    switch (error) {
      case 'invalid':
        return 'Please enter a valid email address';
      default:
        return 'Invalid email address';
    }
  }
}

/// Base OTP input with validation
abstract class BaseOtpInput extends BaseFormInput<String, String> {
  const BaseOtpInput.pure() : super.pure('');
  const BaseOtpInput.dirty([String value = '']) : super.dirty(value);
  
  /// Expected OTP length
  int get otpLength => 4;
  
  @override
  String? validator(String value) {
    if (value.isEmpty) return 'empty';
    if (value.length != otpLength) return 'invalid_length';
    if (!RegExp(r'^\d+$').hasMatch(value)) return 'invalid_format';
    
    return null;
  }
  
  @override
  String? get displayErrorMessage {
    if (error == null) return null;
    
    switch (error) {
      case 'empty':
        return 'Please enter OTP';
      case 'invalid_length':
        return 'OTP must be $otpLength digits';
      case 'invalid_format':
        return 'OTP should contain only numbers';
      default:
        return 'Invalid OTP';
    }
  }
}