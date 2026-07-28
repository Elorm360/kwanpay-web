import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';

class EnterAmountScreen extends StatelessWidget {
  final String recipient;

  const EnterAmountScreen({
    super.key,
    required this.recipient,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: const Text("Send Money"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Recipient info
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.accent,
                child: Text(
                  recipient.substring(0, 1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Sending to",
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    recipient,
                    style: AppTextStyles.title,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          // Currency selection
          const Text(
            "Choose Currency",
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.medium),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: "USD",
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: "USD", child: Text("USD - US Dollar")),
                  DropdownMenuItem(value: "GHS", child: Text("GHS - Ghana Cedi")),
                  DropdownMenuItem(value: "EUR", child: Text("EUR - Euro")),
                ],
                onChanged: (value) {},
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Amount input
          const Text(
            "Enter Amount",
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "0.00",
              hintStyle: AppTextStyles.caption,
              prefixText: "\$ ",
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Note input
          const Text(
            "Add Note (Optional)",
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "What's this for?",
              hintStyle: AppTextStyles.caption,
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Continue button
          PrimaryButton(
            text: "Continue",
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Payment processing coming in Sprint 8"),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

