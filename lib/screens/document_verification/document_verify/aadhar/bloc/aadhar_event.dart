part of 'aadhar_bloc.dart';

abstract class AadharEvent extends Equatable {
  const AadharEvent();

  @override
  List<Object> get props => [];
}

class AadharNumberChanged extends AadharEvent {
  const AadharNumberChanged(this.aadharNumber);
  final String aadharNumber;
  @override
  List<Object> get props => [aadharNumber];
}

class AadharImageChanged extends AadharEvent {
  const AadharImageChanged(this.aadharImage);
  final String aadharImage;
  @override
  List<Object> get props => [aadharImage];
}

class AadharSubmitted extends AadharEvent {
  const AadharSubmitted();
}
