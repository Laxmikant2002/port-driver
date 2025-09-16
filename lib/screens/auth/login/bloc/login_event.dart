part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class ChangePhone extends LoginEvent {
  final String phone;
  const ChangePhone(this.phone);

  @override
  List<Object> get props => [phone];
}

class SubmitLogin extends LoginEvent {}
