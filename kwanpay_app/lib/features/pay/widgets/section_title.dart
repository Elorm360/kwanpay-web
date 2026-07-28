import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback? onTap;

  const SectionTitle({
    super.key,
    required this.title,
    this.actionText = "See all",
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.title,
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionText,
            style: AppTextStyles.button.copyWith(
              color: AppColors.accent,
            ),
          ),
        ),
      ],
    );
  }
}

