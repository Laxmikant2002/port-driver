import 'package:flutter/material.dart';
import 'package:driver/routes/auth_routes.dart';
import 'package:driver/routes/profile_routes.dart';
import 'package:driver/routes/driver_status_routes.dart';
import 'package:driver/routes/booking_routes.dart';
import 'package:driver/routes/trip_routes.dart';
import 'package:driver/routes/finance_routes.dart';
import 'package:driver/routes/history_routes.dart';
import 'package:driver/routes/rewards_routes.dart';
import 'package:driver/routes/help_support_routes.dart';
import 'package:driver/routes/notifications_routes.dart';
import 'package:driver/routes/settings_routes.dart';
import 'package:driver/routes/document_upload_routes.dart';
import 'package:driver/routes/document_routes.dart';
import 'package:driver/routes/account_routes.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> getAllRoutes() {
    return {
      // Authentication flow
      ...AuthRoutes.getRoutes(),
      
      // Driver profile management
      ...ProfileRoutes.getRoutes(),
      
      // Driver status and dashboard
      ...DriverStatusRoutes.getRoutes(),
      
      // Booking management
      ...BookingRoutes.getRoutes(),
      
      // Trip lifecycle
      ...TripRoutes.getRoutes(),
      
      // Finance and earnings
      ...FinanceRoutes.getRoutes(),
      
      // History and ratings
      ...HistoryRoutes.getRoutes(),
      
      // Rewards and achievements
      ...RewardsRoutes.getRoutes(),
      
      // Help and support
      ...HelpSupportRoutes.getRoutes(),
      
      // Notifications
      ...NotificationsRoutes.getRoutes(),
      
      // Settings
      ...SettingsRoutes.getRoutes(),
      
      // Modern document upload flow
      ...DocumentUploadRoutes.getRoutes(),
      
      // Document management for active drivers
      ...DocumentRoutes.getRoutes(),
      
      // Account management
      ...AccountRoutes.getRoutes(),
    };
  }
}
