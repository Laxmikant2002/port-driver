part of 'login_bloc.dart';

@immutable
final class LoginState extends Equatable {
  const LoginState({
    this.phoneInput = const PhoneInput.pure(),
    this.error,
    this.status = FormzSubmissionStatus.initial,
  });

  final PhoneInput phoneInput;
  final FormzSubmissionStatus status;
  final String? error;

  // Added dynamic validity check
  bool get isValid => Formz.validate([phoneInput]);

  LoginState copyWith({
    PhoneInput? phoneInput,
    FormzSubmissionStatus? status,
    String? error,
  }) =>
      LoginState(
        phoneInput: phoneInput ?? this.phoneInput,
        status: status ?? this.status,
        error: error ?? this.error,
      );

  @override
  List<Object?> get props => [
        phoneInput,
        status,
        error,
      ];
}
