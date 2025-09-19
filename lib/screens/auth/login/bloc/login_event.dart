part of 'login_bloc.dart';

/// Base class for all login events
sealed class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when phone number changes
final class LoginPhoneChanged extends LoginEvent {
  const LoginPhoneChanged(this.phone);

  final String phone;

  @override
  List<Object> get props => [phone];

  @override
  String toString() => 'LoginPhoneChanged(phone: $phone)';
}

/// Event triggered when user submits the login form
final class LoginSubmitted extends LoginEvent {
  const LoginSubmitted();

  @override
  String toString() => 'LoginSubmitted()';
}

