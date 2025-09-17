part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class ProfileFirstNameChanged extends ProfileEvent {
  const ProfileFirstNameChanged(this.firstName);

  final String firstName;

  @override
  List<Object> get props => [firstName];
}

class ProfileLastNameChanged extends ProfileEvent {
  const ProfileLastNameChanged(this.lastName);

  final String lastName;

  @override
  List<Object> get props => [lastName];
}

class ProfileEmailChanged extends ProfileEvent {
  const ProfileEmailChanged(this.email);

  final String email;

  @override
  List<Object> get props => [email];
}

class ProfileAlternativePhoneChanged extends ProfileEvent {
  const ProfileAlternativePhoneChanged(this.alternativePhone);

  final String alternativePhone;

  @override
  List<Object> get props => [alternativePhone];
}

class ProfileSubmitted extends ProfileEvent {
  const ProfileSubmitted();
}
