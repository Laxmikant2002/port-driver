import 'package:equatable/equatable.dart';

/// Challenge model
class Challenge extends Equatable {
  const Challenge({
    required this.id,
    required this.name,
    required this.description,
    required this.target,
    required this.progress,
    required this.isCompleted,
    required this.endDate,
    this.rewardAmount,
    this.category,
    this.startDate,
  });

  final String id;
  final String name;
  final String description;
  final double target;
  final double progress;
  final bool isCompleted;
  final DateTime endDate;
  final double? rewardAmount;
  final String? category;
  final DateTime? startDate;

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      target: (json['target'] as num).toDouble(),
      progress: (json['progress'] as num).toDouble(),
      isCompleted: json['isCompleted'] as bool? ?? false,
      endDate: DateTime.parse(json['endDate'] as String),
      rewardAmount: (json['rewardAmount'] as num?)?.toDouble(),
      category: json['category'] as String?,
      startDate: json['startDate'] != null 
          ? DateTime.parse(json['startDate'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'target': target,
      'progress': progress,
      'isCompleted': isCompleted,
      'endDate': endDate.toIso8601String(),
      'rewardAmount': rewardAmount,
      'category': category,
      'startDate': startDate?.toIso8601String(),
    };
  }

  Challenge copyWith({
    String? id,
    String? name,
    String? description,
    double? target,
    double? progress,
    bool? isCompleted,
    DateTime? endDate,
    double? rewardAmount,
    String? category,
    DateTime? startDate,
  }) {
    return Challenge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      target: target ?? this.target,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      endDate: endDate ?? this.endDate,
      rewardAmount: rewardAmount ?? this.rewardAmount,
      category: category ?? this.category,
      startDate: startDate ?? this.startDate,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        target,
        progress,
        isCompleted,
        endDate,
        rewardAmount,
        category,
        startDate,
      ];
}
