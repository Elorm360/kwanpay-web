import 'package:flutter/material.dart';

import '../../../core/models/transaction_model.dart';
import '../../../core/models/transaction_status.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class RecentActivity extends StatelessWidget {
  final List<TransactionModel> transactions;
  final String title;
  final int? limit;

  const RecentActivity({
    super.key,
    required this.transactions,
    this.title = 'Recent Activity',
    this.limit,
  });

  IconData getTransactionIcon(String type) {
    switch (type) {
      case "Top Up":
        return Icons.south_west_rounded;
      case "Send":
        return Icons.north_east_rounded;
      case "Receive":
      case "Convert In":
        return Icons.south_west_rounded;
      case "Convert Out":
      case "Exchange":
        return Icons.currency_exchange;
      case "Payment":
        return Icons.credit_card_rounded;
      default:
        return Icons.receipt_long;
    }
  }

  Color getTransactionColor(String type) {
    switch (type) {
      case "Top Up":
      case "Receive":
      case "Convert In":
        return AppColors.success;
      case "Send":
      case "Payment":
      case "Convert Out":
        return AppColors.primary;
      case "Exchange":
        return AppColors.accent;
      default:
        return AppColors.textSecondary;
    }
  }

  bool _isOutgoing(String type) {
    return type == 'Send' ||
        type == 'Payment' ||
        type == 'Exchange' ||
        type == 'Convert Out';
  }

  Color _statusColor(String status) {
    switch (status) {
      case TransactionStatus.completed:
        return AppColors.success;
      case TransactionStatus.failed:
      case TransactionStatus.cancelled:
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(local.year, local.month, local.day);

    if (day == today) return 'Today';
    if (day == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return '${local.day}/${local.month}/${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 54,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              "No transactions yet",
              style: AppTextStyles.title,
            ),
            const SizedBox(height: 8),
            Text(
              "Transfers, top-ups, and payments will appear here.",
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final visible = limit == null
        ? transactions
        : transactions.take(limit!).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.title,
          ),
          const SizedBox(height: 20),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visible.length,
            separatorBuilder: (_, _) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final tx = visible[index];
              final outgoing = _isOutgoing(tx.type);
              final sign = outgoing ? '-' : '+';
              final completed = tx.isCompleted;

              return Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.paper,
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
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (TransactionProviders.isTest(tx.provider)) ...[
                          const SizedBox(height: 4),
                          Text(
                            'TEST',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          tx.description,
                          style: AppTextStyles.caption,
                        ),
                        if (tx.reference != null &&
                            tx.reference!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            tx.reference!,
                            style: AppTextStyles.caption,
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          "${_formatDate(tx.createdAt)} • ${tx.status}",
                          style: AppTextStyles.caption.copyWith(
                            color: _statusColor(tx.status),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "$sign ${tx.currency} ${tx.amount.toStringAsFixed(2)}",
                    style: AppTextStyles.body.copyWith(
                      color: !completed
                          ? AppColors.textSecondary
                          : outgoing
                              ? AppColors.textPrimary
                              : AppColors.success,
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
