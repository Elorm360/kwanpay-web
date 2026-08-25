import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/wallet_dashboard_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../convert/presentation/convert_screen.dart';
import '../../pay/presentation/pay_screen.dart';
import '../../send/presentation/send_money_screen.dart';
import '../presentation/add_funds_screen.dart';
import 'action_card.dart';

class QuickActions extends ConsumerWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quick Actions",
            style: AppTextStyles.title,
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            "Choose what you'd like to do.",
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ActionCard(
                  icon: Icons.qr_code_scanner_rounded,
                  title: "Pay",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PayScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ActionCard(
                  icon: Icons.send_rounded,
                  title: "Send",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SendMoneyScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ActionCard(
                  icon: Icons.currency_exchange_rounded,
                  title: "Rates",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ConvertScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ActionCard(
                  icon: Icons.account_balance_wallet_outlined,
                  title: "Top Up",
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddFundsScreen(),
                      ),
                    );
                    ref.read(walletDashboardProvider.notifier).refresh();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
