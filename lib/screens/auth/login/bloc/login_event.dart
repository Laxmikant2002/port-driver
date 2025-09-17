part of 'login_bloc.dart';

/// Base class for all login events
abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when phone number changes
class PhoneChanged extends LoginEvent {
  const PhoneChanged(this.phone);

  final String phone;

  @override
  List<Object> get props => [phone];

  @override
  String toString() => 'PhoneChanged(phone: $phone)';
}

/// Event triggered when user submits the login form
class LoginSubmitted extends LoginEvent {
  const LoginSubmitted();

  @override
  String toString() => 'LoginSubmitted()';
}

/// Event triggered when user requests OTP resend
class ResendOtpRequested extends LoginEvent {
  const ResendOtpRequested();

  @override
  String toString() => 'ResendOtpRequested()';
}

/// Event triggered to reset form state
class LoginReset extends LoginEvent {
  const LoginReset();

  @override
  String toString() => 'LoginReset()';
}
