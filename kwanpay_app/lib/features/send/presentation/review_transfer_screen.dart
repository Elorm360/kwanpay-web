import 'package:flutter/material.dart';

import '../../../core/services/transaction_service.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import 'transfer_success_screen.dart';

class ReviewTransferScreen extends StatefulWidget {
  final Map<String, dynamic> recipient;
  final double amount;

  const ReviewTransferScreen({
    super.key,
    required this.recipient,
    required this.amount,
  });

  @override
  State<ReviewTransferScreen> createState() =>
      _ReviewTransferScreenState();
}

class _ReviewTransferScreenState
    extends State<ReviewTransferScreen> {

  bool isSending = false;

  Future<void> executeTransfer() async {
    setState(() {
      isSending = true;
    });

    try {
      await TransactionService().transferFunds(
        receiverWalletId:
            widget.recipient['wallet']['wallet_id'],
        amount: widget.amount,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TransferSuccessScreen(
            recipientName:
                widget.recipient['profile']['full_name'],
            amount: widget.amount,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Review Transfer"),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Review Transfer",
                style: AppTextStyles.headline,
              ),
              const SizedBox(height: 32),
              Text(
                "Recipient",
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 8),
              Text(
                widget.recipient['profile']['full_name'],
                style: AppTextStyles.title,
              ),
              Text(
                widget.recipient['wallet']['wallet_id'],
                style: AppTextStyles.body,
              ),
              const Divider(height: 40),
              Text(
                "Amount",
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 8),
              Text(
                "USD ${widget.amount.toStringAsFixed(2)}",
                style: AppTextStyles.title,
              ),
              const SizedBox(height: 24),
              Text(
                "Transfer Fee",
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 8),
              const Text(
                "USD 0.00",
                style: AppTextStyles.body,
              ),
              const Divider(height: 40),
              Text(
                "Total",
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 8),
              Text(
                "USD ${widget.amount.toStringAsFixed(2)}",
                style: AppTextStyles.headline,
              ),
              const Spacer(),
              isSending
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : PrimaryButton(
                      text: "Confirm Transfer",
                      onPressed: executeTransfer,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
