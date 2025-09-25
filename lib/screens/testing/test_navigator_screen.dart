import 'package:flutter/material.dart';
import 'package:driver/widgets/colors.dart';
import 'package:driver/services/testing_navigator_service.dart';

/// Screen for testing all app screens during development
/// This screen provides navigation to all screens for testing purposes
class TestNavigatorScreen extends StatelessWidget {
  const TestNavigatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screens = TestingNavigatorService.getTestScreens();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Test Navigator'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showTestingInfo(context),
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          // Testing mode banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.warning.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.bug_report,
                  color: AppColors.warning,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Testing Mode Active - This screen is for development only',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Screen list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: screens.length,
              itemBuilder: (context, index) {
                final screenName = screens.keys.elementAt(index);
                final screenWidget = screens.values.elementAt(index);
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getScreenIcon(screenName),
                        color: AppColors.cyan,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      screenName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      _getScreenDescription(screenName),
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.textTertiary,
                      size: 16,
                    ),
                    onTap: () {
                      _navigateToScreen(context, screenName, screenWidget);
                    },
                  ),
                );
              },
            ),
          ),
          
          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.science,
                  color: AppColors.textTertiary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '${screens.length} screens available for testing',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Get appropriate icon for each screen
  IconData _getScreenIcon(String screenName) {
    switch (screenName) {
      case 'Dashboard':
        return Icons.dashboard;
      case 'Profile Setup':
        return Icons.person;
      case 'Language Selection':
        return Icons.language;
      case 'Vehicle Selection':
        return Icons.directions_car;
      case 'Work Location':
        return Icons.location_on;
      case 'Document Upload':
        return Icons.upload_file;
      case 'Document Pending':
        return Icons.hourglass_empty;
      case 'Incoming Ride Request':
        return Icons.notifications_active;
      case 'Ride Detail':
        return Icons.details;
      case 'Navigation Screen':
        return Icons.navigation;
      case 'Trip Progress':
        return Icons.timeline;
      case 'Fare Breakdown':
        return Icons.attach_money;
      case 'Account Suspended':
        return Icons.block;
      case 'Account Inactive':
        return Icons.pause_circle_outline;
      default:
        return Icons.screen_share;
    }
  }

  /// Get description for each screen
  String _getScreenDescription(String screenName) {
    switch (screenName) {
      case 'Dashboard':
        return 'Main driver dashboard with online/offline toggle';
      case 'Profile Setup':
        return 'Driver profile creation and setup';
      case 'Language Selection':
        return 'Choose preferred app language';
      case 'Vehicle Selection':
        return 'Select assigned vehicle';
      case 'Work Location':
        return 'Choose work area/city';
      case 'Document Upload':
        return 'Upload required documents (RC, License, etc.)';
      case 'Document Pending':
        return 'Documents under review status screen';
      case 'Incoming Ride Request':
        return 'Bottom sheet for incoming ride requests';
      case 'Ride Detail':
        return 'Detailed ride information screen';
      case 'Navigation Screen':
        return 'Navigation and trip progress screen';
      case 'Trip Progress':
        return 'Active trip progress tracking';
      case 'Fare Breakdown':
        return 'Trip fare calculation details';
      case 'Account Suspended':
        return 'Account suspended status screen';
      case 'Account Inactive':
        return 'Account inactive status screen';
      default:
        return 'Test screen for development';
    }
  }

  /// Navigate to the selected screen
  void _navigateToScreen(BuildContext context, String screenName, Widget screenWidget) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(screenName),
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          body: screenWidget,
        ),
      ),
    );
  }

  /// Show testing information dialog
  void _showTestingInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: AppColors.cyan,
            ),
            const SizedBox(width: 8),
            const Text('Testing Mode'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This screen is for development and testing purposes only.',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Features:',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildInfoItem('• Navigate to any screen instantly'),
            _buildInfoItem('• Test all UI components'),
            _buildInfoItem('• Preview different states'),
            _buildInfoItem('• No backend dependencies'),
            const SizedBox(height: 16),
            Text(
              'Note: Some screens may show mock data or require additional setup for full functionality.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it',
              style: TextStyle(
                color: AppColors.cyan,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build info item
  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
      ),
    );
  }
}
