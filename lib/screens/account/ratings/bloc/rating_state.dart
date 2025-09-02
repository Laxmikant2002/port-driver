import 'package:equatable/equatable.dart';
import 'package:driver/screens/account/ratings/bloc/rating_review_model.dart';


abstract class RatingState extends Equatable {
  const RatingState();

  @override
  List<Object?> get props => [];
}

class RatingInitial extends RatingState {}

class RatingLoading extends RatingState {}

class RatingLoaded extends RatingState {
  final double rating;
  final int peopleRated;
  final List<RatingReview> reviews;

  const RatingLoaded({
    required this.rating,
    required this.peopleRated,
    required this.reviews,
  });

  @override
  List<Object?> get props => [rating, peopleRated, reviews];
}

class RatingError extends RatingState {
  final String message;
  const RatingError(this.message);

  @override
  List<Object?> get props => [message];
}