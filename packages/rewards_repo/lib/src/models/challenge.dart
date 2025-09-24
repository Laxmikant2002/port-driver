import 'package:equatable/equatable.dart';

/// Challenge model for driver rewards
class Challenge extends Equatable {
  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.reward,
    required this.target,
    required this.currentProgress,
    required this.status,
    required this.type,
    required this.duration,
    required this.icon,
    this.timeLeft,
    this.startedAt,
    this.completedAt,
    this.expiresAt,
    this.metadata,
  });

  final String id;
  final String title;
  final String description;
  final double reward;
  final int target;
  final int currentProgress;
  final ChallengeStatus status;
  final ChallengeType type;
  final ChallengeDuration duration;
  final String icon;
  final Duration? timeLeft;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? expiresAt;
  final Map<String, dynamic>? metadata;

  /// Progress percentage (0.0 to 1.0)
  double get progressPercentage => target > 0 ? currentProgress / target : 0.0;

  /// Progress percentage as integer (0 to 100)
  int get progressPercentageInt => (progressPercentage * 100).round();

  /// Whether challenge is active
  bool get isActive => status == ChallengeStatus.active;

  /// Whether challenge is completed
  bool get isCompleted => status == ChallengeStatus.completed;

  /// Whether challenge is expired
  bool get isExpired => status == ChallengeStatus.expired;

  /// Whether challenge is locked
  bool get isLocked => status == ChallengeStatus.locked;

  /// Remaining progress needed
  int get remainingProgress => (target - currentProgress).clamp(0, target);

  /// Whether challenge is expired by time
  bool get isTimeExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  /// Formatted time left string
  String get timeLeftFormatted {
    if (timeLeft == null) return '';
    
    final hours = timeLeft!.inHours;
    final minutes = timeLeft!.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Formatted time left for display
  String get timeLeftDisplay {
    if (timeLeft == null) return '';
    
    final hours = timeLeft!.inHours;
    final minutes = timeLeft!.inMinutes % 60;
    
    if (hours > 0) {
      return 'Time left: ${hours}h ${minutes}m';
    } else {
      return 'Time left: ${minutes}m';
    }
  }

  /// Progress text for display
  String get progressText => '$currentProgress of $target ${getProgressUnit()}';

  /// Progress unit based on challenge type
  String getProgressUnit() {
    switch (type) {
      case ChallengeType.trips:
        return 'trips';
      case ChallengeType.distance:
        return 'km';
      case ChallengeType.rating:
        return 'rating';
      case ChallengeType.streak:
        return 'days';
      case ChallengeType.earnings:
        return 'earnings';
    }
  }

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      reward: (json['reward'] as num).toDouble(),
      target: json['target'] as int,
      currentProgress: json['currentProgress'] as int,
      status: ChallengeStatus.fromString(json['status'] as String),
      type: ChallengeType.fromString(json['type'] as String),
      duration: ChallengeDuration.fromString(json['duration'] as String),
      icon: json['icon'] as String,
      timeLeft: json['timeLeft'] != null 
          ? Duration(seconds: json['timeLeft'] as int)
          : null,
      startedAt: json['startedAt'] != null 
          ? DateTime.parse(json['startedAt'] as String) 
          : null,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String) 
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
      'type': type.value,
      'duration': duration.value,
      'icon': icon,
      'timeLeft': timeLeft?.inSeconds,
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  Challenge copyWith({
    String? id,
    String? title,
    String? description,
    double? reward,
    int? target,
    int? currentProgress,
    ChallengeStatus? status,
    ChallengeType? type,
    ChallengeDuration? duration,
    String? icon,
    Duration? timeLeft,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      reward: reward ?? this.reward,
      target: target ?? this.target,
      currentProgress: currentProgress ?? this.currentProgress,
      status: status ?? this.status,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      icon: icon ?? this.icon,
      timeLeft: timeLeft ?? this.timeLeft,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
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
        type,
        duration,
        icon,
        timeLeft,
        startedAt,
        completedAt,
        expiresAt,
        metadata,
      ];

  @override
  String toString() {
    return 'Challenge('
        'id: $id, '
        'title: $title, '
        'status: $status, '
        'progress: $currentProgress/$target'
        ')';
  }
}

/// Challenge status enum
enum ChallengeStatus {
  locked('locked', 'Locked'),
  active('active', 'Active'),
  completed('completed', 'Completed'),
  expired('expired', 'Expired');

  const ChallengeStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  static ChallengeStatus fromString(String value) {
    return ChallengeStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => throw ArgumentError('Unknown challenge status: $value'),
    );
  }
}

/// Challenge type enum
enum ChallengeType {
  trips('trips', 'Trips'),
  distance('distance', 'Distance'),
  rating('rating', 'Rating'),
  streak('streak', 'Streak'),
  earnings('earnings', 'Earnings');

  const ChallengeType(this.value, this.displayName);

  final String value;
  final String displayName;

  static ChallengeType fromString(String value) {
    return ChallengeType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw ArgumentError('Unknown challenge type: $value'),
    );
  }
}

/// Challenge duration enum
enum ChallengeDuration {
  daily('daily', 'Daily'),
  weekly('weekly', 'Weekly'),
  monthly('monthly', 'Monthly');

  const ChallengeDuration(this.value, this.displayName);

  final String value;
  final String displayName;

  static ChallengeDuration fromString(String value) {
    return ChallengeDuration.values.firstWhere(
      (duration) => duration.value == value,
      orElse: () => throw ArgumentError('Unknown challenge duration: $value'),
    );
  }
}
