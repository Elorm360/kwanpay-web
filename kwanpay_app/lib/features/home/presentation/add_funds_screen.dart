import 'package:flutter/material.dart';
import '../../../core/utils/money_error.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/models/app_currency.dart';
import '../../../core/models/transaction_model.dart';
import '../../../core/models/transaction_status.dart';
import '../../../core/payments/payment_gateway.dart';
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
  bool _loadingExistingTransaction = true;

  String? _error;

  @override
  void initState() {
    super.initState();
    _recoverPendingTransaction();
  }

  Future<void> _recoverPendingTransaction() async {
    try {
      final transaction = await _transactionService.getPendingTopUp();
      if (!mounted) return;
      setState(() {
        _transaction = transaction;
        _fundingReference = transaction?.reference ?? _fundingReference;
        _loadingExistingTransaction = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingExistingTransaction = false;
        _error = _message(error);
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String _message(Object error) => moneyErrorMessage(error);

  Future<void> _requestPayment(PaymentGateway gateway) async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter an amount greater than zero.');
      return;
    }

    final method = ref.read(walletDashboardProvider).defaultPaymentMethod;
    if (method == null) {
      setState(() => _error = 'Add a Mobile Money number in Payment methods first.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      _fundingReference ??= _transactionService.generateTransactionReference();
      final session = await gateway.startTopUp(
        amount: amount,
        reference: _fundingReference!,
        rail: method.rail,
        msisdn: method.msisdn,
      );
      await ref.read(walletDashboardProvider.notifier).refresh();
      if (!mounted) return;
      setState(() {
        _transaction = session.transaction;
        _checkoutUrl = session.checkoutUrl;
        _submitting = false;
      });
      await _openCheckout();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _fundingReference = null;
        _error = _message(error);
      });
    }
  }

  Future<void> _openCheckout() async {
    final url = _checkoutUrl;
    if (url == null) return;
    final uri = Uri.tryParse(url);
    final opened = uri != null &&
        uri.scheme == 'https' &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      setState(() => _error = 'Could not open the payment page. Tap "Open payment page" to try again.');
    }
  }

  Future<void> _refreshStatus(PaymentGateway gateway) async {
    final reference = _transaction?.reference;
    if (reference == null || reference.isEmpty) {
      setState(() => _error = 'This payment is missing its reference.');
      return;
    }
    if (_submitting) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final session = await gateway.checkTopUp(reference: reference);
      if (!mounted) return;
      final updated = session.transaction;
      setState(() {
        _transaction = updated;
        _checkoutUrl = session.checkoutUrl ?? _checkoutUrl;
        _submitting = false;
      });

      if (updated.status == TransactionStatus.completed) {
        await ref.read(walletDashboardProvider.notifier).refresh();
      }
      if (!mounted) return;

      final message = updated.status == TransactionStatus.completed
          ? 'Payment confirmed. GHS ${updated.amount.toStringAsFixed(2)} is in your wallet.'
          : updated.isPending
              ? (session.message ?? 'Payment is still pending. Finish the payment, then refresh again.')
              : 'This payment is ${updated.status}. Your wallet was not credited.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = _message(error);
      });
    }
  }

  Future<void> _openPaymentMethods() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()),
    );
    await ref.read(walletDashboardProvider.notifier).refresh();
  }

  Widget _errorText() => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Text(
          _error!,
          style: AppTextStyles.body.copyWith(color: AppColors.error),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final gateway = ref.watch(paymentGatewayProvider);
    final dashboard = ref.watch(walletDashboardProvider);
    final method = dashboard.defaultPaymentMethod;
    final transaction = _transaction;

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
          Text('Mobile Money', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Add Ghana cedis using MTN, Telecel, or AirtelTigo. Your wallet is credited only after the payment is confirmed.',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          if (_loadingExistingTransaction)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: CircularProgressIndicator(),
              ),
            )
          else if (transaction != null) ...[
            _FundingStatusCard(transaction: transaction),
            const SizedBox(height: AppSpacing.lg),
            if (_error != null) _errorText(),
            if (!transaction.isPending)
              Text(
                transaction.status == TransactionStatus.completed
                    ? 'GHS ${transaction.amount.toStringAsFixed(2)} is now in your KwanPay wallet.'
                    : 'This request is ${transaction.status}. Your Ghana cedi balance was not changed.',
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              )
            else if (gateway == null || transaction.provider != gateway.id)
              Text(
                'This payment was started with a payment partner KwanPay no longer uses. '
                'Your wallet is only credited if that payment was confirmed. Contact support if money left your account.',
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              )
            else if (_submitting)
              const Center(child: CircularProgressIndicator())
            else ...[
              if (_checkoutUrl != null) ...[
                OutlinedButton.icon(
                  onPressed: _openCheckout,
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Open payment page'),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              PrimaryButton(
                text: 'Refresh status',
                onPressed: () => _refreshStatus(gateway),
              ),
            ],
          ] else if (gateway == null)
            const _TopUpsUnavailableCard()
          else ...[
            Text('Amount (GHS)', style: AppTextStyles.caption),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
              decoration: InputDecoration(
                hintText: '0.00',
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  borderSide: const BorderSide(color: AppColors.accent, width: 1.4),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Pay from', style: AppTextStyles.caption),
            const SizedBox(height: AppSpacing.sm),
            if (method == null)
              _NoPaymentMethodCard(onAdd: _openPaymentMethods)
            else
              _PaymentMethodCard(
                methodName: method.network.name,
                number: method.displayNumber,
                onChange: _openPaymentMethods,
              ),
            const SizedBox(height: AppSpacing.xl),
            if (_error != null) _errorText(),
            IgnorePointer(
              ignoring: _submitting,
              child: Opacity(
                opacity: _submitting ? 0.6 : 1,
                child: PrimaryButton(
                  text: _submitting
                      ? 'Requesting...'
                      : method == null
                          ? 'Add a payment method first'
                          : 'Add Funds',
                  onPressed: () => _requestPayment(gateway),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TopUpsUnavailableCard extends StatelessWidget {
  const _TopUpsUnavailableCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.schedule_rounded, color: AppColors.accent, size: 32),
          const SizedBox(height: AppSpacing.md),
          Text('Top-ups are coming soon', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'We are finalizing our Mobile Money partner. You can still save your Mobile Money number in Payment methods so you are ready when top-ups open.',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _NoPaymentMethodCard extends StatelessWidget {
  final VoidCallback onAdd;

  const _NoPaymentMethodCard({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Save your MTN, Telecel, or AirtelTigo number first.',
            style: AppTextStyles.caption,
          ),
          TextButton(onPressed: onAdd, child: const Text('Add payment method')),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final String methodName;
  final String number;
  final VoidCallback onChange;

  const _PaymentMethodCard({
    required this.methodName,
    required this.number,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  methodName,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(number, style: AppTextStyles.caption),
              ],
            ),
          ),
          TextButton(onPressed: onChange, child: const Text('Change')),
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
          Text(transaction.description, style: AppTextStyles.caption),
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
