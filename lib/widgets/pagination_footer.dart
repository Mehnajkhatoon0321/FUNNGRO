import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_text_styles.dart';

/// Distinct footer widget for the bottom of the paginated list.
class PaginationFooter extends StatelessWidget {
  final bool isLoadingMore;
  final String? paginationError;
  final bool hasReachedEnd;
  final int totalCount;
  final VoidCallback onRetry;

  const PaginationFooter({
    super.key,
    required this.isLoadingMore,
    required this.paginationError,
    required this.hasReachedEnd,
    required this.totalCount,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24.0),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 12),
              Text(
                AppStrings.loadingMoreProjects,
                style: AppTextStyles.footerStatus,
              ),
            ],
          ),
        ),
      );
    }

    if (paginationError != null) {
      final lower = paginationError!.toLowerCase();
      final isOffline = lower.contains('internet') ||
          lower.contains('offline') ||
          lower.contains('wi-fi') ||
          lower.contains('data') ||
          lower.contains('connection');

      final errorText = isOffline
          ? 'No internet connection. Please check your data & retry.'
          : 'Failed to load next page ($paginationError)';

      return Container(
        margin: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFECDD3)),
        ),
        child: Row(
          children: [
            Icon(
              isOffline ? Icons.wifi_off_rounded : Icons.warning_amber_rounded,
              color: const Color(0xFFE11D48),
              size: 24,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                errorText,
                style: const TextStyle(
                  color: Color(0xFF9F1239),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                visualDensity: VisualDensity.compact,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (hasReachedEnd) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Center(
          child: Text(
            '${AppStrings.endOfListMessage} ($totalCount projects)',
            style: AppTextStyles.footerStatus,
          ),
        ),
      );
    }

    return const SizedBox(height: 16);
  }
}
