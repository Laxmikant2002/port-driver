part of 'rc_bloc.dart';

abstract class RcEvent extends Equatable {
  const RcEvent();

  @override
  List<Object> get props => [];
}

class RcNumberChanged extends RcEvent {
  const RcNumberChanged(this.rcNumber);
  final String rcNumber;
  @override
  List<Object> get props => [rcNumber];
}

class RcImageChanged extends RcEvent {
  const RcImageChanged(this.rcImage);
  final String rcImage;
  @override
  List<Object> get props => [rcImage];
}

class VehicleNumberChanged extends RcEvent {
  const VehicleNumberChanged(this.vehicleNumber);
  final String vehicleNumber;
  @override
  List<Object> get props => [vehicleNumber];
}

class RcSubmitted extends RcEvent {
  const RcSubmitted();
}
