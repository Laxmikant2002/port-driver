import 'package:auth_repo/auth_repo.dart';
import 'package:profile_repo/profile_repo.dart';
import 'package:driver/services/route_flow_service.dart';

/// Service that defines and manages the complete driver lifecycle
/// This service provides a clear overview of all possible driver states and routes
class DriverLifecycleService {
  /// Complete driver lifecycle flow definition
  static const Map<DriverStatus, DriverLifecycleStep> lifecycleFlow = {
    DriverStatus.newUser: DriverLifecycleStep(
      status: DriverStatus.newUser,
      route: '/profile-creation',
      description: 'New driver - needs complete onboarding',
      requiredSteps: [
        'Profile Setup',
        'Language Selection', 
        'Vehicle Selection',
        'Work Area Selection',
        'Document Upload',
      ],
      canReceiveRides: false,
    ),
    
    DriverStatus.profileIncomplete: DriverLifecycleStep(
      status: DriverStatus.profileIncomplete,
      route: '/profile-creation',
      description: 'Profile exists but incomplete - resume onboarding',
      requiredSteps: [
        'Complete Profile Setup',
        'Language Selection',
        'Vehicle Selection', 
        'Work Area Selection',
        'Document Upload',
      ],
      canReceiveRides: false,
    ),
    
    DriverStatus.documentsPending: DriverLifecycleStep(
      status: DriverStatus.documentsPending,
      route: '/document-upload',
      description: 'Documents uploaded - awaiting verification',
      requiredSteps: [
        'Wait for Document Verification',
      ],
      canReceiveRides: false,
      showOfflineMode: true,
    ),
    
    DriverStatus.documentsRejected: DriverLifecycleStep(
      status: DriverStatus.documentsRejected,
      route: '/document-upload',
      description: 'Documents rejected - needs resubmission',
      requiredSteps: [
        'Resubmit Documents',
      ],
      canReceiveRides: false,
    ),
    
    DriverStatus.verified: DriverLifecycleStep(
      status: DriverStatus.verified,
      route: '/dashboard',
      description: 'Fully verified - ready to work',
      requiredSteps: [],
      canReceiveRides: true,
      showOnlineOfflineToggle: true,
    ),
    
    DriverStatus.suspended: DriverLifecycleStep(
      status: DriverStatus.suspended,
      route: '/account-suspended',
      description: 'Account suspended - contact support',
      requiredSteps: [
        'Contact Support',
        'Resolve Suspension',
      ],
      canReceiveRides: false,
    ),
    
    DriverStatus.inactive: DriverLifecycleStep(
      status: DriverStatus.inactive,
      route: '/account-inactive',
      description: 'Account inactive - reactivate required',
      requiredSteps: [
        'Reactivate Account',
      ],
      canReceiveRides: false,
    ),
  };

  /// Get the lifecycle step for a given driver status
  static DriverLifecycleStep getLifecycleStep(DriverStatus status) {
    return lifecycleFlow[status] ?? lifecycleFlow[DriverStatus.newUser]!;
  }

  /// Get all possible routes for the driver lifecycle
  static List<String> getAllRoutes() {
    return [
      // Authentication Routes
      '/',
      '/get-otp',
      
      // Onboarding Routes
      '/profile-creation',
      '/language-selection',
      '/vehicle-selection',
      '/work-location',
      '/document-upload',
      
      // Main App Routes
      '/dashboard',
      '/work-area-selection',
      
      // Account Status Routes
      '/account-suspended',
      '/account-inactive',
      
      // Booking Flow Routes
      '/incoming-ride-request',
      '/booking-details',
      '/trip',
      '/trip-in-progress',
      '/trip-summary',
      
      // Other Routes
      '/wallet',
      '/earnings',
      '/settings',
      '/profile',
    ];
  }

