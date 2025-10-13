import 'package:equatable/equatable.dart';

/// Achievement model
class Achievement extends Equatable {
  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    required this.unlockedAt,
    this.rewardAmount,
    this.category,
  });

  final String id;
  final String name;
  final String description;
  final String icon;
  final bool isUnlocked;
  final DateTime unlockedAt;
  final double? rewardAmount;
  final String? category;

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: DateTime.parse(json['unlockedAt'] as String),
      rewardAmount: (json['rewardAmount'] as num?)?.toDouble(),
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt.toIso8601String(),
      'rewardAmount': rewardAmount,
      'category': category,
    };
  }

  Achievement copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    bool? isUnlocked,
    DateTime? unlockedAt,
    double? rewardAmount,
    String? category,
  }) {
    return Achievement(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      rewardAmount: rewardAmount ?? this.rewardAmount,
      category: category ?? this.category,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        icon,
        isUnlocked,
        unlockedAt,
        rewardAmount,
        category,
      ];
}
