import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/wallet_dashboard_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../../navigation/main_navigation_screen.dart';

class TransferSuccessScreen extends ConsumerWidget {
  final String recipientName;
  final double amount;
  final String currency;

  const TransferSuccessScreen({
    super.key,
    required this.recipientName,
    required this.amount,
    required this.currency,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            children: [
              const Spacer(),
              const CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.success,
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Transfer Successful",
                style: AppTextStyles.headline,
              ),
              const SizedBox(height: 12),
              Text(
                "You sent $currency ${amount.toStringAsFixed(2)} to\n$recipientName",
                textAlign: TextAlign.center,
                style: AppTextStyles.body,
              ),
              const Spacer(),
              PrimaryButton(
                text: "Back to Dashboard",
                onPressed: () async {
                  await ref.read(walletDashboardProvider.notifier).refresh();
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MainNavigationScreen(),
                    ),
                    (_) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
