import 'package:flutter/material.dart';

import '../../../core/models/transaction_model.dart';
import '../../../core/theme/app_text_styles.dart';

class RecentActivity extends StatelessWidget {
  final List<TransactionModel> transactions;

  const RecentActivity({
    super.key,
    required this.transactions,
  });

  IconData getTransactionIcon(String type) {
    switch (type) {
      case "Top Up":
        return Icons.south_west_rounded;
      case "Send":
        return Icons.north_east_rounded;
      case "Receive":
        return Icons.south_west_rounded;
      case "Payment":
        return Icons.credit_card_rounded;
      case "Exchange":
        return Icons.currency_exchange;
      default:
        return Icons.receipt_long;
    }
  }

  Color getTransactionColor(String type) {
    switch (type) {
      case "Top Up":
        return Colors.green;
      case "Send":
        return Colors.red;
      case "Receive":
        return Colors.blue;
      case "Payment":
        return Colors.deepPurple;
      case "Exchange":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 54,
            ),
            const SizedBox(height: 16),
            Text(
              "No Transactions Yet",
              style: AppTextStyles.title,
            ),
            const SizedBox(height: 8),
            Text(
              "Your transfers, payments and top-ups will appear here.",
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

   return Container(
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Recent Activity",
            style: AppTextStyles.title,
          ),
          TextButton(
            onPressed: () {},
            child: const Text("View All"),
          ),
        ],
      ),

      const SizedBox(height: 20),

      ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: transactions.length,
        separatorBuilder: (_, _) => const Divider(height: 24),
        itemBuilder: (context, index) {

          final tx = transactions[index];

          return Row(
            children: [

              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  getTransactionIcon(tx.type),
                  color: getTransactionColor(tx.type),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      tx.type,
                      style: AppTextStyles.title,
                    ),

                    const SizedBox(height: 4),

                    Text(
                      tx.description,
                      style: AppTextStyles.body,
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "Today • ${tx.status}",
                      style: AppTextStyles.caption,
                    ),

                  ],
                ),
              ),

              Text(
                "+ ${tx.currency} ${tx.amount.toStringAsFixed(2)}",
                style: AppTextStyles.title.copyWith(
                  color: getTransactionColor(tx.type),
                  fontWeight: FontWeight.bold,
                ),
              ),

            ],
          );

        },
      ),

    ],
  ),
);
  }
}

