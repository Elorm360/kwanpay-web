import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_colors.dart';

class ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const ProfileTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius:
                      BorderRadius.circular(AppRadius.medium),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.colorTextPrimary,
                      ),
                    ),

                    if (subtitle != null) ...[
                      const SizedBox(height: 2),

                      Text(
                        subtitle!,
                        style: AppTextStyles.caption.copyWith(
                          color: context.colorTextSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,
                color: context.colorTextSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

