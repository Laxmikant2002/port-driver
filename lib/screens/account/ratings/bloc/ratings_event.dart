part of 'ratings_bloc.dart';

/// Base class for all Ratings events
sealed class RatingsEvent extends Equatable {
  const RatingsEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered when ratings are loaded
final class RatingsLoaded extends RatingsEvent {
  const RatingsLoaded();

  @override
  String toString() => 'RatingsLoaded()';
}

/// Event triggered when a rating is selected for viewing
final class RatingSelected extends RatingsEvent {
  const RatingSelected(this.rating);

  final Rating rating;

  @override
  List<Object> get props => [rating];

  @override
  String toString() => 'RatingSelected(rating: $rating)';
}

/// Event triggered when a rating is submitted
final class RatingSubmitted extends RatingsEvent {
  const RatingSubmitted({
    required this.rideId,
    required this.rating,
    this.comment,
    this.category = RatingCategory.overall,
  });

  final String rideId;
  final int rating;
  final String? comment;
  final RatingCategory category;

  @override
  List<Object> get props => [rideId, rating, comment ?? '', category];

  @override
  String toString() => 'RatingSubmitted(rideId: $rideId, rating: $rating)';
}

/// Event triggered when a rating is deleted
final class RatingDeleted extends RatingsEvent {
  const RatingDeleted(this.ratingId);

  final String ratingId;

  @override
  List<Object> get props => [ratingId];

  @override
  String toString() => 'RatingDeleted(ratingId: $ratingId)';
}

/// Event triggered when ratings are filtered
final class RatingsFiltered extends RatingsEvent {
  const RatingsFiltered({
    this.minRating,
    this.maxRating,
    this.category,
    this.hasComment,
  });

  final int? minRating;
  final int? maxRating;
  final RatingCategory? category;
  final bool? hasComment;

  @override
  List<Object> get props => [
        minRating ?? 0,
        maxRating ?? 0,
        category ?? RatingCategory.overall,
        hasComment ?? false,
      ];

  @override
  String toString() => 'RatingsFiltered(minRating: $minRating, maxRating: $maxRating, category: $category)';
}

/// Event triggered when ratings are refreshed
final class RatingsRefreshed extends RatingsEvent {
  const RatingsRefreshed();

  @override
  String toString() => 'RatingsRefreshed()';
}
