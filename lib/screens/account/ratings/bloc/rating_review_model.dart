class RatingReview {
  final String name;
  final String profileUrl;
  final double rating;
  final String comment;
  final DateTime date;

  RatingReview({
    required this.name,
    required this.profileUrl,
    required this.rating,
    required this.comment,
    required this.date,
  });
}