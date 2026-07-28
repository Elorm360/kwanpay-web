import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class FeaturePlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const FeaturePlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 80,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                style: AppTextStyles.title,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "Feature under development",
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                "This feature will be available in an upcoming release.",
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

