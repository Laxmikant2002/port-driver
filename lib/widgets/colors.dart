import 'package:flutter/material.dart';

class AppColors {
  // 🎯 Primary Brand Colors - Deep Navy Blue (matching the image)
  static const Color deepNavyBlue = Color(0xFF1E3A8A);      // Deep navy blue from image
  static const Color primary = deepNavyBlue;
  static const Color primaryDark = Color(0xFF1E40AF);       // Darker deep navy blue
  static const Color primaryLight = Color(0xFF3B82F6);      // Lighter deep navy blue
  static const Color primaryContainer = Color(0xFFEFF6FF);  // Light blue background

  // 🌊 Secondary Colors - Cyan (matching the image)
  static const Color cyan = Color(0xFF06B6D4);              // Cyan from image - teal/cyan accent
  static const Color secondary = cyan;
  static const Color secondaryDark = Color(0xFF0891B2);     // Darker cyan
  static const Color secondaryLight = Color(0xFF22D3EE);    // Lighter cyan

  // 🎨 Image-specific Colors
  static const Color teal = Color(0xFF14B8A6);              // Teal for profile avatar (from image)
  static const Color lightBlue = Color(0xFFE0F2FE);         // Light blue for icons (from image)
  static const Color lightBlueIcon = Color(0xFF0EA5E9);     // Light blue icon color (from image)
  static const Color successGreen = Color(0xFF10B981);      // Success green (from image)
  static const Color warningYellow = Color(0xFFF59E0B);     // Warning yellow (from image)

  // ⚡ Accent Colors
  static const Color accent = Color(0xFFF59E0B);            // Amber - warnings, highlights
  static const Color accentDark = Color(0xFFD97706);        // Darker amber
  static const Color accentLight = Color(0xFFFBBF24);       // Lighter amber

  // 🎨 Neutral Colors
  static const Color surface = Color(0xFFFFFFFF);           // Card/container backgrounds
  static const Color surfaceVariant = Color(0xFFF8FAFC);    // Subtle background variant
  static const Color background = Color(0xFFF1F5F9);        // Main background
  static const Color backgroundSecondary = Color(0xFFE2E8F0); // Secondary background

  // 📝 Text Colors
  static const Color textPrimary = Color(0xFF0F172A);       // High contrast text
  static const Color textSecondary = Color(0xFF475569);     // Medium contrast text
  static const Color textTertiary = Color(0xFF64748B);      // Low contrast text
  static const Color textDisabled = Color(0xFF94A3B8);      // Disabled text

  // 🚦 Status Colors
  static const Color success = Color(0xFF10B981);           // Success states
  static const Color successLight = Color(0xFFD1FAE5);      // Success background
  static const Color warning = Color(0xFFF59E0B);           // Warning states
  static const Color warningLight = Color(0xFFFEF3C7);      // Warning background
  static const Color error = Color(0xFFEF4444);             // Error states
  static const Color errorLight = Color(0xFFFEE2E2);        // Error background
  static const Color info = Color(0xFF3B82F6);              // Info states
  static const Color infoLight = Color(0xFFDBEAFE);         // Info background

  // 🎭 Interactive Colors
  static const Color border = Color(0xFFE2E8F0);            // Default borders
  static const Color borderFocus = Color(0xFF3B82F6);       // Focused borders
  static const Color borderError = Color(0xFFEF4444);       // Error borders
  static const Color borderSuccess = Color(0xFF10B981);     // Success borders

  // 🌈 Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF2563EB),
    Color(0xFF3B82F6),
  ];
  
  static const List<Color> secondaryGradient = [
    Color(0xFF10B981),
    Color(0xFF34D399),
  ];

  static const List<Color> backgroundGradient = [
    Color(0xFFF8FAFC),
    Color(0xFFF1F5F9),
  ];

  // 🎯 Legacy Support (for backward compatibility)
  static const Color navyDark = primaryDark;
  static const Color amber = accent;
  static const Color amberDark = accentDark;
  static const Color greenSuccess = success;
  static const Color redError = error;
  static const Color infoLightBlue = infoLight;
  static const Color backgroundAlt = backgroundSecondary;
  static const Color textCTA = primary;
  static const Color textSuccess = success;
  static const Color textError = error;
  static const Color userPrimary = primary;
  static const Color userSecondary = secondary;
  static const Color userCTA = primary;
  static const Color userSuccess = success;
  static const Color userError = error;
  static const Color userInfoBg = infoLight;
}