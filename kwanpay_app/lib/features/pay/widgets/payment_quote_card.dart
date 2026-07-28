import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';

class PaymentQuoteCard extends StatelessWidget {
  const PaymentQuoteCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),

      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),

        boxShadow: AppShadows.card,
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "Payment Estimate",
            style: AppTextStyles.title,
          ),

          const SizedBox(height: AppSpacing.lg),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.calculate_outlined,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    "Choose an operator to view:",
                    style: AppTextStyles.body,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    "• Amount\n• Exchange rate\n• Network fee\n• Total payable",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          PrimaryButton(
            text: "Review Payment",
            onPressed: () {},
          ),

        ],
      ),
    );
  }
}

