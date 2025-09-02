import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:driver/screens/account/ratings/bloc/rating_review_model.dart';
import 'package:driver/screens/account/ratings/bloc/rating_state.dart';

part 'rating_event.dart';


class RatingBloc extends Bloc<RatingsEvent, RatingState> {
  RatingBloc() : super(RatingInitial()) {
    on<LoadRatings>(_onLoadRating);
  }

  Future<void> _onLoadRating(
      LoadRatings event, Emitter<RatingState> emit) async {
    try {
      emit(RatingLoading());
      await Future.delayed(const Duration(milliseconds: 500));

      final reviews = [
        RatingReview(
          name: 'John Doe',
          profileUrl: 'https://via.placeholder.com/48',
          rating: 4.0,
          comment: 'Very good ride, professional driver.',
          date: DateTime(2025, 4, 25),
        ),
        RatingReview(
          name: 'Jane Smith',
          profileUrl: 'https://via.placeholder.com/48',
          rating: 5.0,
          comment: 'Comfortable, excellent experience!',
          date: DateTime(2025, 4, 20),
        ),
      ];

      emit(RatingLoaded(
        rating: event.rating,
        peopleRated: event.peopleRated,
        reviews: reviews,
      ));
    } catch (e) {
      emit(RatingError(e.toString()));
    }
  }
}