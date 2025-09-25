import 'package:auth_repo/auth_repo.dart';
import 'package:profile_repo/profile_repo.dart';
import 'package:driver/routes/route_constants.dart';

/// Service responsible for managing the complete driver lifecycle route flow
/// This service handles the proper sequencing of onboarding and main app routes
class RouteFlowService {
  /// Determines the complete route flow after OTP verification
  /// Implements the exact logic specified:
  /// if (!isLoggedIn) -> LoginScreen
  /// else {
  ///   if (driverExists) {
  ///     if (documentsVerified) -> DashboardScreen
  ///     else if (documentsPending) -> DocumentPendingScreen  
  ///     else -> DocumentUploadScreen
  ///   } else {
  ///     -> OnboardingFlow (profile → language → vehicle → work area → documents)
  ///   }
  /// }
  static Future<RouteDecision> determineInitialRoute({
    required AuthUser user,
    required ProfileRepo profileRepo,
  }) async {
    try {
      // Check if driver exists in the system
      final statusResponse = await profileRepo.checkDriverStatus(user.phone);
      
      if (!statusResponse.success) {
        // Driver doesn't exist - start onboarding flow
        return RouteDecision(
          route: RouteConstants.profileCreation,
          reason: 'Driver not found, starting onboarding flow',
          arguments: {'user': user, 'isNewUser': true},
        );
      }

      // Driver exists - check document status
      switch (statusResponse.status) {
        case DriverStatus.newUser:
        case DriverStatus.profileIncomplete:
          // Driver exists but profile incomplete - continue onboarding
          return RouteDecision(
            route: RouteConstants.profileCreation,
            reason: 'Driver exists but profile incomplete, continuing onboarding',
            arguments: {
              'user': user,
              'isNewUser': false,
              'profile': statusResponse.profile,
              'missingRequirements': statusResponse.missingRequirements,
            },
          );

        case DriverStatus.documentsPending:
          // Documents uploaded but pending verification
          return RouteDecision(
            route: '/document-pending', // Custom route for pending screen
            reason: 'Documents pending verification - show pending screen',
            arguments: {
              'user': user,
              'profile': statusResponse.profile,
              'missingRequirements': statusResponse.missingRequirements,
            },
          );

        case DriverStatus.documentsRejected:
          // Documents rejected - need to re-upload
          return RouteDecision(
            route: RouteConstants.documentUpload,
            reason: 'Documents rejected, need resubmission',
            arguments: {
              'user': user,
              'profile': statusResponse.profile,
              'missingRequirements': statusResponse.missingRequirements,
              'isResubmission': true,
            },
          );

        case DriverStatus.verified:
          // Documents verified - go to dashboard
          return RouteDecision(
            route: RouteConstants.dashboard,
            reason: 'Driver verified and ready to work',
            arguments: {
              'user': user,
              'profile': statusResponse.profile,
            },
          );

        case DriverStatus.suspended:
          // Account suspended
          return RouteDecision(
            route: RouteConstants.accountSuspended,
            reason: 'Account suspended',
            arguments: {
              'user': user,
              'profile': statusResponse.profile,
              'reason': statusResponse.message ?? 'Account suspended',
            },
          );

        case DriverStatus.inactive:
          // Account inactive
          return RouteDecision(
            route: RouteConstants.accountInactive,
            reason: 'Account inactive',
            arguments: {
              'user': user,
              'profile': statusResponse.profile,
              'reason': statusResponse.message ?? 'Account inactive',
            },
          );

        default:
          // Unknown status - default to onboarding
          return RouteDecision(
            route: RouteConstants.profileCreation,
            reason: 'Unknown status, starting onboarding',
            arguments: {'user': user, 'isNewUser': true},
          );
      }
    } catch (e) {
      // On error, default to onboarding flow
      return RouteDecision(
        route: RouteConstants.profileCreation,
        reason: 'Error checking status, starting onboarding: ${e.toString()}',
        arguments: {'user': user, 'isNewUser': true},
      );
    }
  }

