import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/booking_location.dart';
import '../utils/result.dart';

/// Centralized navigation coordinator for the booking flow.
/// 
/// Handles all navigation between booking flow screens with consistent
/// animations, data passing, and state management.
class BookingFlowCoordinator {
  /// Navigate to pickup location with turn-by-turn navigation
  static Future<void> navigateToPickup(
    BuildContext context,
    Booking booking,
  ) async {
    await Navigator.pushNamed(
      context,
      BookingFlowRoutes.navigation,
      arguments: NavigationScreenArguments(
        booking: booking,
        phase: NavigationPhase.pickup,
      ),
    );
  }

  /// Navigate to dropoff location with turn-by-turn navigation
  static Future<void> navigateToDropoff(
    BuildContext context,
    Booking booking,
  ) async {
    await Navigator.pushNamed(
      context,
      BookingFlowRoutes.navigation,
      arguments: NavigationScreenArguments(
        booking: booking,
        phase: NavigationPhase.dropoff,
      ),
    );
  }

  /// Show ride completion screen with trip summary
  static Future<TripRating?> showRideComplete(
    BuildContext context,
    TripSummary summary,
  ) async {
    final result = await Navigator.pushNamed(
      context,
      BookingFlowRoutes.tripComplete,
      arguments: summary,
    );
    
    return result as TripRating?;
  }

  /// Show incoming ride request sheet
  static Future<BookingAction?> showRideRequest(
    BuildContext context,
    BookingRequest request,
  ) async {
    final result = await showModalBottomSheet<BookingAction>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      builder: (context) => IncomingRideRequestSheet(request: request),
    );

