import 'package:equatable/equatable.dart';

/// Reward model
class Reward extends Equatable {
  const Reward({
    required this.id,
    required this.name,
    required this.description,
    required this.amount,
    required this.isClaimed,
    required this.claimedAt,
    this.category,
    this.expiryDate,
  });

  final String id;
  final String name;
  final String description;
  final double amount;
  final bool isClaimed;
  final DateTime claimedAt;
  final String? category;
  final DateTime? expiryDate;

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      isClaimed: json['isClaimed'] as bool? ?? false,
      claimedAt: DateTime.parse(json['claimedAt'] as String),
      category: json['category'] as String?,
      expiryDate: json['expiryDate'] != null 
          ? DateTime.parse(json['expiryDate'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'amount': amount,
      'isClaimed': isClaimed,
      'claimedAt': claimedAt.toIso8601String(),
      'category': category,
      'expiryDate': expiryDate?.toIso8601String(),
    };
  }

  Reward copyWith({
    String? id,
    String? name,
    String? description,
    double? amount,
    bool? isClaimed,
    DateTime? claimedAt,
    String? category,
    DateTime? expiryDate,
  }) {
    return Reward(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      isClaimed: isClaimed ?? this.isClaimed,
      claimedAt: claimedAt ?? this.claimedAt,
      category: category ?? this.category,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        amount,
        isClaimed,
        claimedAt,
        category,
        expiryDate,
      ];
}
