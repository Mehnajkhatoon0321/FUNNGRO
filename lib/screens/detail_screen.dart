import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/currency_formatter.dart';
import '../core/utils/responsive_layout.dart';
import '../models/earning.dart';

class DetailScreen extends StatelessWidget {
  final EarningDetail detail;

  const DetailScreen({super.key, required this.detail});

  String _formatDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year.toString();
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$day/$month/$year, $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.earningsDetail),
      ),
      body: ResponsiveLayout.constrainedBody(
        context,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppColors.successBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    size: 56,
                    color: AppColors.success,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  formatCurrency(detail.payout),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.successBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.successText.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    detail.status,
                    style: const TextStyle(
                      color: AppColors.successText,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Divider(color: AppColors.divider),
              const SizedBox(height: 16),
              _buildDetailRow(AppStrings.project, detail.projectTitle),
              if (detail.category != null)
                _buildDetailRow('Category', detail.category!),
              _buildDetailRow(AppStrings.client, detail.clientName),
              _buildDetailRow(
                AppStrings.date,
                _formatDateTime(detail.completedAt),
              ),
              if (detail.paymentMode != null)
                _buildDetailRow('Payment Mode', detail.paymentMode!),
              _buildDetailRow(AppStrings.transactionRef, detail.paymentRef),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.bodySecondary,
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: AppTextStyles.cardTitle,
            ),
          ),
        ],
      ),
    );
  }
}
