enum NotificationType {
  // Ride related
  newRideRequest,     // New ride request received
  rideAccepted,       // Ride accepted by driver
  rideStarted,        // Ride started
  rideCompleted,      // Ride completed
  rideCancelled,      // Ride cancelled
  rideScheduled,      // Ride scheduled for future

  // Payment related
  paymentReceived,    // Payment received for ride
  paymentFailed,      // Payment failed
  walletUpdated,      // Wallet balance updated
  withdrawalSuccess,  // Money withdrawal successful
  withdrawalFailed,   // Money withdrawal failed

  // Document related
  documentExpired,    // Document expiry warning
  documentApproved,   // Document approved
  documentRejected,   // Document rejected
  documentRequired,   // New document required

  // Earnings related
  dailyEarnings,      // Daily earnings summary
  weeklyEarnings,     // Weekly earnings summary
  bonusEarned,        // Bonus earned
  incentiveEarned,    // Incentive earned

  // Promotional
  promotion,          // Promotional offers
  referralBonus,      // Referral bonus earned
  specialOffer,       // Special offers

  // System
  systemUpdate,       // System updates
  maintenance,        // Maintenance notifications
  emergency,          // Emergency alerts
  safetyAlert,        // Safety alerts
  offlineWarning,     // Offline warning
  onlineReminder,     // Online reminder
}
