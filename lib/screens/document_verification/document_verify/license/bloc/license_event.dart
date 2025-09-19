part of 'license_bloc.dart';

/// Base class for all License events
sealed class LicenseEvent extends Equatable {
  const LicenseEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered when license front image is changed
final class LicenseFrontImageChanged extends LicenseEvent {
  const LicenseFrontImageChanged(this.frontImage);
  final String frontImage;

  @override
  List<Object> get props => [frontImage];

  @override
  String toString() => 'LicenseFrontImageChanged(frontImage: $frontImage)';
}

/// Event triggered when license back image is changed
final class LicenseBackImageChanged extends LicenseEvent {
  const LicenseBackImageChanged(this.backImage);
  final String backImage;

  @override
  List<Object> get props => [backImage];

  @override
  String toString() => 'LicenseBackImageChanged(backImage: $backImage)';
}

/// Event triggered when license form is submitted
final class LicenseSubmitted extends LicenseEvent {
  const LicenseSubmitted();

  @override
  String toString() => 'LicenseSubmitted()';
}
