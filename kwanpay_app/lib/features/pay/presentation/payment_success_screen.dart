import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/wallet_dashboard_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../../navigation/main_navigation_screen.dart';

class PaymentSuccessScreen extends ConsumerWidget {
  final String operatorName;
  final double amount;
  final String currency;
  final String? txHash;

  const PaymentSuccessScreen({
    super.key,
    required this.operatorName,
    required this.amount,
    required this.currency,
    this.txHash,
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
                'Payment Successful',
                style: AppTextStyles.headline,
              ),
              const SizedBox(height: 12),
              Text(
                'You paid $currency ${amount.toStringAsFixed(2)} to\n$operatorName',
                textAlign: TextAlign.center,
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 8),
              Text(
                'Horizon verified this Testnet USDC payment. It did not debit your GHS, USD, or NGN pot.',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (txHash != null && txHash!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  txHash!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption,
                ),
              ],
              const Spacer(),
              PrimaryButton(
                text: 'Back to Dashboard',
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
