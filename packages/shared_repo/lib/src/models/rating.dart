import 'package:equatable/equatable.dart';

/// Rating categories for different aspects of service
enum RatingCategory {
  overall,
  punctuality,
  cleanliness,
  communication,
  safety,
  comfort,
}

/// Rating model for driver ratings
class Rating extends Equatable {
  const Rating({
    required this.id,
    required this.driverId,
    required this.passengerId,
    required this.rideId,
    required this.rating,
    required this.createdAt,
    this.comment,
    this.category,
    this.tags = const [],
  });

  final String id;
  final String driverId;
  final String passengerId;
  final String rideId;
  final double rating;
  final DateTime createdAt;
  final String? comment;
  final RatingCategory? category;
  final List<String> tags;

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'] as String,
      driverId: json['driverId'] as String,
      passengerId: json['passengerId'] as String,
      rideId: json['rideId'] as String,
      rating: (json['rating'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      comment: json['comment'] as String?,
      category: json['category'] != null 
          ? RatingCategory.values.firstWhere(
              (e) => e.name == json['category'],
              orElse: () => RatingCategory.overall,
            )
          : RatingCategory.overall,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driverId': driverId,
      'passengerId': passengerId,
      'rideId': rideId,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
      'comment': comment,
      'category': category?.name,
      'tags': tags,
    };
  }

  Rating copyWith({
    String? id,
    String? driverId,
    String? passengerId,
    String? rideId,
    double? rating,
    DateTime? createdAt,
    String? comment,
    RatingCategory? category,
    List<String>? tags,
  }) {
    return Rating(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      passengerId: passengerId ?? this.passengerId,
      rideId: rideId ?? this.rideId,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      comment: comment ?? this.comment,
      category: category ?? this.category,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [
        id,
        driverId,
        passengerId,
        rideId,
        rating,
        createdAt,
        comment,
        category,
        tags,
      ];

  @override
  String toString() {
    return 'Rating('
        'id: $id, '
        'rating: $rating, '
        'comment: $comment, '
        'createdAt: $createdAt'
        ')';
  }
}

/// Rating statistics model
class RatingStatistics extends Equatable {
  const RatingStatistics({
    required this.averageRating,
    required this.totalRatings,
    required this.ratingDistribution,
    required this.recentRatings,
    this.period,
  });

  final double averageRating;
  final int totalRatings;
  final Map<int, int> ratingDistribution; // rating -> count
  final List<Rating> recentRatings;
  final String? period;

  factory RatingStatistics.fromJson(Map<String, dynamic> json) {
    return RatingStatistics(
      averageRating: (json['averageRating'] as num).toDouble(),
      totalRatings: json['totalRatings'] as int,
      ratingDistribution: Map<int, int>.from(json['ratingDistribution'] as Map),
      recentRatings: (json['recentRatings'] as List<dynamic>)
          .map((e) => Rating.fromJson(e as Map<String, dynamic>))
          .toList(),
      period: json['period'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'averageRating': averageRating,
      'totalRatings': totalRatings,
      'ratingDistribution': ratingDistribution,
      'recentRatings': recentRatings.map((e) => e.toJson()).toList(),
      'period': period,
    };
  }

  @override
  List<Object?> get props => [
        averageRating,
        totalRatings,
        ratingDistribution,
        recentRatings,
        period,
      ];
}

/// Request model for submitting a rating
class RatingSubmitRequest extends Equatable {
  const RatingSubmitRequest({
    required this.rideId,
    required this.rating,
    this.comment,
    this.category = RatingCategory.overall,
  });

  final String rideId;
  final int rating;
  final String? comment;
  final RatingCategory category;

  Map<String, dynamic> toJson() {
    return {
      'rideId': rideId,
      'rating': rating,
      'comment': comment,
      'category': category.name,
    };
  }

  @override
  List<Object?> get props => [rideId, rating, comment, category];
}
