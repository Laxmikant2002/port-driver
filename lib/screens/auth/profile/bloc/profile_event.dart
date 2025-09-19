part of 'profile_bloc.dart';

/// Base class for all Profile events
sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered when first name is changed
final class ProfileFirstNameChanged extends ProfileEvent {
  const ProfileFirstNameChanged(this.firstName);

  final String firstName;

  @override
  List<Object> get props => [firstName];

  @override
  String toString() => 'ProfileFirstNameChanged(firstName: $firstName)';
}

/// Event triggered when last name is changed
final class ProfileLastNameChanged extends ProfileEvent {
  const ProfileLastNameChanged(this.lastName);

  final String lastName;

  @override
  List<Object> get props => [lastName];

  @override
  String toString() => 'ProfileLastNameChanged(lastName: $lastName)';
}

/// Event triggered when email is changed
final class ProfileEmailChanged extends ProfileEvent {
  const ProfileEmailChanged(this.email);

  final String email;

  @override
  List<Object> get props => [email];

  @override
  String toString() => 'ProfileEmailChanged(email: $email)';
}

/// Event triggered when alternative phone is changed
final class ProfileAlternativePhoneChanged extends ProfileEvent {
  const ProfileAlternativePhoneChanged(this.alternativePhone);

  final String alternativePhone;

  @override
  List<Object> get props => [alternativePhone];

  @override
  String toString() => 'ProfileAlternativePhoneChanged(alternativePhone: $alternativePhone)';
}

/// Event triggered when profile form is submitted
final class ProfileSubmitted extends ProfileEvent {
  const ProfileSubmitted();

  @override
  String toString() => 'ProfileSubmitted()';
}
