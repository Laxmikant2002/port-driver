import 'package:equatable/equatable.dart';

/// Vehicle model
class Vehicle extends Equatable {
  const Vehicle({
    required this.id,
    required this.name,
    required this.number,
    required this.year,
    required this.type,
    required this.photoPath,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String number;
  final String year;
  final String type;
  final String photoPath;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String,
      name: json['name'] as String,
      number: json['number'] as String,
      year: json['year'] as String,
      type: json['type'] as String,
      photoPath: json['photoPath'] as String,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'number': number,
      'year': year,
      'type': type,
      'photoPath': photoPath,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Vehicle copyWith({
    String? id,
    String? name,
    String? number,
    String? year,
    String? type,
    String? photoPath,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Vehicle(
      id: id ?? this.id,
      name: name ?? this.name,
      number: number ?? this.number,
      year: year ?? this.year,
      type: type ?? this.type,
      photoPath: photoPath ?? this.photoPath,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, number, year, type, photoPath, isActive, createdAt, updatedAt];
}
