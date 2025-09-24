import 'package:equatable/equatable.dart';

/// Achievement model for driver rewards
class Achievement extends Equatable {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.reward,
    required this.target,
    required this.currentProgress,
    required this.status,
    required this.category,
    required this.icon,
    this.unlockedAt,
    this.expiresAt,
    this.metadata,
  });

  final String id;
  final String title;
  final String description;
  final double reward;
  final int target;
  final int currentProgress;
  final AchievementStatus status;
  final AchievementCategory category;
  final String icon;
  final DateTime? unlockedAt;
  final DateTime? expiresAt;
  final Map<String, dynamic>? metadata;

  /// Progress percentage (0.0 to 1.0)
  double get progressPercentage => target > 0 ? currentProgress / target : 0.0;

  /// Progress percentage as integer (0 to 100)
  int get progressPercentageInt => (progressPercentage * 100).round();

  /// Whether achievement is unlocked
  bool get isUnlocked => status == AchievementStatus.unlocked;

  /// Whether achievement is in progress
  bool get isInProgress => status == AchievementStatus.inProgress;

  /// Whether achievement is locked
  bool get isLocked => status == AchievementStatus.locked;

  /// Remaining progress needed
  int get remainingProgress => (target - currentProgress).clamp(0, target);

  /// Whether achievement is expired
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      reward: (json['reward'] as num).toDouble(),
      target: json['target'] as int,
      currentProgress: json['currentProgress'] as int,
      status: AchievementStatus.fromString(json['status'] as String),
      category: AchievementCategory.fromString(json['category'] as String),
      icon: json['icon'] as String,
      unlockedAt: json['unlockedAt'] != null 
          ? DateTime.parse(json['unlockedAt'] as String) 
          : null,
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt'] as String) 
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'reward': reward,
      'target': target,
      'currentProgress': currentProgress,
      'status': status.value,
      'category': category.value,
      'icon': icon,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    double? reward,
    int? target,
    int? currentProgress,
    AchievementStatus? status,
    AchievementCategory? category,
    String? icon,
    DateTime? unlockedAt,
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      reward: reward ?? this.reward,
      target: target ?? this.target,
      currentProgress: currentProgress ?? this.currentProgress,
      status: status ?? this.status,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        reward,
        target,
        currentProgress,
        status,
        category,
        icon,
        unlockedAt,
        expiresAt,
        metadata,
      ];

  @override
  String toString() {
    return 'Achievement('
        'id: $id, '
        'title: $title, '
        'status: $status, '
        'progress: $currentProgress/$target'
        ')';
  }
}

/// Achievement status enum
enum AchievementStatus {
  locked('locked', 'Locked'),
  inProgress('in_progress', 'In Progress'),
  unlocked('unlocked', 'Unlocked'),
  expired('expired', 'Expired');

  const AchievementStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  static AchievementStatus fromString(String value) {
    return AchievementStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => throw ArgumentError('Unknown achievement status: $value'),
    );
  }
}

/// Achievement category enum
enum AchievementCategory {
  streak('streak', 'Streak'),
  speed('speed', 'Speed'),
  rating('rating', 'Rating'),
  distance('distance', 'Distance'),
  time('time', 'Time'),
  special('special', 'Special');

  const AchievementCategory(this.value, this.displayName);

  final String value;
  final String displayName;

  static AchievementCategory fromString(String value) {
    return AchievementCategory.values.firstWhere(
      (category) => category.value == value,
      orElse: () => throw ArgumentError('Unknown achievement category: $value'),
    );
  }
}
