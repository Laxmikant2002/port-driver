import 'dart:convert';

ResendOtpResponse resendOtpResponseFromJson(String str) =>
    ResendOtpResponse.fromJson(json.decode(str));

String resendOtpResponseToJson(ResendOtpResponse data) =>
    json.encode(data.toJson());

class ResendOtpResponse {
  final String otp;
  final String otpToken;

  ResendOtpResponse({
    required this.otp,
    required this.otpToken,
  });

  factory ResendOtpResponse.fromJson(Map<String, dynamic> json) =>
      ResendOtpResponse(
        otp: json["otp"],
        otpToken: json["otpToken"],
      );

  Map<String, dynamic> toJson() => {
        "otp": otp,
        "otpToken": otpToken,
      };
}
