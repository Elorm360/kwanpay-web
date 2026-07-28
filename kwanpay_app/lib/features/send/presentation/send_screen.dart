import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_colors.dart';

class SendScreen extends StatelessWidget {
  const SendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorPaper,
      appBar: AppBar(
        title: const Text("Send Money"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            "Who would you like to send money to?",
            style: AppTextStyles.title.copyWith(
              color: context.colorTextPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            decoration: InputDecoration(
              hintText: "Search recipient",
              hintStyle: AppTextStyles.caption,
              prefixIcon: Icon(
                Icons.search,
                color: context.colorTextSecondary,
              ),
              filled: true,
              fillColor: context.colorSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                borderSide: BorderSide(color: context.colorBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            "Recent Recipients",
            style: AppTextStyles.title.copyWith(
              color: context.colorTextPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.xl,
            ),
            decoration: BoxDecoration(
              color: context.colorSurface,
              borderRadius: BorderRadius.circular(AppRadius.large),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppRadius.large),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.primary,
                    size: 36,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  "No recipients yet.",
                  style: AppTextStyles.title.copyWith(
                    color: context.colorTextPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  "Recipients you've paid before\nwill appear here.",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    color: context.colorTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

