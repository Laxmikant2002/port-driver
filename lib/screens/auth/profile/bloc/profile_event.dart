part of 'profile_bloc.dart';

/// Base class for all profile events
sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when profile screen is initialized
final class ProfileInitialized extends ProfileEvent {
  const ProfileInitialized();

  @override
  String toString() => 'ProfileInitialized()';
}

/// Event triggered when name input changes
final class ProfileNameChanged extends ProfileEvent {
  const ProfileNameChanged(this.name);

  final String name;

  @override
  List<Object> get props => [name];

  @override
  String toString() => 'ProfileNameChanged(name: $name)';
}

/// Event triggered when date of birth changes
final class ProfileDateOfBirthChanged extends ProfileEvent {
  const ProfileDateOfBirthChanged(this.dateOfBirth);

  final DateTime dateOfBirth;

  @override
  List<Object> get props => [dateOfBirth];

  @override
  String toString() => 'ProfileDateOfBirthChanged(dateOfBirth: $dateOfBirth)';
}

/// Event triggered when gender selection changes
final class ProfileGenderChanged extends ProfileEvent {
  const ProfileGenderChanged(this.gender);

  final String gender;

  @override
  List<Object> get props => [gender];

  @override
  String toString() => 'ProfileGenderChanged(gender: $gender)';
}

/// Event triggered when profile photo changes
final class ProfilePhotoChanged extends ProfileEvent {
  const ProfilePhotoChanged(this.photoPath);

  final String? photoPath;

  @override
  List<Object?> get props => [photoPath];

  @override
  String toString() => 'ProfilePhotoChanged(photoPath: $photoPath)';
}

/// Event triggered when profile form is submitted
final class ProfileSubmitted extends ProfileEvent {
  const ProfileSubmitted();

  @override
  String toString() => 'ProfileSubmitted()';
}