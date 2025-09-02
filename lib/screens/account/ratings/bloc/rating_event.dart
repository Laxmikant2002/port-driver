part of 'rating_bloc.dart';

abstract class RatingsEvent extends Equatable {
  const RatingsEvent();
  @override
  List<Object?> get props => [];
}

class LoadRatings extends RatingsEvent {
  final double rating;
  final int peopleRated;

  const LoadRatings(this.rating, this.peopleRated);

  @override
  List<Object?> get props => [rating, peopleRated];
}
