import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../../pay/presentation/pay_screen.dart';

class RecentActivity extends StatelessWidget {
  const RecentActivity({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section Header ─────────────────────────────────
          const Text(
            "Activity",
            style: AppTextStyles.title,
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            "Your payments, transfers and wallet\nactivity will appear here.",
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Empty Activity Card ────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.large),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.receipt_long_outlined,
                  color: AppColors.primary,
                  size: 56,
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  "No activity yet",
                  style: AppTextStyles.title,
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  "Payments, transfers and wallet\ntop ups will appear here once\nyou start using KwanPay.",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  text: "Make Your First Payment",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PayScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

