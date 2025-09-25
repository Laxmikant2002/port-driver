/// Dashboard screen constants and configurations
class DashboardConstants {
  // Text constants
  static const String appTitle = 'Driver Dashboard';
  static const String appSubtitle = 'Manage your availability and track your earnings';
  static const String todaysEarnings = 'Today\'s Earnings';
  static const String tripsToday = 'Trips Today';
  static const String workArea = 'Work Area';
  static const String notSet = 'Not set';
  static const String change = 'Change';
  static const String set = 'Set';
  static const String lastActive = 'Last active: Just now';
  static const String version = 'Version 1.0.0';
  
  // Error messages
  static const String defaultError = 'An error occurred';
  
  // Dialog constants
  static const String goOfflineTitle = 'Go Offline?';
  static const String goOfflineMessage = 'Are you sure you want to go offline? You won\'t receive new ride requests.';
  static const String cancel = 'Cancel';
  static const String goOffline = 'Go Offline';
  
  // Layout constants
  static const double defaultPadding = 24.0;
  static const double cardPadding = 20.0;
  static const double borderRadius = 20.0;
  static const double cardBorderRadius = 24.0;
  static const double dialogBorderRadius = 16.0;
  static const double buttonBorderRadius = 8.0;
  static const double iconSize = 48.0;
  static const double smallIconSize = 24.0;
  static const double logoSize = 20.0;
  static const double switchScale = 1.5;
  
  // Animation constants
  static const Duration snackBarDuration = Duration(seconds: 3);
  static const Duration dialogTransition = Duration(milliseconds: 200);
  
  // Private constructor to prevent instantiation
  DashboardConstants._();
}