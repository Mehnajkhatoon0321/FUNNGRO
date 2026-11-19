import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../models/earning.dart';

class EarningTile extends StatelessWidget {
  final Earning earning;
  final String subtitle;
  final VoidCallback onTap;
  final bool isLoading;

  const EarningTile({
    super.key,
    required this.earning,
    required this.subtitle,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Clean Category / Transaction Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.successBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_downward_rounded,
                    color: AppColors.successText,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Title and formatted subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        earning.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Amount & Chevron
                isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            earning.formattedAmount,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.successText,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: AppColors.textMuted,
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
