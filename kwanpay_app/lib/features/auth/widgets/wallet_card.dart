import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class WalletCard extends StatefulWidget {
  final double balance;
  final VoidCallback onAddMoney;

  const WalletCard({
    super.key,
    required this.balance,
    required this.onAddMoney,
  });

  @override
  State<WalletCard> createState() => _WalletCardState();
}

class _WalletCardState extends State<WalletCard> {
  bool _isBalanceVisible = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.lg)
          .copyWith(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Balance Header Row ──────────────────────────────
          Row(
            children: [
              const Text(
                "Available Balance",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isBalanceVisible = !_isBalanceVisible;
                  });
                },
                child: Icon(
                  _isBalanceVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.white54,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Balance Amount ─────────────────────────────────
          Text(
            _isBalanceVisible
                ? "USD ${widget.balance.toStringAsFixed(2)}"
                : "•••••",
            style: AppTextStyles.headline.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          // ── Subtle Divider ──────────────────────────────────
          const Divider(
            color: Colors.white24,
            height: AppSpacing.xl,
          ),

          // ── Wallet Status Row ───────────────────────────────
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.white70,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text(
                "Wallet",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              const Text(
                "Not Connected",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── Action Buttons ──────────────────────────────────
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.primary,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.medium),
                      ),
                    ),
                    child: const Text(
                      "Pay",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: widget.onAddMoney,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Colors.white,
                      ),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.medium),
                      ),
                    ),
                    child: const Text(
                      "Add Funds",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

