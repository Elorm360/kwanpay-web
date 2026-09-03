import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/app_currency.dart';
import '../../../core/providers/wallet_dashboard_provider.dart';
import '../../../core/services/wallet_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/kwan_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import 'review_transfer_screen.dart';

class SendMoneyScreen extends ConsumerStatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  ConsumerState<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends ConsumerState<SendMoneyScreen> {
  final walletController = TextEditingController();
  final amountController = TextEditingController();

  Map<String, dynamic>? recipient;
  bool searching = false;
  late String _sendCurrency;

  @override
  void initState() {
    super.initState();
    _sendCurrency = AppCurrencies.home.code;
    ref.read(walletDashboardProvider.notifier).refresh();
  }

  @override
  void dispose() {
    walletController.dispose();
    amountController.dispose();
    super.dispose();
  }

  Future<void> pasteWalletId() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final pasted = data?.text?.trim() ?? '';
    if (pasted.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nothing to paste. Copy a wallet ID first.')),
      );
      return;
    }
    setState(() {
      walletController.text = pasted;
      recipient = null;
    });
  }

  Future<void> searchWallet() async {
    final walletId = walletController.text.trim();
    if (searching) return;
    if (walletId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a wallet ID.')),
      );
      return;
    }

    setState(() => searching = true);
    try {
      final result = await WalletService().findWalletById(walletId);
      if (!mounted) return;
      setState(() {
        recipient = result;
        searching = false;
      });
      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('We could not find that KwanPay wallet.')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        recipient = null;
        searching = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('We could not look up that wallet right now.')),
      );
    }
  }

  void validateTransfer() {
    final found = recipient;
    if (found == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Search for a recipient first.')),
      );
      return;
    }

    final amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount.')),
      );
      return;
    }

    final balance = ref.read(walletDashboardProvider).canonicalBalance;
    if (amount > balance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You do not have enough available balance.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewTransferScreen(
          recipient: found,
          amount: amount,
          currency: _sendCurrency,
        ),
      ),
    );
  }

  String _recipientName() {
    final profile = recipient?['profile'];
    if (profile is Map && profile['full_name'] != null) {
      final name = profile['full_name'].toString().trim();
      if (name.isNotEmpty) return name;
    }
    return 'KwanPay user';
  }

  String _recipientWalletId() {
    final wallet = recipient?['wallet'];
    if (wallet is Map && wallet['wallet_id'] != null) {
      return wallet['wallet_id'].toString();
    }
    return walletController.text.trim();
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = ref.watch(walletDashboardProvider);
    final balance = dashboard.canonicalBalance;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(title: const Text('Send Money')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          children: [
            Text('Send money securely', style: AppTextStyles.headline),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Send funds to another KwanPay wallet. Review the recipient and amount before you confirm.',
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('RECIPIENT', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.sm),
            KwanTextField(
              label: 'Wallet ID',
              icon: Icons.account_balance_wallet_outlined,
              controller: walletController,
              suffix: IconButton(
                tooltip: 'Paste wallet ID',
                onPressed: pasteWalletId,
                icon: const Icon(Icons.content_paste_rounded),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              text: searching ? 'Searching…' : 'Find recipient',
              onPressed: searching ? null : searchWallet,
            ),
            const SizedBox(height: AppSpacing.lg),
            if (recipient == null)
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.large),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.person_search_rounded, size: 36, color: AppColors.textSecondary),
                    SizedBox(height: AppSpacing.sm),
                    Text('Recipient details will appear here', style: TextStyle(fontWeight: FontWeight.w700)),
                    SizedBox(height: AppSpacing.xs),
                    Text('Check the wallet identity before sending money.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.large),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                      foregroundColor: AppColors.primary,
                      child: Text(_recipientName().substring(0, 1).toUpperCase()),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_recipientName(), style: AppTextStyles.title),
                          const SizedBox(height: 3),
                          Text(_recipientWalletId(), style: AppTextStyles.caption),
                          const SizedBox(height: 6),
                          const Row(
                            children: [
                              Icon(Icons.verified_rounded, color: AppColors.success, size: 17),
                              SizedBox(width: 5),
                              Text('Verified KwanPay wallet', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            if (recipient != null) ...[
              const SizedBox(height: AppSpacing.xl),
              Text('AMOUNT', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: AppSpacing.sm),
              KwanTextField(
                label: 'Amount in ${_sendCurrency}',
                icon: Icons.payments_outlined,
                controller: amountController,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Available · ${_sendCurrency} ${balance.toStringAsFixed(2)}',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(text: 'Review transfer', onPressed: validateTransfer),
            ],
          ],
        ),
      ),
    );
  }
}
