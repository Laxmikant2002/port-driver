part of 'profile_bloc.dart';

/// Base class for all Profile events
sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered when profile is loaded
final class ProfileLoaded extends ProfileEvent {
  const ProfileLoaded();

  @override
  String toString() => 'ProfileLoaded()';
}

/// Event triggered when full name is changed
final class FullNameChanged extends ProfileEvent {
  const FullNameChanged(this.fullName);

  final String fullName;

  @override
  List<Object> get props => [fullName];

  @override
  String toString() => 'FullNameChanged(fullName: $fullName)';
}

/// Event triggered when profile picture is changed
final class ProfilePictureChanged extends ProfileEvent {
  const ProfilePictureChanged(this.imagePath);

  final String imagePath;

  @override
  List<Object> get props => [imagePath];

  @override
  String toString() => 'ProfilePictureChanged(imagePath: $imagePath)';
}

/// Event triggered when date of birth is changed
final class DateOfBirthChanged extends ProfileEvent {
  const DateOfBirthChanged(this.dateOfBirth);

  final DateTime dateOfBirth;

  @override
  List<Object> get props => [dateOfBirth];

  @override
  String toString() => 'DateOfBirthChanged(dateOfBirth: $dateOfBirth)';
}

/// Event triggered when gender is changed
final class GenderChanged extends ProfileEvent {
  const GenderChanged(this.gender);

  final String gender;

  @override
  List<Object> get props => [gender];

  @override
  String toString() => 'GenderChanged(gender: $gender)';
}

/// Event triggered when preferred location is changed
final class PreferredLocationChanged extends ProfileEvent {
  const PreferredLocationChanged(this.preferredLocation);

  final String preferredLocation;

  @override
  List<Object> get props => [preferredLocation];

  @override
  String toString() => 'PreferredLocationChanged(preferredLocation: $preferredLocation)';
}

/// Event triggered when service area is changed
final class ServiceAreaChanged extends ProfileEvent {
  const ServiceAreaChanged(this.serviceArea);

  final String serviceArea;

  @override
  List<Object> get props => [serviceArea];

  @override
  String toString() => 'ServiceAreaChanged(serviceArea: $serviceArea)';
}

/// Event triggered when languages spoken are changed
final class LanguagesChanged extends ProfileEvent {
  const LanguagesChanged(this.languagesSpoken);

  final List<String> languagesSpoken;

  @override
  List<Object> get props => [languagesSpoken];

  @override
  String toString() => 'LanguagesChanged(languagesSpoken: $languagesSpoken)';
}

/// Event triggered when vehicle is assigned
final class VehicleAssigned extends ProfileEvent {
  const VehicleAssigned({
    required this.vehicleId,
    required this.vehicleType,
    required this.plateNumber,
    this.assignedByAdmin = false,
  });

  final String vehicleId;
  final String vehicleType;
  final String plateNumber;
  final bool assignedByAdmin;

  @override
  List<Object> get props => [vehicleId, vehicleType, plateNumber, assignedByAdmin];

  @override
  String toString() => 'VehicleAssigned(vehicleId: $vehicleId, vehicleType: $vehicleType, plateNumber: $plateNumber)';
}

/// Event triggered when driver status is changed
final class DriverStatusChanged extends ProfileEvent {
  const DriverStatusChanged(this.driverStatus);

  final DriverStatus driverStatus;

  @override
  List<Object> get props => [driverStatus];

  @override
  String toString() => 'DriverStatusChanged(driverStatus: $driverStatus)';
}

/// Event triggered when profile form is submitted
final class UpdateProfile extends ProfileEvent {
  const UpdateProfile();

  @override
  String toString() => 'UpdateProfile()';
}
