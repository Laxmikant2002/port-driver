import 'package:flutter/material.dart';

import 'package:driver/routes/account_routes.dart';
import 'package:driver/routes/auth_routes.dart';
import 'package:driver/routes/main_routes.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> getAllRoutes() {
    return {
      // Authentication flow
      ...AuthRoutes.getRoutes(),
      
      // Main app functionality (driver status, booking, trips)
      ...MainRoutes.getRoutes(),
      
      // Account management (profile, documents, history, settings, etc.)
      ...AccountRoutes.getRoutes(),
    };
  }
}
