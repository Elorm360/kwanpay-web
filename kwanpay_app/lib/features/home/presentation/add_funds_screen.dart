import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final _fincraOtpController = TextEditingController();
  final _transactionService = TransactionService();

  TransactionModel? _transaction;
  String? _fundingReference;

  bool _submitting = false;
  bool _fincraOtpRequired = false;
  bool _authorizingFincraOtp = false;
  bool _loadingExistingTransaction = true;

  String? _error;

  @override
  void initState() {
    super.initState();
    _recoverPendingTransaction();
  }

  Future<void> _recoverPendingTransaction() async {
    try {
      final transaction = await _transactionService.getPendingFincraTopUp();

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
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _fincraOtpController.dispose();
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
      _fincraOtpRequired = false;
    });

    try {
      _fundingReference ??= _transactionService.generateTransactionReference();

      final result = await _transactionService.initiateFincraMomo(
        amount: amount,
        reference: _fundingReference!,
        rail: method.rail,
        msisdn: method.msisdn,
      );

      await ref.read(walletDashboardProvider.notifier).refresh();

      if (!mounted) return;

      setState(() {
        _transaction = result.transaction;
        _fincraOtpRequired = result.otpRequired;
        _submitting = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _submitting = false;
        _fundingReference = null;
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _authorizeAndVerify() async {
    final transaction = _transaction;

    if (transaction == null) return;

    final reference = transaction.reference;

    if (reference == null || reference.isEmpty) {
      setState(() {
        _error = 'This payment is missing its reference.';
      });
      return;
    }

    final otp = _fincraOtpController.text.trim();

    if (!RegExp(r'^\d{4,8}$').hasMatch(otp)) {
      setState(() {
        _error = 'Enter the verification code sent to your phone.';
      });
      return;
    }

    setState(() {
      _submitting = true;
      _authorizingFincraOtp = true;
      _error = null;
    });

    try {
      final authorized = await _transactionService.authorizeFincraMomo(
        reference: reference,
        otp: otp,
      );

      if (!mounted) return;

      setState(() {
        _transaction = authorized.transaction;
      });

      final verified = await _transactionService.verifyFincraMomo(
        reference: reference,
      );

      if (!mounted) return;

      final updated = verified.transaction;

      setState(() {
        _transaction = updated;
        _submitting = false;
        _authorizingFincraOtp = false;
        _error = null;

        if (updated.status == TransactionStatus.completed) {
          _fincraOtpRequired = false;
        }
      });

      if (updated.status == TransactionStatus.completed) {
        _fincraOtpController.clear();

        await ref.read(walletDashboardProvider.notifier).refresh();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payment confirmed. GHS ${updated.amount.toStringAsFixed(2)} is in your wallet.',
            ),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _submitting = false;
        _authorizingFincraOtp = false;
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _refreshStatus() async {
    final transaction = _transaction;

    if (transaction == null) return;

    final reference = transaction.reference;

    if (reference == null || reference.isEmpty) {
      setState(() {
        _error = 'This payment is missing its reference.';
      });
      return;
    }

    if (_submitting) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final result = await _transactionService.verifyFincraMomo(
        reference: reference,
      );

      if (!mounted) return;

      final updated = result.transaction;

      setState(() {
        _transaction = updated;
        _submitting = false;
        _error = null;
      });

      if (updated.status == TransactionStatus.completed) {
        await ref.read(walletDashboardProvider.notifier).refresh();
      }

      if (!mounted) return;

      final message = updated.status == TransactionStatus.completed
          ? 'Payment confirmed. GHS ${updated.amount.toStringAsFixed(2)} is in your wallet.'
          : updated.isPending
          ? 'Payment is still pending. Approve the Mobile Money request on your phone, then refresh again.'
          : 'This payment is ${updated.status}. Your wallet was not credited.';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _submitting = false;
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _resendFincraOtp() async {
    final transaction = _transaction;
    final reference = transaction?.reference;

    if (reference == null || reference.isEmpty) {
      setState(() {
        _error = 'This payment is missing its reference.';
      });
      return;
    }

    if (_submitting) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final result = await _transactionService.resendFincraMomoOtp(
        reference: reference,
      );

      if (!mounted) return;

      setState(() {
        if (result.transaction != null) {
          _transaction = result.transaction;
        }
        _submitting = false;
        _error = null;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));

      unawaited(ref.read(walletDashboardProvider.notifier).refresh());
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

    final waitingForProvider =
        transaction != null &&
        transaction.isPending &&
        transaction.provider == 'fincra';

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
          else if (transaction == null) ...[
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
              _NoPaymentMethodCard(
                onAdd: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PaymentMethodsScreen(),
                    ),
                  );

                  await ref.read(walletDashboardProvider.notifier).refresh();
                },
              )
            else
              _PaymentMethodCard(
                methodName: method.network.name,
                number: method.displayNumber,
                onChange: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PaymentMethodsScreen(),
                    ),
                  );

                  await ref.read(walletDashboardProvider.notifier).refresh();
                },
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
                      : 'Add Funds',
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
            if (_fincraOtpRequired && transaction.isPending) ...[
              _VerificationCard(
                controller: _fincraOtpController,
                submitting: _authorizingFincraOtp || _submitting,
                onVerify: _authorizeAndVerify,
                onResend: _resendFincraOtp,
              ),
            ] else if (waitingForProvider) ...[
              Text(
                'Payment request sent',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Check your phone and approve the Mobile Money request with your PIN.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (_submitting) ...[
                const Center(child: CircularProgressIndicator()),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Checking payment…',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ] else ...[
                PrimaryButton(
                  text: 'Refresh status',
                  onPressed: _refreshStatus,
                ),
              ],
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

class _VerificationCard extends StatelessWidget {
  final TextEditingController controller;
  final bool submitting;
  final VoidCallback onVerify;
  final VoidCallback onResend;

  const _VerificationCard({
    required this.controller,
    required this.submitting,
    required this.onVerify,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Verify your phone', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Enter the verification code sent to your phone.',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            maxLength: 8,
            obscureText: true,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Verification code',
              hintText: 'Enter your code',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          IgnorePointer(
            ignoring: submitting,
            child: Opacity(
              opacity: submitting ? 0.6 : 1,
              child: PrimaryButton(
                text: submitting ? 'Checking payment…' : 'Verify payment',
                onPressed: onVerify,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: TextButton(
              onPressed: submitting ? null : onResend,
              child: const Text('Resend code'),
            ),
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
