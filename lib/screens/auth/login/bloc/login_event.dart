part of 'login_bloc.dart';

@immutable
sealed class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

final class ChangePhone extends LoginEvent {
  const ChangePhone(this.phone);

  final String phone;

  @override
  List<Object?> get props => [phone];
}

final class Submit extends LoginEvent {
  const Submit();
}
