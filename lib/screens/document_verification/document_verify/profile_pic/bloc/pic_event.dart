part of 'pic_bloc.dart';

abstract class PicEvent extends Equatable {
  const PicEvent();

  @override
  List<Object> get props => [];
}

class PicImageChanged extends PicEvent {
  const PicImageChanged(this.imagePath);
  final String imagePath;
  @override
  List<Object> get props => [imagePath];
}

class PicSubmitted extends PicEvent {
  const PicSubmitted();
}
