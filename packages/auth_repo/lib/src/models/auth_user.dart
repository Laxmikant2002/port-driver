import 'package:equatable/equatable.dart';

/// User model for authentication
class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    required this.phone,
    this.name,
    this.email,
    this.isVerified = false,
    this.isNewUser = false,
    this.profileComplete = false,
    this.documentVerified = false,
  });

  final String id;
  final String phone;
  final String? name;
  final String? email;
  final bool isVerified;
  final bool isNewUser;
  final bool profileComplete;
  final bool documentVerified;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      phone: json['phone'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      isNewUser: json['isNewUser'] as bool? ?? false,
      profileComplete: json['profileComplete'] as bool? ?? false,
      documentVerified: json['documentVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'name': name,
      'email': email,
      'isVerified': isVerified,
      'isNewUser': isNewUser,
      'profileComplete': profileComplete,
      'documentVerified': documentVerified,
    };
  }

  AuthUser copyWith({
    String? id,
    String? phone,
    String? name,
    String? email,
    bool? isVerified,
    bool? isNewUser,
    bool? profileComplete,
    bool? documentVerified,
  }) {
    return AuthUser(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      email: email ?? this.email,
      isVerified: isVerified ?? this.isVerified,
      isNewUser: isNewUser ?? this.isNewUser,
      profileComplete: profileComplete ?? this.profileComplete,
      documentVerified: documentVerified ?? this.documentVerified,
    );
  }

  @override
  List<Object?> get props => [
        id,
        phone,
        name,
        email,
        isVerified,
        isNewUser,
        profileComplete,
        documentVerified,
      ];

  @override
  String toString() {
    return 'AuthUser('
        'id: $id, '
        'phone: $phone, '
        'name: $name, '
        'email: $email, '
        'isVerified: $isVerified, '
        'isNewUser: $isNewUser, '
        'profileComplete: $profileComplete, '
        'documentVerified: $documentVerified'
        ')';
  }
}
