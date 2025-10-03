import 'package:flutter/material.dart';
import 'package:driver/widgets/colors.dart';

/// Service for managing developer mode and testing features
class DeveloperModeService {
  static bool _isDeveloperMode = false;
  static bool _isTestingMode = true; // Set to false for production builds

  /// Check if developer mode is enabled
  static bool get isDeveloperMode => _isDeveloperMode;

  /// Check if testing mode is enabled
  static bool get isTestingMode => _isTestingMode;

  /// Toggle developer mode
  static void toggleDeveloperMode() {
    _isDeveloperMode = !_isDeveloperMode;
  }

  /// Enable testing mode (for development builds)
  static void enableTestingMode() {
    _isTestingMode = true;
  }

  /// Disable testing mode (for production builds)
  static void disableTestingMode() {
    _isTestingMode = false;
  }

  /// Show developer mode toggle (long press gesture)
  static void showDeveloperModeToggle(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.developer_mode,
              color: AppColors.cyan,
            ),
            const SizedBox(width: 8),
            const Text('Developer Mode'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Developer mode is currently:',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _isDeveloperMode 
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isDeveloperMode 
                      ? AppColors.success
                      : AppColors.error,
                  width: 1,
                ),
              ),
              child: Text(
                _isDeveloperMode ? 'ENABLED' : 'DISABLED',
                style: TextStyle(
                  color: _isDeveloperMode 
                      ? AppColors.success
                      : AppColors.error,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (!_isDeveloperMode)
              Text(
                'Enable developer mode to access:',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (!_isDeveloperMode) ...[
              const SizedBox(height: 8),
              _buildFeatureItem('Test Navigator Screen'),
              _buildFeatureItem('All app screens for testing'),
              _buildFeatureItem('Mock data and states'),
              _buildFeatureItem('Development tools'),
            ],
            if (_isDeveloperMode)
              Text(
                'Developer mode provides access to testing screens and development tools.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textTertiary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              toggleDeveloperMode();
              Navigator.pop(context);
              _showDeveloperModeFeedback(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _isDeveloperMode ? AppColors.error : AppColors.success,
              foregroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              _isDeveloperMode ? 'Disable' : 'Enable',
            ),
          ),
        ],
      ),
    );
  }

  /// Show developer mode feedback
  static void _showDeveloperModeFeedback(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _isDeveloperMode ? Icons.check_circle : Icons.cancel,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _isDeveloperMode 
                  ? 'Developer mode enabled'
                  : 'Developer mode disabled',
            ),
          ],
        ),
        backgroundColor: _isDeveloperMode ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Build feature item for developer mode
  static Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: AppColors.success,
          ),
          const SizedBox(width: 8),
          Text(
            feature,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Add developer mode FAB to dashboard when enabled
  static Widget? getDeveloperModeFAB(BuildContext context) {
    // Test navigator removed for production - developer mode FAB disabled
    return null;
  }

  /// Add developer mode indicator to app bar
  static Widget? getDeveloperModeIndicator() {
    if (!isDeveloperMode) return null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warning,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.developer_mode,
            size: 14,
            color: AppColors.warning,
          ),
          const SizedBox(width: 4),
          Text(
            'DEV',
            style: TextStyle(
              color: AppColors.warning,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Handle long press gesture for developer mode toggle
  static void handleLongPress(BuildContext context) {
    // Only show developer mode toggle if testing mode is enabled
    if (isTestingMode) {
      showDeveloperModeToggle(context);
    }
  }

  /// Check if test navigator should be accessible
  static bool canAccessTestNavigator() {
    return isDeveloperMode && isTestingMode;
  }
}
