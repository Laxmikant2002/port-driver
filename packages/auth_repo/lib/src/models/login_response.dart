import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'login_response.g.dart';

@JsonSerializable()
class AuthResponse extends Equatable {
  final String? token;
  final User? user;
  final bool otpSent;
  final String? message;

  const AuthResponse({
    this.token,
    this.user,
    this.otpSent = false,
    this.message,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);

  @override
  List<Object?> get props => [token, user, otpSent, message];
}

@JsonSerializable()
class User extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final String vehicleType;
  final bool isOnline;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.vehicleType,
    required this.isOnline,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  List<Object?> get props => [
        id,
        fullName,
        email,
        phone,
        role,
        vehicleType,
        isOnline,
      ];
} 