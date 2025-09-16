import 'package:flutter/material.dart';

class AppColors {
  // === Primary Brand Colors ===
  static const Color primary = Color(0xFF2563EB);        // Modern blue - main brand
  static const Color primaryDark = Color(0xFF1D4ED8);    // Darker blue for hover states
  static const Color primaryLight = Color(0xFF3B82F6);   // Lighter blue for accents
  
  // === Secondary Colors ===
  static const Color teal = Color(0xFF0891B2);           // Modern teal for CTAs
  static const Color tealDark = Color(0xFF0E7490);       // Darker teal
  static const Color tealLight = Color(0xFF0EA5E9);      // Light teal
  
  // === Background Colors ===
  static const Color backgroundPrimary = Color(0xFFF0F8FF);   // Light blue background (matches screenshot)
  static const Color backgroundSecondary = Color(0xFFF1F5F9); // Card backgrounds
  static const Color backgroundGradientStart = Color(0xFFE3F2FD); // Light blue gradient start
  static const Color backgroundGradientEnd = Color(0xFFF8FAFC);   // Very light blue-white gradient end
  
  // === Text Colors ===
  static const Color textPrimary = Color(0xFF0F172A);    // Main text (dark slate)
  static const Color textSecondary = Color(0xFF475569);  // Secondary text
  static const Color textTertiary = Color(0xFF94A3B8);   // Tertiary/placeholder text
  static const Color textLight = Color(0xFFCBD5E1);      // Light text on dark backgrounds
  
  // === Surface Colors ===
  static const Color surface = Color(0xFFFFFFFF);        // White surfaces
  static const Color surfaceElevated = Color(0xFFF8FAFC); // Slightly elevated surfaces
  static const Color border = Color(0xFFE2E8F0);         // Default borders
  static const Color borderFocus = Color(0xFF3B82F6);    // Focused borders
  
  // === Status Colors ===
  static const Color success = Color(0xFF059669);        // Success green
  static const Color successLight = Color(0xFF10B981);   // Light success
  static const Color successBg = Color(0xFFECFDF5);      // Success background
  
  static const Color error = Color(0xFFDC2626);          // Error red
  static const Color errorLight = Color(0xFFEF4444);     // Light error
  static const Color errorBg = Color(0xFFFEF2F2);        // Error background
  
  static const Color warning = Color(0xFFD97706);        // Warning orange
  static const Color warningLight = Color(0xFFF59E0B);   // Light warning
  static const Color warningBg = Color(0xFFFEF3C7);      // Warning background
  
  static const Color info = Color(0xFF0284C7);           // Info blue
  static const Color infoBg = Color(0xFFE0F2FE);         // Info background
  
  // === Legacy Colors (for compatibility) ===
  static const Color deepNavyBlue = textPrimary;         // Mapped to new textPrimary
  static const Color background = backgroundPrimary;      // Mapped to new background
  static const Color highlightTeal = teal;               // Mapped to new teal
  static const Color successGreen = success;             // Mapped to new success
  static const Color errorRed = error;                   // Mapped to new error
  static const Color linkTeal = tealDark;                // Mapped to new tealDark
  static const Color cyan = tealLight;                   // Mapped to new tealLight
  static const Color greenSuccess = success;             // Mapped to new success
  static const Color redError = error;                   // Mapped to new error
  
  // === Gradient Definitions ===
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundGradientStart, backgroundGradientEnd],
    stops: [0.0, 1.0],
  );
  
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [teal, tealDark],
    stops: [0.0, 1.0],
  );
}