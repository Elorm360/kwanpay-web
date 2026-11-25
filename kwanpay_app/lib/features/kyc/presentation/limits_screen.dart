import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/kyc_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import 'verify_id_screen.dart';

String ghs(double amount) {
  final whole = amount.truncate();
  final digits = whole.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  final pesewas = ((amount - whole) * 100).round();
  return pesewas == 0
      ? 'GHS $digits'
      : 'GHS $digits.${pesewas.toString().padLeft(2, '0')}';
}

class LimitsScreen extends ConsumerWidget {
  const LimitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(kycStatusProvider);

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(title: const Text('Limits and verification')),
      body: SafeArea(
        child: status.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) =>
              _LoadError(onRetry: () => ref.invalidate(kycStatusProvider)),
          data: (s) => RefreshIndicator(
            color: AppColors.accent,
            onRefresh: () => ref.refresh(kycStatusProvider.future),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              children: [
                _TierHeader(status: s),
                const SizedBox(height: AppSpacing.lg),
                _Card(
                  children: [
                    _UsageRow(
                      label: 'Today',
                      used: s.usedToday,
                      limit: s.dailyLimit,
                    ),
                    const Divider(height: AppSpacing.xl),
                    _UsageRow(
                      label: 'This month',
                      used: s.usedThisMonth,
                      limit: s.monthlyLimit,
                    ),
                    const Divider(height: AppSpacing.xl),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Largest single payment',
                            style: AppTextStyles.body,
                          ),
                        ),
                        Text(
                          ghs(s.perTransactionLimit),
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Limits cover money you send, pay and withdraw. Money coming in is not limited. Days and months reset at midnight GMT.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _VerificationCard(status: s),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TierHeader extends StatelessWidget {
  final KycStatus status;
  const _TierHeader({required this.status});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: status.idVerified
                ? AppColors.success.withValues(alpha: 0.12)
                : AppColors.accent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: Icon(
            status.idVerified
                ? Icons.verified_rounded
                : Icons.verified_user_outlined,
            color: status.idVerified ? AppColors.success : AppColors.accent,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${status.tierName} account', style: AppTextStyles.title),
              const SizedBox(height: 2),
              Text(
                'Level ${status.tier} of 3',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UsageRow extends StatelessWidget {
  final String label;
  final double used;
  final double limit;

  const _UsageRow({
    required this.label,
    required this.used,
    required this.limit,
  });

  @override
  Widget build(BuildContext context) {
    final share = limit <= 0 ? 0.0 : (used / limit).clamp(0.0, 1.0);
    final left = (limit - used).clamp(0, limit).toDouble();

    return Semantics(
      label: '$label: ${ghs(used)} used of ${ghs(limit)}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: AppTextStyles.body)),
              Text(
                '${ghs(left)} left',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: share,
              minHeight: 6,
              backgroundColor: AppColors.border,
              color: share >= 0.9 ? AppColors.accent : AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${ghs(used)} of ${ghs(limit)} used',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerificationCard extends ConsumerWidget {
  final KycStatus status;
  const _VerificationCard({required this.status});

  Future<void> _openVerify(BuildContext context, WidgetRef ref) async {
    final sent = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const VerifyIdScreen()),
    );
    if (sent == true) ref.invalidate(kycStatusProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (status.idVerified) {
      return _Card(
        children: [
          Text('Your ID is verified', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'You have the higher limits that come with a checked ID.',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
        ],
      );
    }

    if (status.underReview) {
      return _Card(
        children: [
          Row(
            children: [
              const Icon(
                Icons.hourglass_top_rounded,
                color: AppColors.accent,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('We are checking your ID', style: AppTextStyles.title),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'A person on our team reviews every document. Your limits go up as soon as it is approved, and you can keep using KwanPay meanwhile.',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
        ],
      );
    }

    final tiers = ref.watch(kycTiersProvider).valueOrNull ?? const [];
    final next = tiers.where((t) => t.tier == 2).firstOrNull;

    return _Card(
      children: [
        Text(
          status.rejected ? 'Your ID needs another try' : 'Raise your limits',
          style: AppTextStyles.title,
        ),
        const SizedBox(height: AppSpacing.xs),
        if (status.rejected && (status.rejectionReason ?? '').isNotEmpty) ...[
          Text(
            status.rejectionReason!,
            style: AppTextStyles.body.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        Text(
          next == null
              ? 'Verify your Ghana Card or passport to raise your limits.'
              : 'Verify your Ghana Card or passport to send up to ${ghs(next.dailyLimit)} a day and ${ghs(next.monthlyLimit)} a month.',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.md),
        PrimaryButton(
          text: status.rejected ? 'Send new photos' : 'Verify your ID',
          onPressed: () => _openVerify(context, ref),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  final VoidCallback onRetry;
  const _LoadError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("We couldn't load your limits", style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.md),
            TextButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
