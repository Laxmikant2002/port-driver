part of 'profile_bloc.dart';

enum FirstNameValidationError { empty }

class FirstName extends FormzInput<String, FirstNameValidationError> {
  const FirstName.pure() : super.pure('');
  const FirstName.dirty([super.value = '']) : super.dirty();

  @override
  FirstNameValidationError? validator(String value) {
    if (value.isEmpty) return FirstNameValidationError.empty;
    return null;
  }
}

enum LastNameValidationError { empty }

class LastName extends FormzInput<String, LastNameValidationError> {
  const LastName.pure() : super.pure('');
  const LastName.dirty([super.value = '']) : super.dirty();

  @override
  LastNameValidationError? validator(String value) {
    if (value.isEmpty) return LastNameValidationError.empty;
    return null;
  }
}

enum EmailValidationError { invalid }

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

enum AlternativePhoneValidationError { invalid }

class AlternativePhone extends FormzInput<String, AlternativePhoneValidationError> {
  const AlternativePhone.pure() : super.pure('');
  const AlternativePhone.dirty([super.value = '']) : super.dirty();

  @override
  AlternativePhoneValidationError? validator(String value) {
    if (value.isNotEmpty && value.length < 10) {
      return AlternativePhoneValidationError.invalid;
    }
    return null;
  }
}

/// Profile state containing form data and submission status
final class ProfileState extends Equatable {
  const ProfileState({
    this.status = FormzSubmissionStatus.initial,
    this.firstName = const FirstName.pure(),
    this.lastName = const LastName.pure(),
    this.email = const Email.pure(),
    this.alternativePhone = const AlternativePhone.pure(),
    this.phone = '',
    this.errorMessage,
  });

  final FormzSubmissionStatus status;
  final FirstName firstName;
  final LastName lastName;
  final Email email;
  final AlternativePhone alternativePhone;
  final String phone;
  final String? errorMessage;

  /// Returns true if the form is valid and ready for submission
  bool get isValid => Formz.validate([firstName, lastName, email, alternativePhone]);

  /// Returns true if the form is currently being submitted
  bool get isSubmitting => status == FormzSubmissionStatus.inProgress;

  /// Returns true if the submission was successful
  bool get isSuccess => status == FormzSubmissionStatus.success;

  /// Returns true if the submission failed
  bool get isFailure => status == FormzSubmissionStatus.failure;

  /// Returns true if there's an error
  bool get hasError => isFailure && errorMessage != null;

  ProfileState copyWith({
    FormzSubmissionStatus? status,
    FirstName? firstName,
    LastName? lastName,
    Email? email,
    AlternativePhone? alternativePhone,
    String? phone,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      alternativePhone: alternativePhone ?? this.alternativePhone,
      phone: phone ?? this.phone,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        firstName,
        lastName,
        email,
        alternativePhone,
        phone,
        errorMessage,
      ];

  @override
  String toString() {
    return 'ProfileState('
        'status: $status, '
        'firstName: $firstName, '
        'lastName: $lastName, '
        'email: $email, '
        'alternativePhone: $alternativePhone, '
        'phone: $phone, '
        'errorMessage: $errorMessage'
        ')';
  }
}
