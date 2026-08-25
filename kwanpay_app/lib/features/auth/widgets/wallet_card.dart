import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/models/app_currency.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class WalletCard extends StatefulWidget {
  final double balance;
  final String walletId;
  final String status;
  final String currency;
  final VoidCallback onAddMoney;
  final VoidCallback onPay;
  final ValueChanged<String>? onCurrencySelected;
  final double pendingAmount;
  final bool balanceMatched;
  final bool hasDisplayRate;
  final String? homeBalanceLabel;

  const WalletCard({
    super.key,
    required this.balance,
    required this.walletId,
    required this.status,
    required this.currency,
    required this.onAddMoney,
    required this.onPay,
    this.onCurrencySelected,
    this.pendingAmount = 0,
    this.balanceMatched = true,
    this.hasDisplayRate = true,
    this.homeBalanceLabel,
  });

  @override
  State<WalletCard> createState() => _WalletCardState();
}

class _WalletCardState extends State<WalletCard> {
  bool hideBalance = false;

  bool get _canCopyWalletId {
    final walletId = widget.walletId.trim();
    return walletId.isNotEmpty && walletId != 'Loading...';
  }

  Future<void> _copyWalletId() async {
    if (!_canCopyWalletId) return;

    await Clipboard.setData(
      ClipboardData(text: widget.walletId.trim()),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Wallet ID copied'),
      ),
    );
  }

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Available Balance",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              IconButton(
                splashRadius: 18,
                onPressed: () {
                  setState(() {
                    hideBalance = !hideBalance;
                  });
                },
                icon: Icon(
                  hideBalance
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Balance Amount ─────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  hideBalance
                      ? "••••••"
                      : widget.hasDisplayRate
                          ? "${widget.currency} ${widget.balance.toStringAsFixed(2)}"
                          : "Rate unavailable",
                  style: AppTextStyles.walletBalance,
                ),
              ),
              if (widget.onCurrencySelected != null)
                PopupMenuButton<String>(
                  onSelected: (code) {
                    widget.onCurrencySelected?.call(code);
                  },
                  color: Colors.white,
                  itemBuilder: (context) {
                    return AppCurrencies.display.map((currency) {
                      return PopupMenuItem<String>(
                        value: currency.code,
                        child: Text('${currency.code} · ${currency.name}'),
                      );
                    }).toList();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Text(
                          widget.currency,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Icon(
                          Icons.expand_more_rounded,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            "Held in Ghana cedis. Other currencies are a live estimate.",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          if (widget.homeBalanceLabel != null) ...[
            const SizedBox(height: 4),
            Text(
              widget.homeBalanceLabel!,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],

          const SizedBox(height: 16),

          // ── Wallet ID Row ────────────────────────────────────
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.white70,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text(
                "Wallet ID",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: GestureDetector(
                  onTap: _canCopyWalletId ? _copyWalletId : null,
                  child: Text(
                    widget.walletId,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              if (_canCopyWalletId)
                IconButton(
                  tooltip: 'Copy wallet ID',
                  splashRadius: 18,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  onPressed: _copyWalletId,
                  icon: const Icon(
                    Icons.copy_rounded,
                    size: 18,
                    color: Colors.white70,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Status Row ──────────────────────────────────────
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: widget.balanceMatched
                      ? AppColors.success
                      : AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.status,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          if (!widget.balanceMatched) ...[
            const SizedBox(height: 8),
            const Text(
              "This balance needs review · available funds were not changed",
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 12,
              ),
            ),
          ] else if (widget.pendingAmount > 0.005) ...[
            const SizedBox(height: 8),
            Text(
              "${widget.currency} ${widget.pendingAmount.toStringAsFixed(2)} pending",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.lg),

          // ── Action Buttons ──────────────────────────────────
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: widget.onPay,
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

