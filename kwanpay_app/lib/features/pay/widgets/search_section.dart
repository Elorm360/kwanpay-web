import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_colors.dart';

class SearchSection extends StatelessWidget {
  const SearchSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        decoration: BoxDecoration(
          color: context.colorSurface,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          boxShadow: [
            BoxShadow(
              color: context.colorTextSecondary.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: "Search operator or destination",
            hintStyle: AppTextStyles.caption,
            prefixIcon: Icon(
              Icons.search_rounded,
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ),
    );
  }
}

