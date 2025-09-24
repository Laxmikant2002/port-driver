import 'package:flutter/material.dart';
import 'package:driver/screens/account/rewards/views/rewards_screen.dart';
import 'package:rewards_repo/rewards_repo.dart';
import 'package:localstorage/localstorage.dart';
import 'package:api_client/api_client.dart';

class RewardsRoutes {
  // Rewards and achievements
  static const String rewards = '/rewards';
  static const String achievements = '/achievements';
  static const String challenges = '/challenges';
  static const String leaderboard = '/leaderboard';

  static Map<String, WidgetBuilder> getRoutes() {
    // Initialize dependencies
    final localStorage = Localstorage();
    final apiClient = ApiClient(
      baseUrl: 'https://api.example.com', // Replace with actual API URL
    );
    final rewardsRepo = RewardsRepo(
      baseUrl: 'https://api.example.com', // Replace with actual API URL
      apiClient: apiClient,
      localStorage: localStorage,
    );

    return {
      rewards: (context) => RewardsScreen(rewardsRepo: rewardsRepo),
      achievements: (context) => RewardsScreen(rewardsRepo: rewardsRepo),
      challenges: (context) => RewardsScreen(rewardsRepo: rewardsRepo),
      leaderboard: (context) {
        // This could be a leaderboard screen
        return const Scaffold(
          body: Center(
            child: Text('Leaderboard - Full screen implementation needed'),
          ),
        );
      },
    };
  }
}
