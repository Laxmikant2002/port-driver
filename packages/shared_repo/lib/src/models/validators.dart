import 'package:formz/formz.dart';

/// Validation error enums
enum NameValidationError { empty, tooShort }

enum PhoneValidationError { empty, invalid }

enum EmailValidationError { invalid }

enum PasswordValidationError { empty, tooShort, weak }

enum OtpValidationError { empty, invalid }

/// Name validation
class Name extends FormzInput<String, NameValidationError> {
  const Name.pure() : super.pure('');
  const Name.dirty([super.value = '']) : super.dirty();

  @override
  NameValidationError? validator(String value) {
    if (value.isEmpty) return NameValidationError.empty;
    if (value.length < 2) return NameValidationError.tooShort;
    return null;
  }
}

/// Phone validation
class Phone extends FormzInput<String, PhoneValidationError> {
  const Phone.pure() : super.pure('');
  const Phone.dirty([super.value = '']) : super.dirty();

  @override
  PhoneValidationError? validator(String value) {
    if (value.isEmpty) return PhoneValidationError.empty;
    if (value.length < 10) return PhoneValidationError.invalid;
    return null;
  }
}

/// Email validation
class Email extends FormzInput<String, EmailValidationError> {
  const Email.pure() : super.pure('');
  const Email.dirty([super.value = '']) : super.dirty();

  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );

  @override
  EmailValidationError? validator(String value) {
    if (value.isNotEmpty && !_emailRegExp.hasMatch(value)) {
      return EmailValidationError.invalid;
    }
    return null;
  }
}

/// Password validation
class Password extends FormzInput<String, PasswordValidationError> {
  const Password.pure() : super.pure('');
  const Password.dirty([super.value = '']) : super.dirty();

  @override
  PasswordValidationError? validator(String value) {
    if (value.isEmpty) return PasswordValidationError.empty;
    if (value.length < 6) return PasswordValidationError.tooShort;
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return PasswordValidationError.weak;
    }
    return null;
  }
}

/// OTP validation
class Otp extends FormzInput<String, OtpValidationError> {
  const Otp.pure() : super.pure('');
  const Otp.dirty([super.value = '']) : super.dirty();

  @override
  OtpValidationError? validator(String value) {
    if (value.isEmpty) return OtpValidationError.empty;
    if (value.length != 6) return OtpValidationError.invalid;
    return null;
  }
}
