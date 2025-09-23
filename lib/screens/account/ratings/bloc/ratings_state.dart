part of 'ratings_bloc.dart';

enum RatingValueValidationError { empty, invalid }

class RatingValue extends FormzInput<int, RatingValueValidationError> {
  const RatingValue.pure() : super.pure(0);
  const RatingValue.dirty([super.value = 0]) : super.dirty();

  @override
  RatingValueValidationError? validator(int value) {
    if (value == 0) return RatingValueValidationError.empty;
    if (value < 1 || value > 5) return RatingValueValidationError.invalid;
    return null;
  }
}

enum CommentValidationError { tooLong }

class Comment extends FormzInput<String, CommentValidationError> {
  const Comment.pure() : super.pure('');
  const Comment.dirty([super.value = '']) : super.dirty();

  @override
  CommentValidationError? validator(String value) {
    if (value.length > 500) return CommentValidationError.tooLong;
    return null;
  }
}

/// Ratings state containing rating data and submission status
final class RatingsState extends Equatable {
  const RatingsState({
    this.allRatings = const [],
    this.filteredRatings = const [],
    this.selectedRating,
    this.averageRating = 0.0,
    this.ratingDistribution = const {},
    this.totalRatings = 0,
    this.ratingValue = const RatingValue.pure(),
    this.comment = const Comment.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.errorMessage,
  });

  final List<Rating> allRatings;
  final List<Rating> filteredRatings;
  final Rating? selectedRating;
  final double averageRating;
  final Map<int, int> ratingDistribution;
  final int totalRatings;
  final RatingValue ratingValue;
  final Comment comment;
  final FormzSubmissionStatus status;
  final String? errorMessage;

  /// Returns true if the form is valid and ready for submission
  bool get isValid => Formz.validate([ratingValue, comment]);

  /// Returns true if ratings are currently being loaded
  bool get isLoading => status == FormzSubmissionStatus.inProgress;

  /// Returns true if ratings were loaded successfully
  bool get isSuccess => status == FormzSubmissionStatus.success;

  /// Returns true if rating operation failed
  bool get isFailure => status == FormzSubmissionStatus.failure;

  /// Returns true if there's an error message
  bool get hasError => isFailure && errorMessage != null;

  /// Returns the current error message if any
  String? get error => errorMessage;

  /// Returns true if the form is currently being submitted
  bool get isSubmitting => status == FormzSubmissionStatus.inProgress;

  /// Returns the current ratings being displayed (filtered or all)
  List<Rating> get currentRatings => filteredRatings.isNotEmpty ? filteredRatings : allRatings;

  /// Returns ratings grouped by month
  Map<String, List<Rating>> get ratingsByMonth {
    final Map<String, List<Rating>> grouped = {};
    
    for (final rating in allRatings) {
      final month = '${rating.createdAt.year}-${rating.createdAt.month.toString().padLeft(2, '0')}';
      if (!grouped.containsKey(month)) {
        grouped[month] = [];
      }
      grouped[month]!.add(rating);
    }
    
    // Sort ratings within each month by creation time (newest first)
    for (final ratings in grouped.values) {
      ratings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    
    return grouped;
  }

  /// Returns ratings grouped by category
  Map<RatingCategory, List<Rating>> get ratingsByCategory {
    final Map<RatingCategory, List<Rating>> grouped = {};
    
    for (final rating in allRatings) {
      if (rating.category != null) {
        if (!grouped.containsKey(rating.category!)) {
          grouped[rating.category!] = [];
        }
        grouped[rating.category!]!.add(rating);
      }
    }
    
    return grouped;
  }

  /// Returns average rating by category
  Map<RatingCategory, double> get averageRatingByCategory {
    final categoryRatings = ratingsByCategory;
    final Map<RatingCategory, double> averages = {};
    
    for (final entry in categoryRatings.entries) {
      if (entry.value.isNotEmpty) {
        final sum = entry.value.map((r) => r.rating).reduce((a, b) => a + b);
        averages[entry.key] = sum / entry.value.length;
      } else {
        averages[entry.key] = 0.0;
      }
    }
    
    return averages;
  }

  /// Returns recent ratings (last 10)
  List<Rating> get recentRatings {
    final sorted = List<Rating>.from(allRatings);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(10).toList();
  }

  /// Returns ratings with comments
  List<Rating> get ratingsWithComments {
    return allRatings.where((r) => r.comment != null && r.comment!.isNotEmpty).toList();
  }

  /// Returns high ratings (4 and 5 stars)
  List<Rating> get highRatings {
    return allRatings.where((r) => r.rating >= 4).toList();
  }

  /// Returns low ratings (1 and 2 stars)
  List<Rating> get lowRatings {
    return allRatings.where((r) => r.rating <= 2).toList();
  }

  /// Returns medium ratings (3 stars)
  List<Rating> get mediumRatings {
    return allRatings.where((r) => r.rating == 3).toList();
  }

  /// Returns percentage of high ratings
  double get highRatingPercentage {
    if (totalRatings == 0) return 0.0;
    return (highRatings.length / totalRatings) * 100;
  }

  /// Returns percentage of low ratings
  double get lowRatingPercentage {
    if (totalRatings == 0) return 0.0;
    return (lowRatings.length / totalRatings) * 100;
  }

  /// Returns rating trend (improving, declining, or stable)
  String get ratingTrend {
    if (totalRatings < 2) return 'stable';
    
    final recent = allRatings.take(10).toList();
    final older = allRatings.skip(10).take(10).toList();
    
    if (recent.isEmpty || older.isEmpty) return 'stable';
    
    final recentAvg = recent.map((r) => r.rating).reduce((a, b) => a + b) / recent.length;
    final olderAvg = older.map((r) => r.rating).reduce((a, b) => a + b) / older.length;
    
    if (recentAvg > olderAvg + 0.2) return 'improving';
    if (recentAvg < olderAvg - 0.2) return 'declining';
    return 'stable';
  }

  RatingsState copyWith({
    List<Rating>? allRatings,
    List<Rating>? filteredRatings,
    Rating? selectedRating,
    double? averageRating,
    Map<int, int>? ratingDistribution,
    int? totalRatings,
    RatingValue? ratingValue,
    Comment? comment,
    FormzSubmissionStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RatingsState(
      allRatings: allRatings ?? this.allRatings,
      filteredRatings: filteredRatings ?? this.filteredRatings,
      selectedRating: selectedRating ?? this.selectedRating,
      averageRating: averageRating ?? this.averageRating,
      ratingDistribution: ratingDistribution ?? this.ratingDistribution,
      totalRatings: totalRatings ?? this.totalRatings,
      ratingValue: ratingValue ?? this.ratingValue,
      comment: comment ?? this.comment,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        allRatings,
        filteredRatings,
        selectedRating,
        averageRating,
        ratingDistribution,
        totalRatings,
        ratingValue,
        comment,
        status,
        errorMessage,
      ];

  @override
  String toString() {
    return 'RatingsState('
        'allRatings: ${allRatings.length}, '
        'filteredRatings: ${filteredRatings.length}, '
        'selectedRating: $selectedRating, '
        'averageRating: $averageRating, '
        'totalRatings: $totalRatings, '
        'ratingValue: $ratingValue, '
        'comment: $comment, '
        'status: $status, '
        'errorMessage: $errorMessage'
        ')';
  }
}
