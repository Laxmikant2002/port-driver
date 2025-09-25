import 'package:flutter/material.dart';
import 'package:driver/screens/booking_flow/Driver_Status/view/dashboard_screen.dart';
import 'package:driver/screens/booking_flow/Ride_Progress/view/incoming_ride_request_sheet.dart';
import 'package:driver/screens/booking_flow/Ride_Progress/view/ride_detail_screen.dart';
import 'package:driver/screens/booking_flow/Ride_Progress/view/navigation_screen.dart';
import 'package:driver/screens/document_upload/views/document_upload_screen.dart';
import 'package:driver/screens/auth/profile/view/profile_screen.dart';
import 'package:driver/screens/auth/language_selection/view/language_selection_screen.dart';
import 'package:driver/screens/auth/vehicle_selection/view/vehicle_screen.dart';
import 'package:driver/screens/auth/work_location/view/work_screen.dart';
import 'package:driver/widgets/colors.dart';
import 'package:auth_repo/auth_repo.dart';
import 'package:profile_repo/profile_repo.dart';
import 'package:booking_repo/booking_repo.dart';
import 'package:driver/models/document_upload.dart';

/// Service for testing and development navigation
/// Provides access to all screens for testing purposes
class TestingNavigatorService {
  /// Check if testing mode is enabled
  static bool get isTestingMode {
    // In production, this would check build flags or environment variables
    // For now, we'll use a simple flag that can be toggled
    return true; // Change to false for production builds
  }

  /// Get all testable screens
  static Map<String, Widget> getTestScreens() {
    return {
      'Dashboard': const DashboardScreen(),
      'Profile Setup': _buildTestProfileScreen(),
      'Language Selection': _buildTestLanguageScreen(),
      'Vehicle Selection': _buildTestVehicleScreen(),
      'Work Location': _buildTestWorkLocationScreen(),
      'Document Upload': _buildTestDocumentUploadScreen(),
      'Document Pending': _buildDocumentPendingScreen(),
      'Incoming Ride Request': _buildTestIncomingRideRequest(),
      'Ride Detail': _buildTestRideDetailScreen(),
      'Navigation Screen': const NavigationScreen(),
      'Trip Progress': _buildTestTripProgressScreen(),
      'Fare Breakdown': _buildFareBreakdownScreen(),
      'Account Suspended': _buildAccountSuspendedScreen(),
      'Account Inactive': _buildAccountInactiveScreen(),
    };
  }

  /// Build test profile screen with mock data
  static Widget _buildTestProfileScreen() {
    final mockUser = const AuthUser(
      id: 'test_user_123',
      phone: '+919876543210',
      isNewUser: true,
    );
    
    return BlocProvider(
      create: (context) => ProfileBloc(
        authRepo: _getMockAuthRepo(),
        profileRepo: _getMockProfileRepo(),
        user: mockUser,
        isNewUser: true,
      )..add(const ProfileInitialized()),
      child: const ProfileScreen(),
    );
  }

  /// Build test language selection screen
  static Widget _buildTestLanguageScreen() {
    final mockUser = const AuthUser(
      id: 'test_user_123',
      phone: '+919876543210',
    );
    
    return BlocProvider(
      create: (context) => LanguageSelectionBloc(
        authRepo: _getMockAuthRepo(),
        profileRepo: _getMockProfileRepo(),
        user: mockUser,
      ),
      child: const LanguageSelectionScreen(),
    );
  }

  /// Build test vehicle selection screen
  static Widget _buildTestVehicleScreen() {
    final mockUser = const AuthUser(
      id: 'test_user_123',
      phone: '+919876543210',
    );
    
    return BlocProvider(
      create: (context) => VehicleBloc(
        authRepo: _getMockAuthRepo(),
        profileRepo: _getMockProfileRepo(),
        user: mockUser,
      ),
      child: const VehicleScreen(),
    );
  }

