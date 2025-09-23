import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:shared_repo/shared_repo.dart';

part 'ratings_event.dart';
part 'ratings_state.dart';

class RatingsBloc extends Bloc<RatingsEvent, RatingsState> {
  RatingsBloc({required this.sharedRepo}) : super(const RatingsState()) {
    on<RatingsLoaded>(_onRatingsLoaded);
    on<RatingSelected>(_onRatingSelected);
    on<RatingSubmitted>(_onRatingSubmitted);
    on<RatingDeleted>(_onRatingDeleted);
    on<RatingsFiltered>(_onRatingsFiltered);
    on<RatingsRefreshed>(_onRatingsRefreshed);
    on<RatingValueChanged>(_onRatingValueChanged);
    on<CommentChanged>(_onCommentChanged);
  }

  final SharedRepo sharedRepo;

  Future<void> _onRatingsLoaded(
    RatingsLoaded event,
    Emitter<RatingsState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      // TODO: Implement ratings through shared_repo or create ratings API
      // For now, simulate with empty ratings
      final mockRatings = <Rating>[];
      
      // Calculate average rating and statistics
      final averageRating = mockRatings.isNotEmpty 
          ? mockRatings.map((r) => r.rating).reduce((a, b) => a + b) / mockRatings.length 
          : 0.0;
      
      final ratingDistribution = _calculateRatingDistribution(mockRatings);
      
      emit(state.copyWith(
        allRatings: mockRatings,
        averageRating: averageRating,
        ratingDistribution: ratingDistribution,
        totalRatings: mockRatings.length,
        status: FormzSubmissionStatus.success,
        clearError: true,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Network error: ${error.toString()}',
      ));
    }
  }

  void _onRatingSelected(
    RatingSelected event,
    Emitter<RatingsState> emit,
  ) {
    emit(state.copyWith(
      selectedRating: event.rating,
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }

  Future<void> _onRatingSubmitted(
    RatingSubmitted event,
    Emitter<RatingsState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      final request = RatingSubmitRequest(
        rideId: event.rideId,
        rating: event.rating,
        comment: event.comment,
        category: event.category,
      );

      // TODO: Implement rating submission through shared_repo
      // For now, simulate success
      
      // Simulate success
      add(const RatingsLoaded());
      emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        clearError: true,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Submit error: ${error.toString()}',
      ));
    }
  }

  Future<void> _onRatingDeleted(
    RatingDeleted event,
    Emitter<RatingsState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      // TODO: Implement rating deletion through shared_repo
      // For now, simulate success
      
      // Simulate success
      add(const RatingsLoaded());
      emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        clearError: true,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Delete error: ${error.toString()}',
      ));
    }
  }

  void _onRatingsFiltered(
    RatingsFiltered event,
    Emitter<RatingsState> emit,
  ) {
    List<Rating> filteredRatings = state.allRatings;
    
    // Apply filters
    if (event.minRating != null) {
      filteredRatings = filteredRatings.where((r) => r.rating >= event.minRating!).toList();
    }
    
    if (event.maxRating != null) {
      filteredRatings = filteredRatings.where((r) => r.rating <= event.maxRating!).toList();
    }
    
    if (event.category != null) {
      filteredRatings = filteredRatings.where((r) => r.category == event.category).toList();
    }
    
    if (event.hasComment != null) {
      if (event.hasComment!) {
        filteredRatings = filteredRatings.where((r) => r.comment != null && r.comment!.isNotEmpty).toList();
      } else {
        filteredRatings = filteredRatings.where((r) => r.comment == null || r.comment!.isEmpty).toList();
      }
    }

    emit(state.copyWith(
      filteredRatings: filteredRatings,
      status: FormzSubmissionStatus.success,
      clearError: true,
    ));
  }

  Future<void> _onRatingsRefreshed(
    RatingsRefreshed event,
    Emitter<RatingsState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      // Refresh ratings to get latest data
      add(const RatingsLoaded());
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Refresh error: ${error.toString()}',
      ));
    }
  }

  void _onRatingValueChanged(
    RatingValueChanged event,
    Emitter<RatingsState> emit,
  ) {
    final ratingValue = RatingValue.dirty(event.ratingValue);
    emit(
      state.copyWith(
        ratingValue: ratingValue,
        status: FormzSubmissionStatus.initial,
      ),
    );
  }

  void _onCommentChanged(
    CommentChanged event,
    Emitter<RatingsState> emit,
  ) {
    final comment = Comment.dirty(event.comment);
    emit(
      state.copyWith(
        comment: comment,
        status: FormzSubmissionStatus.initial,
      ),
    );
  }

  Map<int, int> _calculateRatingDistribution(List<Rating> ratings) {
    final distribution = <int, int>{};
    
    for (int i = 1; i <= 5; i++) {
      distribution[i] = ratings.where((r) => r.rating == i).length;
    }
    
    return distribution;
  }
}
