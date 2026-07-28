import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class EmptyOperatorState extends StatelessWidget {
  const EmptyOperatorState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xl,
        horizontal: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: AppShadows.card,
      ),
      child: const Column(
        children: [
          Icon(
            Icons.storefront_outlined,
            size: 56,
            color: AppColors.textSecondary,
          ),

          SizedBox(height: AppSpacing.md),

          Text(
            "No operators available",
            style: AppTextStyles.title,
          ),

          SizedBox(height: AppSpacing.sm),

          Text(
            "Operators that accept KwanPay\nwill appear here.",
            textAlign: TextAlign.center,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

