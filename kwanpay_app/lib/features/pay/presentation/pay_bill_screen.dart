import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/app_currency.dart';
import '../../../core/providers/wallet_dashboard_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/kwan_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../models/operator_model.dart';
import 'review_payment_screen.dart';

class PayBillScreen extends ConsumerStatefulWidget {
  final TourismOperator operator;

  const PayBillScreen({
    super.key,
    required this.operator,
  });

  @override
  ConsumerState<PayBillScreen> createState() => _PayBillScreenState();
}

class _PayBillScreenState extends ConsumerState<PayBillScreen> {
  final _accountController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ref.read(walletDashboardProvider.notifier).refresh();
  }

  @override
  void dispose() {
    _accountController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String? _normalizedBookingReference() {
    final account = _accountController.text
        .trim()
        .replaceAll(RegExp(r'[^A-Za-z0-9]'), '')
        .toUpperCase();
    if (account.length < 6 || account.length > 24) {
      return null;
    }

    return account;
  }

  void _continue() {
    final dashboard = ref.read(walletDashboardProvider);
    final account = _normalizedBookingReference();
    if (account == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Enter a valid ${widget.operator.accountLabel.toLowerCase()}.',
          ),
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter an amount greater than zero.')),
      );
      return;
    }

    if (amount > dashboard.canonicalBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient Ghana cedi balance.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewPaymentScreen(
          operator: widget.operator,
          accountNumber: account,
          amount: amount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = ref.watch(walletDashboardProvider);
    final available = dashboard.canonicalBalance;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.operator.name),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.operator.name,
                style: AppTextStyles.headline,
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.operator.category} · ${widget.operator.location}',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 8),
              Text(
                'Pays ${widget.operator.name} in Ghana cedis from your KwanPay wallet. The operator receives GHS. Stellar settlement stays underneath later corridors.',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 24),
              Text(
                'Available ${AppCurrencies.home.code} ${available.toStringAsFixed(2)}',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 24),
              KwanTextField(
                label: widget.operator.accountLabel,
                icon: widget.operator.icon,
                controller: _accountController,
              ),
              const SizedBox(height: 16),
              KwanTextField(
                label: 'Amount (GHS)',
                icon: Icons.attach_money,
                controller: _amountController,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Continue',
                onPressed: _continue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
