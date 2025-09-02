import 'dart:convert';

VerifyResponse verifyResponseFromJson(String str) =>
    VerifyResponse.fromJson(json.decode(str));

String verifyResponseToJson(VerifyResponse data) =>
    json.encode(data.toJson());

class VerifyResponse {
  final bool status;
  final String error;

  VerifyResponse({
    required this.status,
    required this.error,
  });

  factory VerifyResponse.fromJson(Map<String, dynamic> json) => VerifyResponse(
        status: json["status"],
        error: json["error"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "error": error,
      };
}
