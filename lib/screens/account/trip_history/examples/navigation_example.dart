import 'package:flutter/material.dart';
import 'package:history_repo/history_repo.dart';
import 'package:localstorage/localstorage.dart';
import 'package:api_client/api_client.dart';
import '../views/trip_history_screen.dart';

/// Example showing how to navigate to the Trip History screen
class TripHistoryNavigationExample extends StatelessWidget {
  const TripHistoryNavigationExample({super.key});

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
              'Trip History Navigation Example',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _navigateToTripHistory(context),
              child: const Text('Open Trip History'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _navigateToTripHistoryWithRoute(context),
              child: const Text('Open Trip History via Route'),
            ),
          ],
        ),
      ),
    );
  }

  /// Method 1: Direct navigation with dependency injection
  void _navigateToTripHistory(BuildContext context) {
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

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TripHistoryScreen(historyRepo: historyRepo),
      ),
    );
  }

  /// Method 2: Navigation using named routes
  void _navigateToTripHistoryWithRoute(BuildContext context) {
    Navigator.of(context).pushNamed('/trip-history');
  }
}

/// Example widget showing how to integrate trip history into an existing screen
class TripHistoryIntegrationExample extends StatelessWidget {
  const TripHistoryIntegrationExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Dashboard'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Account Dashboard',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          // Trip History Card
          Card(
            child: ListTile(
              leading: const Icon(Icons.history_rounded),
              title: const Text('Trip History'),
              subtitle: const Text('View your completed trips and earnings'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              onTap: () => _navigateToTripHistory(context),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Other account options
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
          
          Card(
            child: ListTile(
              leading: const Icon(Icons.settings_rounded),
              title: const Text('Settings'),
              subtitle: const Text('App preferences and configuration'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              onTap: () {
                // Navigate to settings
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToTripHistory(BuildContext context) {
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

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TripHistoryScreen(historyRepo: historyRepo),
      ),
    );
  }
}
