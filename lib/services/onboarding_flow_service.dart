import 'package:flutter/material.dart';
import 'package:auth_repo/auth_repo.dart';
import 'package:profile_repo/profile_repo.dart';
import 'package:driver/routes/auth_routes.dart';
import 'package:driver/routes/main_routes.dart';
import 'package:driver/services/route_flow_service.dart';

/// Service responsible for managing the onboarding flow navigation
/// This service handles the sequential navigation through onboarding steps
class OnboardingFlowService {
  /// Navigate to the next step in the onboarding flow
  static Future<void> navigateToNextStep({
    required BuildContext context,
    required String currentStep,
    required AuthUser user,
    required ProfileRepo profileRepo,
    Map<String, dynamic>? currentArguments,
  }) async {
    try {
      // Get the next step in the flow
      final routeDecision = RouteFlowService.getNextOnboardingStep(
        currentStep: currentStep,
        completedSteps: _getCompletedSteps(currentArguments),
        missingRequirements: currentArguments?['missingRequirements'] ?? [],
      );

      // Navigate to the next step
      if (routeDecision.route == RouteConstants.dashboard) {
        // Onboarding complete, go to dashboard
        Navigator.pushReplacementNamed(
          context,
          MainRoutes.dashboard,
          arguments: {
            'user': user,
            'profile': currentArguments?['profile'],
          },
        );
      } else {
        // Continue onboarding
        Navigator.pushReplacementNamed(
          context,
          routeDecision.route,
          arguments: {
            'user': user,
            'profile': currentArguments?['profile'],
            'isNewUser': currentArguments?['isNewUser'] ?? true,
            'missingRequirements': currentArguments?['missingRequirements'] ?? [],
            ...routeDecision.arguments,
          },
        );
      }
    } catch (e) {
      // On error, go to dashboard as fallback
      Navigator.pushReplacementNamed(
        context,
        MainRoutes.dashboard,
        arguments: {'user': user},
      );
    }
  }

  /// Navigate back to the previous step in onboarding
  static void navigateToPreviousStep({
    required BuildContext context,
    required String currentStep,
    required AuthUser user,
    Map<String, dynamic>? currentArguments,
  }) {
    final previousStep = _getPreviousStep(currentStep);
    
    if (previousStep != null) {
      Navigator.pushReplacementNamed(
        context,
        previousStep,
        arguments: {
          'user': user,
          'profile': currentArguments?['profile'],
          'isNewUser': currentArguments?['isNewUser'] ?? true,
          'missingRequirements': currentArguments?['missingRequirements'] ?? [],
        },
      );
    } else {
      // If no previous step, go back to login
      Navigator.pushReplacementNamed(context, AuthRoutes.login);
    }
  }

  /// Skip onboarding and go directly to dashboard (for testing)
  static void skipOnboarding({
    required BuildContext context,
    required AuthUser user,
    Map<String, dynamic>? currentArguments,
  }) {
    Navigator.pushReplacementNamed(
      context,
      MainRoutes.dashboard,
      arguments: {
        'user': user,
        'profile': currentArguments?['profile'],
      },
    );
  }

  /// Get the onboarding flow progress
  static double getProgress(String currentStep, Map<String, dynamic>? arguments) {
    const steps = [
      RouteConstants.profileCreation,
      RouteConstants.languageSelection,
      RouteConstants.vehicleSelection,
      RouteConstants.workLocation,
      RouteConstants.documentUpload,
    ];

    final currentIndex = steps.indexOf(currentStep);
    if (currentIndex == -1) return 0.0;

    return (currentIndex + 1) / steps.length;
  }

  /// Get the step number for display
  static int getStepNumber(String currentStep) {
    const steps = [
      RouteConstants.profileCreation,
      RouteConstants.languageSelection,
      RouteConstants.vehicleSelection,
      RouteConstants.workLocation,
      RouteConstants.documentUpload,
    ];

    final index = steps.indexOf(currentStep);
    return index == -1 ? 1 : index + 1;
  }

  /// Get total number of steps
  static int getTotalSteps() {
    return 5; // profile, language, vehicle, work location, documents
  }

  /// Get completed steps from arguments
  static List<String> _getCompletedSteps(Map<String, dynamic>? arguments) {
    // This would be populated based on the current arguments
    // For now, return empty list as we don't track completed steps yet
    return [];
  }

  /// Get the previous step in the flow
  static String? _getPreviousStep(String currentStep) {
    const steps = [
      RouteConstants.profileCreation,
      RouteConstants.languageSelection,
      RouteConstants.vehicleSelection,
      RouteConstants.workLocation,
      RouteConstants.documentUpload,
    ];

    final currentIndex = steps.indexOf(currentStep);
    if (currentIndex <= 0) return null;

    return steps[currentIndex - 1];
  }

  /// Check if current step is the first step
  static bool isFirstStep(String currentStep) {
    return currentStep == RouteConstants.profileCreation;
  }

  /// Check if current step is the last step
  static bool isLastStep(String currentStep) {
    return currentStep == RouteConstants.documentUpload;
  }

  /// Get step title for display
  static String getStepTitle(String currentStep) {
    switch (currentStep) {
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
      default:
        return 'Onboarding';
    }
  }

  /// Get step description
  static String getStepDescription(String currentStep) {
    switch (currentStep) {
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
      default:
        return 'Complete this step to continue';
    }
  }
}
