import 'package:flutter/material.dart';
import '../views/help_support_screen.dart';

/// Example showing how to navigate to the Help & Support screen
class HelpSupportNavigationExample extends StatelessWidget {
  const HelpSupportNavigationExample({super.key});

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
              'Help & Support Navigation Example',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _navigateToHelpSupport(context),
              child: const Text('Open Help & Support'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _navigateToHelpSupportWithRoute(context),
              child: const Text('Open Help & Support via Route'),
            ),
          ],
        ),
      ),
    );
  }

  /// Method 1: Direct navigation
  void _navigateToHelpSupport(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const HelpSupportScreen(),
      ),
    );
  }

  /// Method 2: Navigation using named routes
  void _navigateToHelpSupportWithRoute(BuildContext context) {
    Navigator.of(context).pushNamed('/help-support');
  }
}

/// Example widget showing how to integrate help support into an existing screen
class HelpSupportIntegrationExample extends StatelessWidget {
  const HelpSupportIntegrationExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Settings',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          // Help & Support Card
          Card(
            child: ListTile(
              leading: const Icon(Icons.help_rounded),
              title: const Text('Help & Support'),
              subtitle: const Text('Get help and contact support'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              onTap: () => _navigateToHelpSupport(context),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Other settings options
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
              leading: const Icon(Icons.notifications_rounded),
              title: const Text('Notifications'),
              subtitle: const Text('Manage notification preferences'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              onTap: () {
                // Navigate to notifications
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToHelpSupport(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const HelpSupportScreen(),
      ),
    );
  }
}
