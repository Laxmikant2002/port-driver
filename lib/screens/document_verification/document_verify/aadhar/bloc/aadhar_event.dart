part of 'aadhar_bloc.dart';

/// Base class for all Aadhar events
sealed class AadharEvent extends Equatable {
  const AadharEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered when Aadhar front image is changed
final class AadharFrontImageChanged extends AadharEvent {
  const AadharFrontImageChanged(this.frontImage);
  final String frontImage;

  @override
  List<Object> get props => [frontImage];

  @override
  String toString() => 'AadharFrontImageChanged(frontImage: $frontImage)';
}

/// Event triggered when Aadhar back image is changed
final class AadharBackImageChanged extends AadharEvent {
  const AadharBackImageChanged(this.backImage);
  final String backImage;

  @override
  List<Object> get props => [backImage];

  @override
  String toString() => 'AadharBackImageChanged(backImage: $backImage)';
}

/// Event triggered when Aadhar form is submitted
final class AadharSubmitted extends AadharEvent {
  const AadharSubmitted();

  @override
  String toString() => 'AadharSubmitted()';
}
