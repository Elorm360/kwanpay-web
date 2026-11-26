import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/wallet_dashboard_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/transaction_model.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../navigation/main_navigation_screen.dart';
import '../../receipts/receipt_screen.dart';

class PaymentSuccessScreen extends ConsumerWidget {
  final String operatorName;
  final double amount;
  final String currency;

  /// Set only for the Stellar testnet USDC flow.
  final String? txHash;
  final TransactionModel? transaction;

  const PaymentSuccessScreen({
    super.key,
    required this.operatorName,
    required this.amount,
    required this.currency,
    this.txHash,
    this.transaction,
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
                'Payment made',
                style: AppTextStyles.headline,
              ),
              const SizedBox(height: 12),
              Text(
                'You paid $currency ${amount.toStringAsFixed(2)} to\n$operatorName',
                textAlign: TextAlign.center,
                style: AppTextStyles.body,
              ),
              // The test-network note belongs only to the Stellar USDC flow;
              // a cedi payment does come out of the GHS balance.
              if (txHash != null && txHash!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Paid in test USDC on the Stellar test network. Your GHS balance was not used.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  txHash!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption,
                ),
              ],
              const Spacer(),
              if (transaction != null) ...[
                SecondaryButton(
                  text: 'View receipt',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReceiptScreen(transaction: transaction!),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              PrimaryButton(
                text: 'Back to home',
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