  /// Get the next possible routes from a given status
  static List<String> getNextPossibleRoutes(DriverStatus status) {
    final step = getLifecycleStep(status);
    
    switch (status) {
      case DriverStatus.newUser:
        return ['/profile-creation'];
      case DriverStatus.profileIncomplete:
        return ['/profile-creation'];
      case DriverStatus.documentsPending:
        return ['/document-upload', '/dashboard']; // Can view dashboard in offline mode
      case DriverStatus.documentsRejected:
        return ['/document-upload'];
      case DriverStatus.verified:
        return ['/dashboard', '/work-area-selection'];
      case DriverStatus.suspended:
        return ['/account-suspended'];
      case DriverStatus.inactive:
        return ['/account-inactive'];
      default:
        return ['/profile-creation'];
    }
  }

  /// Check if a route is accessible from a given driver status
  static bool isRouteAccessible(String route, DriverStatus status) {
    final accessibleRoutes = getNextPossibleRoutes(status);
    return accessibleRoutes.contains(route);
  }

  /// Get the driver lifecycle summary
  static DriverLifecycleSummary getLifecycleSummary(DriverStatus status) {
    final step = getLifecycleStep(status);
    
    return DriverLifecycleSummary(
      currentStatus: status,
      currentStep: step,
      progress: _calculateProgress(status),
      nextSteps: step.requiredSteps,
      canReceiveRides: step.canReceiveRides,
      showOfflineMode: step.showOfflineMode ?? false,
      showOnlineOfflineToggle: step.showOnlineOfflineToggle ?? false,
    );
  }

  /// Calculate progress percentage for the driver lifecycle
  static double _calculateProgress(DriverStatus status) {
    switch (status) {
      case DriverStatus.newUser:
        return 0.0;
      case DriverStatus.profileIncomplete:
        return 0.2;
      case DriverStatus.documentsPending:
        return 0.8;
      case DriverStatus.documentsRejected:
        return 0.8;
      case DriverStatus.verified:
        return 1.0;
      case DriverStatus.suspended:
        return 0.0;
      case DriverStatus.inactive:
        return 0.0;
      default:
        return 0.0;
    }
  }
}

/// Model representing a step in the driver lifecycle
class DriverLifecycleStep {
  final DriverStatus status;
  final String route;
  final String description;
  final List<String> requiredSteps;
  final bool canReceiveRides;
  final bool? showOfflineMode;
  final bool? showOnlineOfflineToggle;

  const DriverLifecycleStep({
    required this.status,
    required this.route,
    required this.description,
    required this.requiredSteps,
    required this.canReceiveRides,
    this.showOfflineMode,
    this.showOnlineOfflineToggle,
  });
}

/// Model representing the complete driver lifecycle summary
class DriverLifecycleSummary {
  final DriverStatus currentStatus;
  final DriverLifecycleStep currentStep;
  final double progress;
  final List<String> nextSteps;
  final bool canReceiveRides;
  final bool showOfflineMode;
  final bool showOnlineOfflineToggle;

  const DriverLifecycleSummary({
    required this.currentStatus,
    required this.currentStep,
    required this.progress,
    required this.nextSteps,
    required this.canReceiveRides,
    required this.showOfflineMode,
    required this.showOnlineOfflineToggle,
  });

  /// Get progress as percentage string
  String get progressText => '${(progress * 100).toInt()}%';

  /// Get status display text
  String get statusText {
    switch (currentStatus) {
      case DriverStatus.newUser:
        return 'New Driver';
      case DriverStatus.profileIncomplete:
        return 'Profile Incomplete';
      case DriverStatus.documentsPending:
        return 'Documents Under Review';
      case DriverStatus.documentsRejected:
        return 'Documents Rejected';
      case DriverStatus.verified:
        return 'Verified Driver';
      case DriverStatus.suspended:
        return 'Account Suspended';
      case DriverStatus.inactive:
        return 'Account Inactive';
      default:
        return 'Unknown Status';
    }
  }

  /// Get status color for UI display
  String get statusColor {
    switch (currentStatus) {
      case DriverStatus.verified:
        return 'success';
      case DriverStatus.documentsPending:
        return 'warning';
      case DriverStatus.suspended:
      case DriverStatus.inactive:
        return 'error';
      default:
        return 'info';
    }
  }
}
