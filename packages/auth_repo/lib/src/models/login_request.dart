import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'login_request.g.dart';

@JsonSerializable()
class LoginRequest extends Equatable {
  const LoginRequest({
    required this.phone,
    this.otp,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  final String phone;
  final String? otp;

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);

  @override
  List<Object?> get props => [phone, otp];
} 