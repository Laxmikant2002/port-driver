part of 'rc_bloc.dart';

/// Base class for all RC events
sealed class RcEvent extends Equatable {
  const RcEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered when RC number is changed
final class RcNumberChanged extends RcEvent {
  const RcNumberChanged(this.rcNumber);
  final String rcNumber;

  @override
  List<Object> get props => [rcNumber];

  @override
  String toString() => 'RcNumberChanged(rcNumber: $rcNumber)';
}

/// Event triggered when RC image is changed
final class RcImageChanged extends RcEvent {
  const RcImageChanged(this.rcImage);
  final String rcImage;

  @override
  List<Object> get props => [rcImage];

  @override
  String toString() => 'RcImageChanged(rcImage: $rcImage)';
}

/// Event triggered when vehicle number is changed
final class VehicleNumberChanged extends RcEvent {
  const VehicleNumberChanged(this.vehicleNumber);
  final String vehicleNumber;

  @override
  List<Object> get props => [vehicleNumber];

  @override
  String toString() => 'VehicleNumberChanged(vehicleNumber: $vehicleNumber)';
}

/// Event triggered when RC form is submitted
final class RcSubmitted extends RcEvent {
  const RcSubmitted();

  @override
  String toString() => 'RcSubmitted()';
}
