import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../core/models/transaction_model.dart';
import '../../core/models/transaction_status.dart';
import '../../core/providers/wallet_dashboard_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/primary_button.dart';
import 'receipt_details.dart';
import 'receipt_pdf.dart';

class ReceiptScreen extends ConsumerStatefulWidget {
  final TransactionModel transaction;

  /// Shown on a transfer receipt when the screen that opened it knows the
  /// recipient's name; otherwise the wallet ID is used.
  final String? counterpartyName;

  const ReceiptScreen({
    super.key,
    required this.transaction,
    this.counterpartyName,
  });

  @override
  ConsumerState<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends ConsumerState<ReceiptScreen> {
  bool _sharing = false;

  ReceiptDetails _details() {
    final dashboard = ref.read(walletDashboardProvider);
    return ReceiptDetails.from(
      widget.transaction,
      ownerName: dashboard.profile?.fullName,
      ownWalletId: dashboard.wallet?.walletId,
      counterpartyName: widget.counterpartyName,
    );
  }

  Future<void> _share() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      final bytes = await buildReceiptPdf(widget.transaction, _details());
      await Printing.sharePdf(
        bytes: bytes,
        filename: receiptFileName(widget.transaction),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('We could not create the receipt. Try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  void _copy(ReceiptLine line) {
    Clipboard.setData(ClipboardData(text: line.value));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${line.label} copied')));
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(walletDashboardProvider);
    final details = _details();
    final status = details.status;
    final (icon, colour) = switch (status) {
      TransactionStatus.completed => (Icons.check_rounded, AppColors.success),
      TransactionStatus.failed ||
      TransactionStatus.cancelled => (Icons.close_rounded, AppColors.error),
      _ => (Icons.hourglass_top_rounded, AppColors.accent),
    };

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(title: const Text('Receipt')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.large),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: colour.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: colour, size: 30),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    details.title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Semantics(
                    label: details.amount.replaceFirst('-', 'minus'),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        details.amount,
                        style: details.noMoneyMoved
                            ? AppTextStyles.headline.copyWith(
                                color: AppColors.textSecondary,
                                decoration: TextDecoration.lineThrough,
                              )
                            : AppTextStyles.headline,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: colour.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      status,
                      style: AppTextStyles.caption.copyWith(
                        color: colour == AppColors.accent
                            ? AppColors.textPrimary
                            : colour,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (details.statusNote != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      details.statusNote!,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.large),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < details.lines.length; i++) ...[
                    if (i > 0) const Divider(height: 1),
                    _LineRow(
                      line: details.lines[i],
                      onCopy: details.lines[i].copyable
                          ? () => _copy(details.lines[i])
                          : null,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            IgnorePointer(
              ignoring: _sharing,
              child: Opacity(
                opacity: _sharing ? 0.6 : 1,
                child: PrimaryButton(
                  text: _sharing ? 'Preparing…' : 'Share receipt',
                  onPressed: _share,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Sends a PDF you can save or send by WhatsApp or email.',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LineRow extends StatelessWidget {
  final ReceiptLine line;
  final VoidCallback? onCopy;

  const _LineRow({required this.line, this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              line.label,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 3,
            child: Text(
              line.value,
              textAlign: TextAlign.right,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          if (onCopy != null)
            IconButton(
              tooltip: 'Copy ${line.label.toLowerCase()}',
              visualDensity: VisualDensity.compact,
              onPressed: onCopy,
              icon: const Icon(
                Icons.copy_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}
