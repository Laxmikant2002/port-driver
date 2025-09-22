/// Enum representing different types of notifications
enum NotificationType {
  // Booking Related
  newRideRequest,
  bookingConfirmed,
  bookingCancelled,
  pickupReminder,
  
  // Document & Profile
  documentApproved,
  documentRejected,
  vehicleAssignmentChanged,
  
  // Finance
  paymentReceived,
  weeklyPayoutCredited,
  
  // System / General
  system,
  appUpdate,
  policyUpdate,
  workAreaUpdate,
  penaltyWarning,
  suspensionWarning,
  
  // Legacy types for backward compatibility
  ride,
  payment,
  promotion,
  emergency,
  maintenance,
  support,
}

extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      // Booking Related
      case NotificationType.newRideRequest:
        return 'New Ride Request';
      case NotificationType.bookingConfirmed:
        return 'Booking Confirmed';
      case NotificationType.bookingCancelled:
        return 'Booking Cancelled';
      case NotificationType.pickupReminder:
        return 'Pickup Reminder';
      
      // Document & Profile
      case NotificationType.documentApproved:
        return 'Document Approved';
      case NotificationType.documentRejected:
        return 'Document Rejected';
      case NotificationType.vehicleAssignmentChanged:
        return 'Vehicle Assignment Changed';
      
      // Finance
      case NotificationType.paymentReceived:
        return 'Payment Received';
      case NotificationType.weeklyPayoutCredited:
        return 'Weekly Payout Credited';
      
      // System / General
      case NotificationType.system:
        return 'System';
      case NotificationType.appUpdate:
        return 'App Update';
      case NotificationType.policyUpdate:
        return 'Policy Update';
      case NotificationType.workAreaUpdate:
        return 'Work Area Update';
      case NotificationType.penaltyWarning:
        return 'Penalty Warning';
      case NotificationType.suspensionWarning:
        return 'Suspension Warning';
      
      // Legacy types
      case NotificationType.ride:
        return 'Ride';
      case NotificationType.payment:
        return 'Payment';
      case NotificationType.promotion:
        return 'Promotion';
      case NotificationType.emergency:
        return 'Emergency';
      case NotificationType.maintenance:
        return 'Maintenance';
      case NotificationType.support:
        return 'Support';
    }
  }

  /// Whether this notification type should show a popup when received
  bool get shouldShowPopup {
    switch (this) {
      case NotificationType.newRideRequest:
      case NotificationType.bookingConfirmed:
      case NotificationType.bookingCancelled:
      case NotificationType.documentApproved:
      case NotificationType.documentRejected:
      case NotificationType.paymentReceived:
      case NotificationType.weeklyPayoutCredited:
      case NotificationType.penaltyWarning:
      case NotificationType.suspensionWarning:
      case NotificationType.emergency:
        return true;
      default:
        return false;
    }
  }

  /// Whether this notification type should play a sound
  bool get shouldPlaySound {
    switch (this) {
      case NotificationType.newRideRequest:
      case NotificationType.bookingConfirmed:
      case NotificationType.bookingCancelled:
      case NotificationType.pickupReminder:
      case NotificationType.paymentReceived:
      case NotificationType.weeklyPayoutCredited:
      case NotificationType.penaltyWarning:
      case NotificationType.suspensionWarning:
      case NotificationType.emergency:
        return true;
      default:
        return false;
    }
  }

  /// Whether this notification type should vibrate
  bool get shouldVibrate {
    switch (this) {
      case NotificationType.newRideRequest:
      case NotificationType.bookingConfirmed:
      case NotificationType.bookingCancelled:
      case NotificationType.pickupReminder:
      case NotificationType.emergency:
      case NotificationType.penaltyWarning:
      case NotificationType.suspensionWarning:
        return true;
      default:
        return false;
    }
  }

  /// Whether this notification type should show as a local notification
  bool get shouldShowLocalNotification {
    switch (this) {
      case NotificationType.pickupReminder:
        return true;
      default:
        return false;
    }
  }

  /// Get the appropriate icon for this notification type
  String get iconName {
    switch (this) {
      case NotificationType.newRideRequest:
        return 'ride_request';
      case NotificationType.bookingConfirmed:
        return 'booking_confirmed';
      case NotificationType.bookingCancelled:
        return 'booking_cancelled';
      case NotificationType.pickupReminder:
        return 'pickup_reminder';
      case NotificationType.documentApproved:
        return 'document_approved';
      case NotificationType.documentRejected:
        return 'document_rejected';
      case NotificationType.vehicleAssignmentChanged:
        return 'vehicle_assignment';
      case NotificationType.paymentReceived:
        return 'payment_received';
      case NotificationType.weeklyPayoutCredited:
        return 'payout_credited';
      case NotificationType.appUpdate:
        return 'app_update';
      case NotificationType.policyUpdate:
        return 'policy_update';
      case NotificationType.workAreaUpdate:
        return 'work_area_update';
      case NotificationType.penaltyWarning:
        return 'penalty_warning';
      case NotificationType.suspensionWarning:
        return 'suspension_warning';
      case NotificationType.emergency:
        return 'emergency';
      default:
        return 'notification';
    }
  }
}
