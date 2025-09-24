import 'package:flutter/material.dart';
import 'package:rewards_repo/rewards_repo.dart';
import 'package:localstorage/localstorage.dart';
import 'package:api_client/api_client.dart';
import '../views/rewards_screen.dart';

/// Example showing how to navigate to the Rewards screen
class RewardsNavigationExample extends StatelessWidget {
  const RewardsNavigationExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Rewards System Navigation Example',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _navigateToRewards(context),
              child: const Text('Open Rewards Dashboard'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _navigateToRewardsWithRoute(context),
              child: const Text('Open Rewards via Route'),
            ),
          ],
        ),
      ),
    );
  }

  /// Method 1: Direct navigation with dependency injection
  void _navigateToRewards(BuildContext context) {
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

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RewardsScreen(rewardsRepo: rewardsRepo),
      ),
    );
  }

  /// Method 2: Navigation using named routes
  void _navigateToRewardsWithRoute(BuildContext context) {
    Navigator.of(context).pushNamed('/rewards');
  }
}

/// Example widget showing how to integrate rewards into an existing screen
class RewardsIntegrationExample extends StatelessWidget {
  const RewardsIntegrationExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Dashboard'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Driver Dashboard',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          // Rewards Card
          Card(
            child: ListTile(
              leading: const Icon(Icons.emoji_events_rounded),
              title: const Text('Rewards & Achievements'),
              subtitle: const Text('Track your progress and unlock rewards'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              onTap: () => _navigateToRewards(context),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Other dashboard options
          Card(
            child: ListTile(
              leading: const Icon(Icons.history_rounded),
              title: const Text('Trip History'),
              subtitle: const Text('View your completed trips'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              onTap: () {
                // Navigate to trip history
              },
            ),
          ),
          
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_rounded),
              title: const Text('Profile'),
              subtitle: const Text('Manage your profile information'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              onTap: () {
                // Navigate to profile
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToRewards(BuildContext context) {
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

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RewardsScreen(rewardsRepo: rewardsRepo),
      ),
    );
  }
}