  /// Build test work location screen
  static Widget _buildTestWorkLocationScreen() {
    final mockUser = const AuthUser(
      id: 'test_user_123',
      phone: '+919876543210',
    );
    
    return BlocProvider(
      create: (context) => WorkBloc(
        authRepo: _getMockAuthRepo(),
        profileRepo: _getMockProfileRepo(),
        user: mockUser,
      ),
      child: const WorkLocationPage(),
    );
  }

  /// Build test document upload screen
  static Widget _buildTestDocumentUploadScreen() {
    final mockUser = const AuthUser(
      id: 'test_user_123',
      phone: '+919876543210',
    );
    
    return BlocProvider(
      create: (context) => DocumentUploadBloc(
        documentsRepo: _getMockDocumentsRepo(),
      ),
      child: const DocumentUploadScreen(
        documentType: DocumentType.drivingLicense,
      ),
    );
  }

  /// Build document pending screen
  static Widget _buildDocumentPendingScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Documents Under Review'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.hourglass_empty,
                size: 64,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Documents Under Review',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Your documents are being verified by our team. This process usually takes 24-48 hours.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Text(
                    'You can still use the app in offline mode to:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildOfflineFeature('View your profile'),
                  _buildOfflineFeature('Check document status'),
                  _buildOfflineFeature('View app settings'),
                  _buildOfflineFeature('Contact support'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to dashboard in offline mode
                  Navigator.pushReplacementNamed(context, '/dashboard');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cyan,
                  foregroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Continue to Dashboard (Offline Mode)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build test incoming ride request
  static Widget _buildTestIncomingRideRequest() {
    // This would need a mock booking object
    return Scaffold(
      body: Container(
        color: Colors.black54,
        child: const Center(
          child: Text(
            'Incoming Ride Request Sheet\n(Requires mock booking data)',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  /// Build test ride detail screen
  static Widget _buildTestRideDetailScreen() {
    return Scaffold(
      body: Container(
        color: Colors.black54,
        child: const Center(
          child: Text(
            'Ride Detail Screen\n(Requires mock booking data)',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  /// Build test trip progress screen
  static Widget _buildTestTripProgressScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip in Progress'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
      ),
      body: const Center(
        child: Text(
          'Trip Progress Screen\n(Requires active trip data)',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// Build fare breakdown screen
  static Widget _buildFareBreakdownScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Fare Breakdown'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Trip Fare Breakdown',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildFareItem('Base Fare', '₹50.00'),
                  _buildFareItem('Distance (5.2 km)', '₹26.00'),
                  _buildFareItem('Time (15 min)', '₹15.00'),
                  _buildFareItem('Platform Fee', '₹5.00'),
                  const Divider(),
                  _buildFareItem('Total Fare', '₹96.00', isTotal: true),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build account suspended screen
  static Widget _buildAccountSuspendedScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Account Suspended'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.block,
                size: 64,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Account Suspended',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Your account has been suspended due to policy violations. Please contact support for assistance.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to support
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cyan,
                  foregroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Contact Support',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build account inactive screen
  static Widget _buildAccountInactiveScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Account Inactive'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.pause_circle_outline,
                size: 64,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Account Inactive',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Your account is currently inactive. Please reactivate your account to continue driving.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  // Reactivate account
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cyan,
                  foregroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Reactivate Account',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method to build fare items
  static Widget _buildFareItem(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: isTotal ? AppColors.success : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Helper method to build offline features
  static Widget _buildOfflineFeature(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: AppColors.success,
          ),
          const SizedBox(width: 12),
          Text(
            feature,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Mock repositories for testing
  static AuthRepo _getMockAuthRepo() {
    // Return mock auth repo for testing
    throw UnimplementedError('Mock AuthRepo not implemented');
  }

  static ProfileRepo _getMockProfileRepo() {
    // Return mock profile repo for testing
    throw UnimplementedError('Mock ProfileRepo not implemented');
  }

  static DocumentsRepo _getMockDocumentsRepo() {
    // Return mock documents repo for testing
    throw UnimplementedError('Mock DocumentsRepo not implemented');
  }
}
