import 'package:equatable/equatable.dart';

/// {@template work_location}
/// A model representing a work location/city where a driver can earn.
/// {@endtemplate}
class WorkLocation extends Equatable {
  /// {@macro work_location}
  const WorkLocation({
    required this.id,
    required this.name,
    required this.state,
    this.isActive = true,
  });

  /// The unique identifier for the work location.
  final String id;

  /// The name of the city/location.
  final String name;

  /// The state where this location is situated.
  final String state;

  /// Whether this location is currently active for earning.
  final bool isActive;

  /// Creates a copy of this work location with the given fields replaced.
  WorkLocation copyWith({
    String? id,
    String? name,
    String? state,
    bool? isActive,
  }) {
    return WorkLocation(
      id: id ?? this.id,
      name: name ?? this.name,
      state: state ?? this.state,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Creates a work location from a JSON map.
  factory WorkLocation.fromJson(Map<String, dynamic> json) {
    return WorkLocation(
      id: json['id'] as String,
      name: json['name'] as String,
      state: json['state'] as String,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  /// Converts this work location to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'state': state,
      'isActive': isActive,
    };
  }

  @override
  List<Object?> get props => [id, name, state, isActive];

  @override
  String toString() {
    return 'WorkLocation(id: $id, name: $name, state: $state, isActive: $isActive)';
  }
}