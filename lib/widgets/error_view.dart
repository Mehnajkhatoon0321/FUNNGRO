import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';

/// Full-screen error state widget with dedicated offline / internet check styling and retry action.
class ErrorView extends StatelessWidget {
  final String? title;
  final String message;
  final VoidCallback onRetry;

  const ErrorView({
    super.key,
    this.title,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final lower = message.toLowerCase();
    final isOffline = lower.contains('internet') ||
        lower.contains('offline') ||
        lower.contains('wi-fi') ||
        lower.contains('data') ||
        lower.contains('connection');

    final effectiveTitle = title ??
        (isOffline
            ? 'No Internet Connection'
            : AppStrings.somethingWentWrong);

    final icon =
        isOffline ? Icons.wifi_off_rounded : Icons.cloud_off_rounded;
    final iconColor = isOffline ? const Color(0xFFE11D48) : AppColors.error;
    final iconBg =
        isOffline ? const Color(0xFFFFF1F2) : AppColors.errorBg;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 52,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              effectiveTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF64748B),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                isOffline ? 'Check & Retry' : AppStrings.tryAgain,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
