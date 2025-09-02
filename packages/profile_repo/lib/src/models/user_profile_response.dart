import 'dart:convert';
import 'package:profile_repo/profile_repo.dart';

UserProfileResponse userProfileResponseFromJson(Map<String, dynamic> json) =>
    UserProfileResponse.fromJson(json);

String userProfileResponseToJson(UserProfileResponse data) =>
    json.encode(data.toJson());

class UserProfileResponse {
  final bool status;
  final UserProfile user;

  UserProfileResponse({
    required this.status,
    required this.user,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileResponse(
      status: json["status"] as bool,
      user: UserProfile.fromJson(json["user"] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "user": user.toJson(),
    };
  }
}

class UserProfile {
  final String id;
  final String email;
  final String password;
  final dynamic emailVerifiedAt;
  final String name;
  final String firstName;
  final String lastName;
  final String language;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final dynamic deletedAt;
  final UserDetail? userDetail;
  final List<UserService>? userServices;

  UserProfile({
    required this.id,
    required this.email,
    required this.password,
    this.emailVerifiedAt,
    required this.name,
    required this.firstName,
    required this.lastName,
    required this.language,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.userDetail,
    this.userServices,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json["id"] as String? ?? '',
      email: json["email"] as String? ?? '',
      password: json["password"] as String? ?? '',
      emailVerifiedAt: json["emailVerifiedAt"],
      name: json["name"] as String? ?? '',
      firstName: json["firstName"] as String? ?? '',
      lastName: json["lastName"] as String? ?? '',
      language: json["language"] as String? ?? '',
      status: json["status"] as int? ?? 0,
      createdAt: json["createdAt"] != null
          ? DateTime.parse(json["createdAt"] as String)
          : DateTime.now(),
      updatedAt: json["updatedAt"] != null
          ? DateTime.parse(json["updatedAt"] as String)
          : DateTime.now(),
      deletedAt: json["deletedAt"],
      userDetail: json["UserDetail"] != null
          ? UserDetail.fromJson(json["UserDetail"] as Map<String, dynamic>)
          : null,
      userServices: json["UserService"] != null
          ? (json["UserService"] as List<dynamic>)
              .map((x) => UserService.fromJson(x as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "email": email,
      "password": password,
      "emailVerifiedAt": emailVerifiedAt,
      "name": name,
      "firstName": firstName,
      "lastName": lastName,
      "language": language,
      "status": status,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
      "deletedAt": deletedAt,
      "UserDetail": userDetail?.toJson(),
      "UserService": userServices?.map((x) => x.toJson()).toList() ?? [],
    };
  }
}

class UserDetail {
  // Placeholder properties for UserDetail
  final String detail;

  UserDetail({required this.detail});

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    return UserDetail(
      detail: json['detail'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'detail': detail,
    };
  }
}

class UserService {
  // Placeholder properties for UserService
  final String serviceName;

  UserService({required this.serviceName});

  factory UserService.fromJson(Map<String, dynamic> json) {
    return UserService(
      serviceName: json['serviceName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceName': serviceName,
    };
  }
}
