import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_colors.dart';

class ProfileHeader extends StatelessWidget {
  final String userName;

  const ProfileHeader({
    super.key,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = userName.isNotEmpty ? userName : 'User';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title ──────────────────────────────────────
          Text(
            "Profile",
            style: AppTextStyles.title.copyWith(
              color: context.colorTextPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            "Manage your KwanPay account.",
            style: AppTextStyles.caption.copyWith(
              color: context.colorTextSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Avatar ─────────────────────────────────────
          Center(
            child: Stack(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.accent,
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 44,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Name ───────────────────────────────────────
          Center(
            child: Text(
              displayName,
              style: AppTextStyles.title.copyWith(
                color: context.colorTextPrimary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // ── Account Badge ──────────────────────────────
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_user_rounded,
                    size: 14,
                    color: AppColors.accent,
                  ),
                  SizedBox(width: 4),
                  Text(
                    "Basic Account",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

