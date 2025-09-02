import 'package:flutter/services.dart';
export './auth_paths.dart';

class BasePaths {
  static final String mainUrl = appFlavor == 'development'
      ? "http://192.168.1.35:3002"
      : "https://backend.siteright360.com";
  static final String baseUrl = mainUrl;
}