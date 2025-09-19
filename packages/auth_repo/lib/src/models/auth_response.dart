import 'package:equatable/equatable.dart';
import 'auth_user.dart';

/// Response model for authentication operations
class AuthResponse extends Equatable {
  const AuthResponse({
    required this.success,
    this.user,
    this.message,
    this.otpSent = false,
    this.otpToken,
    this.accessToken,
    this.refreshToken,
  });

  final bool success;
  final AuthUser? user;
  final String? message;
  final bool otpSent;
  final String? otpToken;
  final String? accessToken;
  final String? refreshToken;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] as bool? ?? false,
      user: json['user'] != null ? AuthUser.fromJson(json['user'] as Map<String, dynamic>) : null,
      message: json['message'] as String?,
      otpSent: json['otpSent'] as bool? ?? false,
      otpToken: json['otpToken'] as String?,
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'user': user?.toJson(),
      'message': message,
      'otpSent': otpSent,
      'otpToken': otpToken,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }

  AuthResponse copyWith({
    bool? success,
    AuthUser? user,
    String? message,
    bool? otpSent,
    String? otpToken,
    String? accessToken,
    String? refreshToken,
  }) {
    return AuthResponse(
      success: success ?? this.success,
      user: user ?? this.user,
      message: message ?? this.message,
      otpSent: otpSent ?? this.otpSent,
      otpToken: otpToken ?? this.otpToken,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }

  @override
  List<Object?> get props => [
        success,
        user,
        message,
        otpSent,
        otpToken,
        accessToken,
        refreshToken,
      ];

  @override
  String toString() {
    return 'AuthResponse('
        'success: $success, '
        'user: $user, '
        'message: $message, '
        'otpSent: $otpSent, '
        'otpToken: $otpToken, '
        'accessToken: $accessToken, '
        'refreshToken: $refreshToken'
        ')';
  }
}
