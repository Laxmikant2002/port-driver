import 'package:flutter/material.dart';
import 'package:driver/routes/account_routes.dart';
import 'package:driver/routes/auth_routes.dart';
import 'package:driver/routes/dashboard_routes.dart';
import 'package:driver/routes/settings_routes.dart';
import 'package:driver/routes/docs_routes.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> getAllRoutes() {
    return {
      ...AuthRoutes.getRoutes(),
      ...DashboardRoutes.getRoutes(),
      ...AccountRoutes.getRoutes(),
      ...SettingsRoutes.getRoutes(),
      ...DocsRoutes.getRoutes(),
    };
  }
}
