import 'package:flutter/material.dart';

class AppConstants {
  // Dimension Constants
  static const double kFieldHeight = 56.0;
  static const double kBorderRadius = 18.0;
  static const double kCardBorderRadius = 32.0;
  static const double kButtonBorderRadius = 16.0;
  static const double kContainerBorderRadius = 20.0;
  static const double kIconSize = 20.0;
  static const double kFlagIconSize = 12.0;
  
  // Spacing Constants
  static const double kPaddingSmall = 8.0;
  static const double kPaddingMedium = 16.0;
  static const double kPaddingLarge = 24.0;
  static const double kPaddingXLarge = 32.0;
  
  // Animation Constants
  static const Duration kFadeAnimationDuration = Duration(milliseconds: 1200);
  static const Duration kValidationAnimationDuration = Duration(milliseconds: 300);
  
  // Text Constants
  static const double kBodyTextSize = 16.0;
  static const double kInputTextSize = 17.0;
  static const double kTitleTextSize = 28.0;
  static const double kBrandTextSize = 22.0;
  
  // Responsive Breakpoints
  static const double kMobileBreakpoint = 600.0;
  static const double kTabletBreakpoint = 900.0;
  
  // Country Codes
  static const Map<String, String> kCountryCodes = {
    'IN': '+91',
    'US': '+1',
    'UK': '+44',
    'AE': '+971',
    'AU': '+61',
  };
  
  static const Map<String, String> kCountryFlags = {
    'IN': '🇮🇳',
    'US': '🇺🇸',
    'UK': '🇬🇧',
    'AE': '🇦🇪',
    'AU': '🇦🇺',
  };
  
  // Phone Validation
  static const int kPhoneNumberLength = 10;
  static const String kDefaultCountryCode = 'IN';
}

// Responsive Helper Extension
extension ResponsiveExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  
  bool get isMobile => screenWidth < AppConstants.kMobileBreakpoint;
  bool get isTablet => screenWidth >= AppConstants.kMobileBreakpoint && 
                      screenWidth < AppConstants.kTabletBreakpoint;
  bool get isDesktop => screenWidth >= AppConstants.kTabletBreakpoint;
  
  double get responsivePadding => screenWidth * 0.05;
  double get responsiveHorizontalPadding => isMobile ? 20.0 : screenWidth * 0.08;
  double get responsiveVerticalPadding => isMobile ? 24.0 : 32.0;
  
  // Image optimization helpers
  int get optimizedImageWidth => screenWidth.toInt();
  int get optimizedImageHeight => (screenHeight * 0.8).toInt(); // Increased from 60% to 80% for taller image
  
  // Background image cache sizes based on device type - Increased heights
  int get backgroundCacheWidth => isMobile ? 600 : isTablet ? 800 : 1200;
  int get backgroundCacheHeight => isMobile ? 1200 : isTablet ? 1600 : 2000; // Significantly increased heights
}