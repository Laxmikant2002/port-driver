import 'package:flutter/material.dart';
import 'package:driver/screens/account/ride_history/views/history_screen.dart';
import 'package:driver/screens/account/ratings/view/ratings_screen.dart';
import 'package:driver/screens/account/trip_history/views/trip_history_screen.dart';
import 'package:history_repo/history_repo.dart';
import 'package:localstorage/localstorage.dart';
import 'package:api_client/api_client.dart';

class HistoryRoutes {
  // Trip history and ratings
  static const String ridesHistory = '/rides-history';
  static const String tripHistory = '/trip-history';
  static const String ratings = '/ratings';
  static const String tripDetails = '/trip-details';
  static const String earningsHistory = '/earnings-history';
  static const String weeklySummary = '/weekly-summary';
  static const String monthlySummary = '/monthly-summary';

  static Map<String, WidgetBuilder> getRoutes() {
    // Initialize dependencies
    final localStorage = Localstorage();
    final apiClient = ApiClient(
      baseUrl: 'https://api.example.com', // Replace with actual API URL
    );
    final historyRepo = HistoryRepo(
      baseUrl: 'https://api.example.com', // Replace with actual API URL
      apiClient: apiClient,
      localStorage: localStorage,
    );

    return {
      ridesHistory: (context) => const HistoryScreen(),
      tripHistory: (context) => TripHistoryScreen(historyRepo: historyRepo),
      ratings: (context) => const RatingsScreen(),
      tripDetails: (context) {
        // This could be a detailed view of a specific trip
        return const Scaffold(
          body: Center(
            child: Text('Trip Details - Full screen implementation needed'),
          ),
        );
      },
      earningsHistory: (context) {
        // This could be a detailed earnings history screen
        return const Scaffold(
          body: Center(
            child: Text('Earnings History - Full screen implementation needed'),
          ),
        );
      },
      weeklySummary: (context) {
        // This could be a weekly summary screen
        return const Scaffold(
          body: Center(
            child: Text('Weekly Summary - Full screen implementation needed'),
          ),
        );
      },
      monthlySummary: (context) {
        // This could be a monthly summary screen
        return const Scaffold(
          body: Center(
            child: Text('Monthly Summary - Full screen implementation needed'),
          ),
        );
      },
    };
  }
}
