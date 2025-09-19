import 'package:equatable/equatable.dart';

class LoginRequest extends Equatable {
  const LoginRequest({
    required this.phone,
    this.countryCode = '+91',
    this.otp,
  });

  final String phone;
  final String countryCode;
  final String? otp;

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'countryCode': countryCode,
      'otp': otp,
    };
  }

  LoginRequest copyWith({
    String? phone,
    String? countryCode,
    String? otp,
  }) {
    return LoginRequest(
      phone: phone ?? this.phone,
      countryCode: countryCode ?? this.countryCode,
      otp: otp ?? this.otp,
    );
  }

  @override
  List<Object?> get props => [phone, countryCode, otp];

  @override
  String toString() {
    return 'LoginRequest(phone: $phone, countryCode: $countryCode, otp: $otp)';
  }
} 