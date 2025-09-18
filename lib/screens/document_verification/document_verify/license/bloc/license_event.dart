part of 'license_bloc.dart';

abstract class LicenseEvent extends Equatable {
  const LicenseEvent();

  @override
  List<Object> get props => [];
}

class LicenseNumberChanged extends LicenseEvent {
  const LicenseNumberChanged(this.licenseNumber);
  final String licenseNumber;
  @override
  List<Object> get props => [licenseNumber];
}

class LicenseImageChanged extends LicenseEvent {
  const LicenseImageChanged(this.licenseImage);
  final String licenseImage;
  @override
  List<Object> get props => [licenseImage];
}

class LicenseDobChanged extends LicenseEvent {
  const LicenseDobChanged(this.dob);
  final String dob;
  @override
  List<Object> get props => [dob];
}

class LicenseSubmitted extends LicenseEvent {
  const LicenseSubmitted();
}
