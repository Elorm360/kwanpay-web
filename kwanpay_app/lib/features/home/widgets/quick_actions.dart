import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../pay/presentation/pay_screen.dart';
import '../../send/presentation/send_screen.dart';
import 'action_card.dart';
import 'feature_placeholder_screen.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
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

          // ── Action Cards ──────────────────────────────────
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
                        builder: (_) => const SendScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ActionCard(
                  icon: Icons.currency_exchange_rounded,
                  title: "Convert",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FeaturePlaceholderScreen(
                          title: "Convert",
                          icon: Icons.currency_exchange_rounded,
                        ),
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FeaturePlaceholderScreen(
                          title: "Top Up",
                          icon: Icons.account_balance_wallet_outlined,
                        ),
                      ),
                    );
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

