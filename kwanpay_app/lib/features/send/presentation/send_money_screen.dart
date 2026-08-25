import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/app_currency.dart';
import '../../../core/providers/wallet_dashboard_provider.dart';
import '../../../core/services/wallet_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/kwan_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import 'review_transfer_screen.dart';

class SendMoneyScreen extends ConsumerStatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  ConsumerState<SendMoneyScreen> createState() =>
      _SendMoneyScreenState();
}

class _SendMoneyScreenState
    extends ConsumerState<SendMoneyScreen> {

  final walletController =
      TextEditingController();

  final amountController =
      TextEditingController();

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
        const SnackBar(
          content: Text('Nothing to paste. Copy a wallet ID first.'),
        ),
      );
      return;
    }

    setState(() {
      walletController.text = pasted;
      recipient = null;
    });
  }

  Future<void> searchWallet() async {
    if (searching) return;

    if (walletController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter a wallet ID."),
        ),
      );
      return;
    }

    searching = true;
    setState(() {});

    try {
      final result = await WalletService().findWalletById(
        walletController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        recipient = result;
        searching = false;
      });

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Wallet not found."),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        recipient = null;
        searching = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }

  void validateTransfer() {
    if (recipient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Search for a recipient first."),
        ),
      );
      return;
    }

    if (amountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter an amount."),
        ),
      );
      return;
    }

    final amount =
        double.tryParse(amountController.text);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter a valid amount."),
        ),
      );
      return;
    }

    if (amount > ref.read(walletDashboardProvider).canonicalBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Insufficient balance."),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewTransferScreen(
          recipient: recipient!,
          amount: amount,
          currency: _sendCurrency,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Send Money"),
      ),

      body: SafeArea(

        child: SingleChildScrollView(

          padding: AppSpacing.pagePadding,

          child: Column(

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Text(
                "Send Money",
                style: AppTextStyles.headline,
              ),

              const SizedBox(height: 8),

              const Text(
                "Send funds securely to another KwanPay wallet in USD, GHS, or NGN. This does not convert currencies.",
                style: AppTextStyles.body,
              ),

              const SizedBox(height: 32),

              KwanTextField(
                label: "Recipient Wallet ID",
                icon: Icons.account_balance_wallet_outlined,
                controller: walletController,
                suffix: IconButton(
                  tooltip: 'Paste wallet ID',
                  onPressed: pasteWalletId,
                  icon: const Icon(
                    Icons.content_paste_rounded,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              PrimaryButton(
                text: searching ? "Searching..." : "Search",
                onPressed: searchWallet,
              ),

              const SizedBox(height: 40),

              recipient == null
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.person_search,
                            size: 48,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Recipient will appear here",
                            style: AppTextStyles.title,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Enter a wallet ID and search.",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body,
                          ),
                        ],
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            child: Text(
                              recipient!['profile']['full_name']
                                  .toString()
                                  .substring(0, 1)
                                  .toUpperCase(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recipient!['profile']['full_name'],
                                  style: AppTextStyles.title,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  recipient!['wallet']['wallet_id'],
                                  style: AppTextStyles.body,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.verified,
                                      color: AppColors.success,
                                      size: 18,
                                    ),
                                    SizedBox(width: 6),
                                    Text("Verified KwanPay User"),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

              if (recipient != null) ...[

                const SizedBox(height: 24),

                KwanTextField(
                  label: "Amount",
                  icon: Icons.attach_money,
                  controller: amountController,
                ),

                const SizedBox(height: 16),

                Text(
                  "Available Balance: "
                  "${AppCurrencies.home.code} ${ref.watch(walletDashboardProvider).canonicalBalance.toStringAsFixed(2)}",
                  style: AppTextStyles.body,
                ),

                const SizedBox(height: 24),

                PrimaryButton(
                  text: "Continue",
                  onPressed: validateTransfer,
                ),

              ],

            ],

          ),

        ),

      ),

    );

  }

}

