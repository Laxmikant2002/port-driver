import 'package:equatable/equatable.dart';

/// Driver level model for rewards system
class DriverLevel extends Equatable {
  const DriverLevel({
    required this.id,
    required this.name,
    required this.minTrips,
    required this.minRating,
    required this.minStreak,
    required this.badge,
    required this.color,
    required this.benefits,
    this.description,
    this.icon,
  });

  final String id;
  final String name;
  final int minTrips;
  final double minRating;
  final int minStreak;
  final String badge;
  final String color;
  final List<String> benefits;
  final String? description;
  final String? icon;

  factory DriverLevel.fromJson(Map<String, dynamic> json) {
    return DriverLevel(
      id: json['id'] as String,
      name: json['name'] as String,
      minTrips: json['minTrips'] as int,
      minRating: (json['minRating'] as num).toDouble(),
      minStreak: json['minStreak'] as int,
      badge: json['badge'] as String,
      color: json['color'] as String,
      benefits: (json['benefits'] as List<dynamic>).cast<String>(),
      description: json['description'] as String?,
      icon: json['icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'minTrips': minTrips,
      'minRating': minRating,
      'minStreak': minStreak,
      'badge': badge,
      'color': color,
      'benefits': benefits,
      'description': description,
      'icon': icon,
    };
  }

  DriverLevel copyWith({
    String? id,
    String? name,
    int? minTrips,
    double? minRating,
    int? minStreak,
    String? badge,
    String? color,
    List<String>? benefits,
    String? description,
    String? icon,
  }) {
    return DriverLevel(
      id: id ?? this.id,
      name: name ?? this.name,
      minTrips: minTrips ?? this.minTrips,
      minRating: minRating ?? this.minRating,
      minStreak: minStreak ?? this.minStreak,
      badge: badge ?? this.badge,
      color: color ?? this.color,
      benefits: benefits ?? this.benefits,
      description: description ?? this.description,
      icon: icon ?? this.icon,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        minTrips,
        minRating,
        minStreak,
        badge,
        color,
        benefits,
        description,
        icon,
      ];

  @override
  String toString() {
    return 'DriverLevel('
        'id: $id, '
        'name: $name, '
        'minTrips: $minTrips, '
        'minRating: $minRating'
        ')';
  }
}

/// Driver progress model
class DriverProgress extends Equatable {
  const DriverProgress({
    required this.currentLevel,
    required this.nextLevel,
    required this.totalTrips,
    required this.currentRating,
    required this.currentStreak,
    required this.levelProgress,
    required this.tripsToNextLevel,
    required this.ratingToNextLevel,
    required this.streakToNextLevel,
  });

  final DriverLevel currentLevel;
  final DriverLevel? nextLevel;
  final int totalTrips;
  final double currentRating;
  final int currentStreak;
  final double levelProgress;
  final int tripsToNextLevel;
  final double ratingToNextLevel;
  final int streakToNextLevel;

  /// Progress percentage (0.0 to 1.0)
  double get progressPercentage => levelProgress.clamp(0.0, 1.0);

  /// Progress percentage as integer (0 to 100)
  int get progressPercentageInt => (progressPercentage * 100).round();

  /// Whether driver can level up
  bool get canLevelUp => nextLevel != null && levelProgress >= 1.0;

  /// Whether driver is at max level
  bool get isMaxLevel => nextLevel == null;

  factory DriverProgress.fromJson(Map<String, dynamic> json) {
    return DriverProgress(
      currentLevel: DriverLevel.fromJson(json['currentLevel'] as Map<String, dynamic>),
      nextLevel: json['nextLevel'] != null 
          ? DriverLevel.fromJson(json['nextLevel'] as Map<String, dynamic>)
          : null,
      totalTrips: json['totalTrips'] as int,
      currentRating: (json['currentRating'] as num).toDouble(),
      currentStreak: json['currentStreak'] as int,
      levelProgress: (json['levelProgress'] as num).toDouble(),
      tripsToNextLevel: json['tripsToNextLevel'] as int,
      ratingToNextLevel: (json['ratingToNextLevel'] as num).toDouble(),
      streakToNextLevel: json['streakToNextLevel'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentLevel': currentLevel.toJson(),
      'nextLevel': nextLevel?.toJson(),
      'totalTrips': totalTrips,
      'currentRating': currentRating,
      'currentStreak': currentStreak,
      'levelProgress': levelProgress,
      'tripsToNextLevel': tripsToNextLevel,
      'ratingToNextLevel': ratingToNextLevel,
      'streakToNextLevel': streakToNextLevel,
    };
  }

  DriverProgress copyWith({
    DriverLevel? currentLevel,
    DriverLevel? nextLevel,
    int? totalTrips,
    double? currentRating,
    int? currentStreak,
    double? levelProgress,
    int? tripsToNextLevel,
    double? ratingToNextLevel,
    int? streakToNextLevel,
  }) {
    return DriverProgress(
      currentLevel: currentLevel ?? this.currentLevel,
      nextLevel: nextLevel ?? this.nextLevel,
      totalTrips: totalTrips ?? this.totalTrips,
      currentRating: currentRating ?? this.currentRating,
      currentStreak: currentStreak ?? this.currentStreak,
      levelProgress: levelProgress ?? this.levelProgress,
      tripsToNextLevel: tripsToNextLevel ?? this.tripsToNextLevel,
      ratingToNextLevel: ratingToNextLevel ?? this.ratingToNextLevel,
      streakToNextLevel: streakToNextLevel ?? this.streakToNextLevel,
    );
  }

  @override
  List<Object?> get props => [
        currentLevel,
        nextLevel,
        totalTrips,
        currentRating,
        currentStreak,
        levelProgress,
        tripsToNextLevel,
        ratingToNextLevel,
        streakToNextLevel,
      ];

  @override
  String toString() {
    return 'DriverProgress('
        'currentLevel: ${currentLevel.name}, '
        'totalTrips: $totalTrips, '
        'currentRating: $currentRating, '
        'currentStreak: $currentStreak, '
        'levelProgress: $levelProgress'
        ')';
  }
}
