import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_colors.dart';

class ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const ProfileSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            title,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          decoration: BoxDecoration(
            color: context.colorSurface,
            borderRadius: BorderRadius.circular(AppRadius.large),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            children: List.generate(children.length, (index) {
              return Column(
                children: [
                  if (index > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Divider(
                        height: 1,
                        color: context.colorBorder,
                      ),
                    ),
                  children[index],
                ],
              );
            }),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

