import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/app_currency.dart';
import '../../../core/models/transaction_model.dart';
import '../../../core/models/transaction_status.dart';
import '../../../core/providers/wallet_dashboard_provider.dart';
import '../../../core/services/transaction_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../../profile/presentation/payment_methods_screen.dart';

class AddFundsScreen extends ConsumerStatefulWidget {
  const AddFundsScreen({super.key});

  @override
  ConsumerState<AddFundsScreen> createState() => _AddFundsScreenState();
}

class _AddFundsScreenState extends ConsumerState<AddFundsScreen> {
  final _amountController = TextEditingController();
  final _transactionService = TransactionService();

  TransactionModel? _transaction;
  String? _fundingReference;
  String? _checkoutUrl;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _requestPayment() async {
    final amount = double.tryParse(_amountController.text.trim());

    if (amount == null || amount <= 0) {
      setState(() {
        _error = 'Enter an amount greater than zero.';
      });
      return;
    }

    final method = ref.read(walletDashboardProvider).defaultPaymentMethod;
    if (method == null) {
      setState(() {
        _error = 'Add a Mobile Money number in Payment methods first.';
      });
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      _fundingReference ??=
          _transactionService.generateTransactionReference();

      var transaction = await _transactionService.initiateGhanaCollection(
        amount: amount,
        reference: _fundingReference!,
        rail: method.rail,
        msisdn: method.msisdn,
      );

      String? checkoutUrl;
      String? providerError;

      try {
        final charge = await _transactionService.initiateFlutterwaveMomo(
          reference: _fundingReference!,
        );
        if (charge.configured) {
          checkoutUrl = charge.redirectUrl;
          transaction = charge.transaction ?? transaction;
        } else {
          await _transactionService.settleGhanaCollection(
            reference: _fundingReference!,
            status: TransactionStatus.cancelled,
          );
          providerError =
              'Mobile Money is not connected yet. Your wallet was not credited.';
          transaction = transaction.copyWith(
            status: TransactionStatus.cancelled,
          );
        }
      } catch (error) {
        providerError = error.toString().replaceFirst('Exception: ', '');
      }

      await ref.read(walletDashboardProvider.notifier).refresh();

      if (!mounted) return;
      setState(() {
        _transaction = transaction;
        _checkoutUrl = checkoutUrl;
        _submitting = false;
        _error = providerError;
      });
    } on PostgrestException catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = error.message;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _refreshStatus() async {
    await ref.read(walletDashboardProvider.notifier).refresh();
    final reference = _transaction?.reference;
    if (reference == null || !mounted) return;

    final match = ref
        .read(walletDashboardProvider)
        .transactions
        .where((txn) => txn.reference == reference);
    if (match.isEmpty) return;

    setState(() {
      _transaction = match.first;
    });
  }

  Future<void> _cancelUnpaidRequest() async {
    final transaction = _transaction;
    if (transaction == null || !transaction.isPending) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final updated = await _transactionService.settleGhanaCollection(
        reference: transaction.reference ?? '',
        status: TransactionStatus.cancelled,
      );
      await ref.read(walletDashboardProvider.notifier).refresh();
      if (!mounted) return;
      setState(() {
        _transaction = updated;
        _submitting = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = ref.watch(walletDashboardProvider);
    final method = dashboard.defaultPaymentMethod;
    final transaction = _transaction;
    final waitingForProvider = transaction != null &&
        transaction.isPending &&
        (transaction.provider == TransactionProviders.flutterwave ||
            transaction.provider == TransactionProviders.ghanaCollectorTest);

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Add Funds'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            'Mobile Money',
            style: AppTextStyles.title,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Add Ghana cedis with MTN, Telecel, or AirtelTigo. The wallet credits only after the payment provider confirms. Nothing is simulated.',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          if (transaction == null) ...[
            Text('Amount (GHS)', style: AppTextStyles.caption),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: InputDecoration(
                hintText: '0.00',
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 18,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  borderSide: const BorderSide(
                    color: AppColors.accent,
                    width: 1.4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Pay from', style: AppTextStyles.caption),
            const SizedBox(height: AppSpacing.sm),
            if (method == null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No Mobile Money number is linked.',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Save your MTN, Telecel, or AirtelTigo number first. Then we charge that number to add Ghana cedis.',
                      style: AppTextStyles.caption,
                    ),
                    TextButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PaymentMethodsScreen(),
                          ),
                        );
                        await ref
                            .read(walletDashboardProvider.notifier)
                            .refresh();
                      },
                      child: const Text('Add payment method'),
                    ),
                  ],
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            method.network.name,
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            method.displayNumber,
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PaymentMethodsScreen(),
                          ),
                        );
                        await ref
                            .read(walletDashboardProvider.notifier)
                            .refresh();
                      },
                      child: const Text('Change'),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.xl),
            if (_error != null) ...[
              Text(
                _error!,
                style: AppTextStyles.body.copyWith(color: AppColors.error),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            IgnorePointer(
              ignoring: _submitting,
              child: Opacity(
                opacity: _submitting ? 0.6 : 1,
                child: PrimaryButton(
                  text: _submitting
                      ? 'Requesting...'
                      : method == null
                          ? 'Add a payment method first'
                          : 'Request MoMo payment',
                  onPressed: _requestPayment,
                ),
              ),
            ),
          ] else ...[
            _FundingStatusCard(transaction: transaction),
            const SizedBox(height: AppSpacing.lg),
            if (_error != null) ...[
              Text(
                _error!,
                style: AppTextStyles.body.copyWith(color: AppColors.error),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            if (waitingForProvider) ...[
              Text(
                transaction.provider == TransactionProviders.flutterwave
                    ? 'Waiting for Mobile Money confirmation. Approve the prompt on your phone. GHS credits only after the provider confirms.'
                    : 'The payment provider did not attach this request. Your wallet will not be credited until a real collection is confirmed.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (_checkoutUrl != null && _checkoutUrl!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                SelectableText(
                  _checkoutUrl!,
                  style: AppTextStyles.caption,
                ),
                TextButton(
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: _checkoutUrl!),
                    );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Checkout URL copied.'),
                      ),
                    );
                  },
                  child: const Text('Copy checkout URL'),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              TextButton(
                onPressed: _submitting ? null : _refreshStatus,
                child: const Text('Refresh status'),
              ),
              if (transaction.provider ==
                  TransactionProviders.ghanaCollectorTest)
                TextButton(
                  onPressed: _submitting ? null : _cancelUnpaidRequest,
                  child: const Text('Cancel unpaid request'),
                ),
            ] else
              Text(
                transaction.status == TransactionStatus.completed
                    ? 'GHS ${transaction.amount.toStringAsFixed(2)} is now in your KwanPay wallet.'
                    : 'This request is ${transaction.status}. Your Ghana cedi balance was not changed.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _FundingStatusCard extends StatelessWidget {
  final TransactionModel transaction;

  const _FundingStatusCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(transaction.status, style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${AppCurrencies.home.code} ${transaction.amount.toStringAsFixed(2)}',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            transaction.description,
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 4),
          Text(
            transaction.reference ?? 'No reference',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
