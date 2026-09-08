import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/transaction_model.dart';
import '../../../core/providers/wallet_dashboard_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../widgets/recent_activity.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  String _filter = 'All';

  List<TransactionModel> _filtered(List<TransactionModel> transactions) {
    if (_filter == 'All') return transactions;
    return transactions.where((transaction) {
      final type = transaction.type.toLowerCase();
      switch (_filter) {
        case 'Money In':
          return type.contains('top') || type.contains('deposit') || type.contains('fund');
        case 'Money Out':
          return type.contains('withdraw') || type.contains('transfer') || type.contains('convert');
        case 'Payments':
          return type.contains('pay');
        case 'Transfers':
          return type.contains('transfer');
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = ref.watch(walletDashboardProvider);
    final transactions = _filtered(dashboard.transactions);

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: const Text('Activity'),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        color: AppColors.accent,
        onRefresh: () => ref.read(walletDashboardProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          children: [
            Text('Your money activity', style: AppTextStyles.headline),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Track funds coming in, going out, transfers, and payments from one place.',
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: const ['All', 'Money In', 'Money Out', 'Payments', 'Transfers'].length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) {
                  const filters = ['All', 'Money In', 'Money Out', 'Payments', 'Transfers'];
                  final filter = filters[index];
                  final selected = filter == _filter;
                  return ChoiceChip(
                    label: Text(filter),
                    selected: selected,
                    onSelected: (_) => setState(() => _filter = filter),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.large),
                    ),
                    side: BorderSide(
                      color: selected ? AppColors.primary : AppColors.border,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (dashboard.loading && dashboard.transactions.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (dashboard.error != null && dashboard.transactions.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Column(
                  children: [
                    const Icon(Icons.cloud_off_rounded, size: 42, color: AppColors.textSecondary),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'We could not load your activity.',
                      style: AppTextStyles.title,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Check your connection and try again.',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextButton(
                      onPressed: () => ref.read(walletDashboardProvider.notifier).refresh(),
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              )
            else if (transactions.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Column(
                  children: [
                    const Icon(Icons.receipt_long_outlined, size: 42, color: AppColors.textSecondary),
                    const SizedBox(height: AppSpacing.md),
                    Text('No activity here yet', style: AppTextStyles.title),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _filter == 'All'
                          ? 'Your completed and pending activity will appear here.'
                          : 'Try another filter to see more activity.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              )
            else
              RecentActivity(
                transactions: transactions,
                title: 'Recent activity',
              ),
          ],
        ),
      ),
    );
  }
}
