import 'package:flutter/material.dart';

/// Centralized color palette for the Funngro application.
/// Ensures consistent branding, theme coherence, and avoids scattered inline colors.
class AppColors {
  AppColors._();

  // Brand Colors
  static const Color primary = Color(0xFF4F46E5); // Indigo
  static const Color primaryDark = Color(0xFF3730A3);
  static const Color primaryLight = Color(0xFFEEF2FF);

  // Background & Surfaces
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Colors.white;
  static const Color cardBorder = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFE5E7EB);

  // Typography Colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Colors.white;

  // Status & Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color successBg = Color(0xFFECFDF5);
  static const Color successText = Color(0xFF065F46);

  static const Color error = Color(0xFFEF4444);
  static const Color errorBg = Color(0xFFFEF2F2);
  static const Color errorBorder = Color(0xFFFECACA);
  static const Color errorText = Color(0xFF991B1B);

  static const Color warningBg = Color(0xFFFFFBEB);
  static const Color warningBorder = Color(0xFFFDE68A);
  static const Color warningText = Color(0xFF92400E);

  // Accent Gradients
  static const List<Color> heroGradient = [
    Color(0xFF4F46E5),
    Color(0xFF9333EA),
  ];
}
