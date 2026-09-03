import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../Core/models/payment_method.dart';
import '../../../Core/providers/wallet_dashboard_provider.dart';
import '../../../Core/services/transaction_service.dart';
import '../../../Core/theme/app_colors.dart';
import '../../../Core/theme/app_radius.dart';
import '../../../Core/theme/app_spacing.dart';
import '../../../Core/theme/app_text_styles.dart';
import '../../profile/presentation/payment_methods_screen.dart';

class WithdrawFundsScreen extends ConsumerStatefulWidget {
  const WithdrawFundsScreen({super.key});

  @override
  ConsumerState<WithdrawFundsScreen> createState() => _WithdrawFundsScreenState();
}

class _WithdrawFundsScreenState extends ConsumerState<WithdrawFundsScreen> {
  final _amountController = TextEditingController();
  final _transactionService = TransactionService();
  PaymentMethod? _selectedMethod;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final methods = ref.read(walletDashboardProvider).paymentMethods;
    _selectedMethod = methods.isNotEmpty
        ? (methods.firstWhere(
            (method) => method.isDefault,
            orElse: () => methods.first,
          ))
        : null;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _openPaymentMethods() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()),
    );
    await ref.read(walletDashboardProvider.notifier).refresh();
    if (!mounted) return;
    final methods = ref.read(walletDashboardProvider).paymentMethods;
    setState(() {
      _selectedMethod = methods.isEmpty
          ? null
          : (methods.firstWhere(
              (method) => method.isDefault,
              orElse: () => methods.first,
            ));
    });
  }

  double _amount() => double.tryParse(_amountController.text.trim()) ?? 0;

  Future<void> _submit() async {
    final amount = _amount();
    final dashboard = ref.read(walletDashboardProvider);
    final balance = dashboard.balanceFor('GHS');
    final method = _selectedMethod;

    if (amount <= 0) {
      setState(() => _error = 'Enter a withdrawal amount.');
      return;
    }
    if (amount > balance + 0.000001) {
      setState(() => _error = 'The withdrawal amount is greater than your available GHS balance.');
      return;
    }
    if (method == null) {
      setState(() => _error = 'Add a Mobile Money payment method first.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final transaction = await _transactionService.initiateFincraPayout(
        amount: amount,
        paymentMethodId: method.id,
      );
      if (!mounted) return;
      setState(() => _submitting = false);

      final status = transaction.status.name;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'completed'
                ? 'Withdrawal completed. GHS ${amount.toStringAsFixed(2)} was sent to ${method.displayNumber}.'
                : 'Withdrawal started. We will update you when the payment is complete.',
          ),
        ),
      );
      await ref.read(walletDashboardProvider.notifier).refresh();
      if (!mounted) return;
      Navigator.pop(context, transaction);
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
    final balance = dashboard.balanceFor('GHS');
    final methods = dashboard.paymentMethods;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: const Text('Withdraw Funds'),
        backgroundColor: AppColors.paper,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.large),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available to withdraw',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'GHS ${balance.toStringAsFixed(2)}',
                      style: AppTextStyles.walletBalance,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      'Your KwanPay balance is sent to a Ghana Mobile Money wallet.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('AMOUNT', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                decoration: const InputDecoration(
                  prefixText: 'GHS ',
                  hintText: '0.00',
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('SEND TO', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700)),
                  TextButton.icon(
                    onPressed: _openPaymentMethods,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Manage'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              if (methods.isEmpty)
                _EmptyMethodCard(onAdd: _openPaymentMethods)
              else
                ...methods.map(
                  (method) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _MethodCard(
                      method: method,
                      selected: method.id == _selectedMethod?.id,
                      onTap: () => setState(() => _selectedMethod = method),
                    ),
                  ),
                ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Withdraw funds'),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Withdrawals are processed securely. Your balance is reserved when the request is created and returned automatically if the payout fails.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  const _MethodCard({required this.method, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: const Icon(Icons.phone_android_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(method.network.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(method.displayNumber, style: const TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? AppColors.accent : AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyMethodCard extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyMethodCard({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.account_balance_wallet_outlined, size: 30, color: AppColors.textSecondary),
          const SizedBox(height: AppSpacing.sm),
          const Text('No Mobile Money method saved', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.xs),
          const Text('Add one so KwanPay knows where to send your withdrawal.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton(onPressed: onAdd, child: const Text('Add Mobile Money')),
        ],
      ),
    );
  }
}
