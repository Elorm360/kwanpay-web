import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/wallet_dashboard_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../widgets/recent_activity.dart';

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(walletDashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: const Text('Activity'),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        color: AppColors.accent,
        onRefresh: () {
          return ref.read(walletDashboardProvider.notifier).refresh();
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          children: [
            if (dashboard.loading && dashboard.transactions.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (dashboard.error != null && dashboard.transactions.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Column(
                  children: [
                    Text(
                      dashboard.error!,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        ref.read(walletDashboardProvider.notifier).refresh();
                      },
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              )
            else
              RecentActivity(
                transactions: dashboard.transactions,
                title: 'Your activity',
              ),
          ],
        ),
      ),
    );
  }
}