    return result;
  }

  /// Show trip progress screen
  static Future<void> showTripProgress(
    BuildContext context,
    Booking booking,
  ) async {
    await Navigator.pushNamed(
      context,
      BookingFlowRoutes.tripProgress,
      arguments: booking,
    );
  }

  /// Show driver dashboard
  static Future<void> showDashboard(BuildContext context) async {
    await Navigator.pushReplacementNamed(
      context,
      BookingFlowRoutes.dashboard,
    );
  }

  /// Show work area selection
  static Future<WorkArea?> showWorkAreaSelection(BuildContext context) async {
    final result = await Navigator.pushNamed(
      context,
      BookingFlowRoutes.workAreaSelection,
    );
    
    return result as WorkArea?;
  }

  /// Show customer contact options
  static Future<ContactAction?> showContactOptions(
    BuildContext context,
    CustomerInfo customer,
  ) async {
    final result = await showModalBottomSheet<ContactAction>(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CustomerContactSheet(customer: customer),
    );

    return result;
  }

  /// Show trip cancellation confirmation
  static Future<bool> showCancellationConfirmation(
    BuildContext context,
    String reason,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => TripCancellationDialog(reason: reason),
    );

    return result ?? false;
  }

  /// Show error dialog with retry option
  static Future<bool> showErrorDialog(
    BuildContext context,
    AppError error, {
    bool showRetry = true,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ErrorDialog(
        error: error,
        showRetry: showRetry,
      ),
    );

    return result ?? false;
  }

  /// Navigate back to driver map
  static void goBackToMap(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      BookingFlowRoutes.driverMap,
      (route) => false,
    );
  }

  /// Show loading dialog
  static void showLoading(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingDialog(message: message),
    );
  }

  /// Hide loading dialog
  static void hideLoading(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Open external navigation app (Google Maps, etc.)
  static Future<bool> openExternalNavigation(
    BuildContext context,
    BookingLocation destination,
  ) async {
    try {
      final url = _buildNavigationUrl(destination);
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Build navigation URL for external apps
  static String _buildNavigationUrl(BookingLocation destination) {
    final lat = destination.latitude;
    final lng = destination.longitude;
    final address = Uri.encodeComponent(destination.address);
    
    // Google Maps URL
    return 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&destination_place_id=$address';
  }
}

/// Route names for booking flow
class BookingFlowRoutes {
  static const String dashboard = '/dashboard';
  static const String driverMap = '/driver-map';
  static const String navigation = '/navigation';
  static const String tripProgress = '/trip-progress';
  static const String tripComplete = '/trip-complete';
  static const String workAreaSelection = '/work-area-selection';
}

/// Arguments for navigation screen
class NavigationScreenArguments {
  const NavigationScreenArguments({
    required this.booking,
    required this.phase,
  });

  final Booking booking;
  final NavigationPhase phase;
}

/// Navigation phases
enum NavigationPhase {
  pickup,
  dropoff,
}

/// Booking actions
enum BookingAction {
  accept,
  reject,
  timeout,
}

/// Contact actions
enum ContactAction {
  call,
  message,
  cancel,
}

/// Trip summary data
class TripSummary {
  const TripSummary({
    required this.booking,
    required this.distanceTraveled,
    required this.duration,
    required this.fareBreakdown,
    required this.completedAt,
  });

  final Booking booking;
  final double distanceTraveled; // in kilometers
  final Duration duration;
  final FareBreakdown fareBreakdown;
  final DateTime completedAt;
}

/// Fare breakdown details
class FareBreakdown {
  const FareBreakdown({
    required this.baseFare,
    required this.distanceFare,
    required this.timeFare,
    required this.surge,
    required this.platformFee,
    required this.total,
  });

  final double baseFare;
  final double distanceFare;
  final double timeFare;
  final double surge;
  final double platformFee;
  final double total;

  double get driverEarnings => total - platformFee;
}

/// Trip rating data
class TripRating {
  const TripRating({
    required this.rating,
    this.feedback,
    this.tags,
  });

  final int rating; // 1-5 stars
  final String? feedback;
  final List<String>? tags;
}

/// Customer information for contact
class CustomerInfo {
  const CustomerInfo({
    required this.name,
    required this.phone,
    this.profilePicture,
    this.notes,
  });

  final String name;
  final String phone;
  final String? profilePicture;
  final String? notes;
}

/// Work area information
class WorkArea {
  const WorkArea({
    required this.id,
    required this.name,
    required this.boundaries,
    required this.center,
  });

  final String id;
  final String name;
  final List<LatLng> boundaries;
  final LatLng center;
}

/// Booking request from real-time manager
class BookingRequest {
  const BookingRequest({
    required this.id,
    required this.customerId,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.estimatedFare,
    required this.estimatedDistance,
    required this.customerName,
    this.customerPhone,
    this.notes,
    this.expiresAt,
  });

  final String id;
  final String customerId;
  final BookingLocation pickupLocation;
  final BookingLocation dropoffLocation;
  final double estimatedFare;
  final double estimatedDistance;
  final String customerName;
  final String? customerPhone;
  final String? notes;
  final DateTime? expiresAt;
}

/// Mock booking class - should be replaced with actual model
class Booking {
  const Booking({
    required this.id,
    required this.customerId,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String customerId;
  final BookingLocation pickupLocation;
  final BookingLocation dropoffLocation;
  final BookingStatus status;
  final DateTime createdAt;
}

/// Booking status
enum BookingStatus {
  pending,
  accepted,
  enRouteToPickup,
  arrivedAtPickup,
  inProgress,
  completed,
  cancelled,
}

// Mock widgets - these should be implemented
class IncomingRideRequestSheet extends StatelessWidget {
  const IncomingRideRequestSheet({super.key, required this.request});
  
  final BookingRequest request;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'New Ride Request',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text('From: ${request.pickupLocation.address}'),
          Text('To: ${request.dropoffLocation.address}'),
          Text('Fare: \$${request.estimatedFare.toStringAsFixed(2)}'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Decline'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Accept'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomerContactSheet extends StatelessWidget {
  const CustomerContactSheet({super.key, required this.customer});
  
  final CustomerInfo customer;

  @override
  Widget build(BuildContext context) {
    return Container(); // TODO: Implement
  }
}

class TripCancellationDialog extends StatelessWidget {
  const TripCancellationDialog({super.key, required this.reason});
  
  final String reason;

  @override
  Widget build(BuildContext context) {
    return Container(); // TODO: Implement
  }
}

class ErrorDialog extends StatelessWidget {
  const ErrorDialog({
    super.key,
    required this.error,
    required this.showRetry,
  });
  
  final AppError error;
  final bool showRetry;

  @override
  Widget build(BuildContext context) {
    return Container(); // TODO: Implement
  }
}

class LoadingDialog extends StatelessWidget {
  const LoadingDialog({super.key, required this.message});
  
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(); // TODO: Implement
  }
}