  /// Gets the next step in the onboarding flow
  static RouteDecision getNextOnboardingStep({
    required String currentStep,
    required List<String> completedSteps,
    required List<String> missingRequirements,
  }) {
    // Define the onboarding flow order
    const onboardingFlow = [
      RouteConstants.profileCreation,
      RouteConstants.languageSelection,
      RouteConstants.vehicleSelection,
      RouteConstants.workLocation,
      RouteConstants.documentUpload,
    ];

    // Find current step index
    final currentIndex = onboardingFlow.indexOf(currentStep);
    if (currentIndex == -1) {
      // If current step not found, start from beginning
      return RouteDecision(
        route: RouteConstants.profileCreation,
        reason: 'Current step not found, starting from beginning',
      );
    }

    // Check if there are more steps
    if (currentIndex + 1 < onboardingFlow.length) {
      final nextStep = onboardingFlow[currentIndex + 1];
      
      // Check if next step is required based on missing requirements
      if (_isStepRequired(nextStep, missingRequirements)) {
        return RouteDecision(
          route: nextStep,
          reason: 'Continuing onboarding flow',
        );
      } else {
        // Skip this step and try next
        return getNextOnboardingStep(
          currentStep: nextStep,
          completedSteps: completedSteps,
          missingRequirements: missingRequirements,
        );
      }
    } else {
      // Onboarding complete, go to dashboard
      return RouteDecision(
        route: RouteConstants.dashboard,
        reason: 'Onboarding completed',
      );
    }
  }

  /// Checks if a step is required based on missing requirements
  static bool _isStepRequired(String step, List<String> missingRequirements) {
    switch (step) {
      case RouteConstants.profileCreation:
        return missingRequirements.any((req) => 
          req.contains('profile') || req.contains('name') || req.contains('photo'));
      
      case RouteConstants.languageSelection:
        return missingRequirements.any((req) => req.contains('language'));
      
      case RouteConstants.vehicleSelection:
        return missingRequirements.any((req) => req.contains('vehicle'));
      
      case RouteConstants.workLocation:
        return missingRequirements.any((req) => 
          req.contains('location') || req.contains('work area'));
      
      case RouteConstants.documentUpload:
        return missingRequirements.any((req) => 
          req.contains('document') || req.contains('license') || 
          req.contains('rc') || req.contains('aadhaar'));
      
      default:
        return true;
    }
  }

  /// Gets the onboarding flow progress percentage
  static double getOnboardingProgress(List<String> completedSteps) {
    const totalSteps = 5; // profile, language, vehicle, work location, documents
    return (completedSteps.length / totalSteps).clamp(0.0, 1.0);
  }

  /// Gets the next step display name
  static String getStepDisplayName(String step) {
    switch (step) {
      case RouteConstants.profileCreation:
        return 'Profile Setup';
      case RouteConstants.languageSelection:
        return 'Language Selection';
      case RouteConstants.vehicleSelection:
        return 'Vehicle Selection';
      case RouteConstants.workLocation:
        return 'Work Area';
      case RouteConstants.documentUpload:
        return 'Document Upload';
      case RouteConstants.dashboard:
        return 'Dashboard';
      default:
        return 'Unknown Step';
    }
  }

  /// Gets the step description
  static String getStepDescription(String step) {
    switch (step) {
      case RouteConstants.profileCreation:
        return 'Set up your profile information';
      case RouteConstants.languageSelection:
        return 'Choose your preferred language';
      case RouteConstants.vehicleSelection:
        return 'Select your assigned vehicle';
      case RouteConstants.workLocation:
        return 'Choose your work area';
      case RouteConstants.documentUpload:
        return 'Upload required documents';
      case RouteConstants.dashboard:
        return 'Start accepting rides';
      default:
        return 'Complete this step to continue';
    }
  }
}

/// Model representing a route decision
class RouteDecision {
  final String route;
  final String reason;
  final Map<String, dynamic> arguments;

  const RouteDecision({
    required this.route,
    required this.reason,
    this.arguments = const {},
  });

  @override
  String toString() {
    return 'RouteDecision(route: $route, reason: $reason, arguments: $arguments)';
  }
}
