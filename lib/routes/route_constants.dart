/// Centralized route constants for the driver app
/// This file contains all route paths used throughout the application
class RouteConstants {
  // Authentication routes
  static const String login = '/';
  static const String otp = '/get-otp';

  // Main app routes
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String goOnline = '/go-online';
  static const String goOffline = '/go-offline';
  static const String workAreaSelection = '/work-area-selection';

  // Booking routes
  static const String incomingRideRequest = '/incoming-ride-request';
  static const String bookingDetails = '/booking-details';
  static const String bookingHistory = '/booking-history';

  // Trip routes
  static const String trip = '/trip';
  static const String startTrip = '/start-trip';
  static const String completeTrip = '/complete-trip';
  static const String cancelTrip = '/cancel-trip';
  static const String tripInProgress = '/trip-in-progress';
  static const String tripSummary = '/trip-summary';
  static const String fareBreakdown = '/fare-breakdown';

  // Profile routes
  static const String profileCreation = '/profile-creation';
  static const String languageSelection = '/language-selection';
  static const String vehicleSelection = '/vehicle-selection';
  static const String workLocation = '/work-location';
  static const String profile = '/profile';

  // Document routes
  static const String documentsList = '/documents-list';
  static const String documentDetail = '/document-detail';
  static const String accountDocuments = '/account/documents';
  static const String documentIntro = '/document-intro';
  static const String documentUpload = '/document-upload';
  static const String documentReview = '/document-review';

  // History routes
  static const String ridesHistory = '/rides-history';
  static const String tripHistory = '/trip-history';
  static const String ratings = '/ratings';

  // Finance routes
  static const String wallet = '/wallet';
  static const String earnings = '/earnings';
  static const String transactionHistory = '/transaction-history';
  static const String earningsSummary = '/earnings-summary';

  // Rewards routes
  static const String rewards = '/rewards';
  static const String achievements = '/achievements';
  static const String challenges = '/challenges';
  static const String leaderboard = '/leaderboard';

  // Settings routes
  static const String settings = '/settings';
  static const String privacy = '/privacy';
  static const String support = '/support';
  static const String about = '/about';
  static const String termsOfService = '/terms-of-service';
  static const String privacyPolicy = '/privacy-policy';

  // Notification routes
  static const String notificationSettings = '/notification-settings';
  static const String bookingNotifications = '/booking-notifications';
  static const String earningsNotifications = '/earnings-notifications';
  static const String systemNotifications = '/system-notifications';

  // Help support routes
  static const String helpSupport = '/help-support';
  static const String faq = '/faq';
  static const String contactUs = '/contact-us';
  static const String emergency = '/emergency';
}
