import 'package:flutter/material.dart';

import '../../../core/models/wallet_model.dart';
import '../../../core/services/wallet_service.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/kwan_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import 'review_transfer_screen.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() =>
      _SendMoneyScreenState();
}

class _SendMoneyScreenState
    extends State<SendMoneyScreen> {

  final walletController =
      TextEditingController();

  final amountController =
      TextEditingController();

  Map<String, dynamic>? recipient;

  bool searching = false;

  WalletModel? myWallet;

  @override
  void initState() {
    super.initState();
    loadMyWallet();
  }

  Future<void> loadMyWallet() async {
    myWallet = await WalletService().getWallet();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    walletController.dispose();
    amountController.dispose();
    super.dispose();
  }

  Future<void> searchWallet() async {
    if (walletController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter a wallet ID."),
        ),
      );
      return;
    }

    setState(() {
      searching = true;
    });

    final result =
        await WalletService().findWalletById(
      walletController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      recipient = result;
      searching = false;
    });

    if (result != null &&
        result['wallet']['id'] ==
            WalletService().currentUser?.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "You cannot send money to your own wallet.",
          ),
        ),
      );

      setState(() {
        recipient = null;
      });

      return;
    }

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Wallet not found."),
        ),
      );
    }
  }

  void validateTransfer() {
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

    if (amount > (myWallet?.balance ?? 0)) {
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
                "Send funds securely to another KwanPay wallet.",
                style: AppTextStyles.body,
              ),

              const SizedBox(height: 32),

              KwanTextField(
                label: "Recipient Wallet ID",
                icon: Icons.account_balance_wallet_outlined,
                controller: walletController,
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
                            color: Colors.grey.shade400,
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
                                      color: Colors.green,
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
                  "${myWallet?.currency ?? "USD"} "
                  "${myWallet?.balance.toStringAsFixed(2) ?? "0.00"}",
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

