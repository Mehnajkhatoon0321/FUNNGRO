import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Centralized text styles adhering to Funngro design guidelines.
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle appBarTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  static const TextStyle heroTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textOnPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle heroSubtitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: Colors.white70,
    height: 1.4,
  );

  static const TextStyle sectionHeader = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  static const TextStyle amountText = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: AppColors.successText,
  );

  static const TextStyle payoutBadge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.warningText,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textMuted,
  );

  static const TextStyle errorTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle errorMessage = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle footerStatus = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
}
