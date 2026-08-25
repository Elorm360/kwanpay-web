import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/app_currency.dart';
import '../../../core/providers/wallet_dashboard_provider.dart';
import '../../../core/services/transaction_service.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../models/operator_model.dart';
import 'payment_success_screen.dart';

class ReviewPaymentScreen extends ConsumerStatefulWidget {
  final TourismOperator operator;
  final String accountNumber;
  final double amount;

  const ReviewPaymentScreen({
    super.key,
    required this.operator,
    required this.accountNumber,
    required this.amount,
  });

  @override
  ConsumerState<ReviewPaymentScreen> createState() =>
      _ReviewPaymentScreenState();
}

class _ReviewPaymentScreenState extends ConsumerState<ReviewPaymentScreen> {
  final _transactionService = TransactionService();
  late final String _paymentReference;
  bool _paying = false;

  @override
  void initState() {
    super.initState();
    _paymentReference = _transactionService.generateTransactionReference();
  }

  Future<void> _confirm() async {
    if (_paying) return;

    setState(() {
      _paying = true;
    });

    try {
      await _transactionService.payOperatorBill(
        operatorCode: widget.operator.code,
        accountNumber: widget.accountNumber,
        amount: widget.amount,
        currency: AppCurrencies.home.code,
        reference: _paymentReference,
      );

      await ref.read(walletDashboardProvider.notifier).refresh();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentSuccessScreen(
            operatorName: widget.operator.name,
            amount: widget.amount,
            currency: AppCurrencies.home.code,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _paying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Payment'),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Review Payment',
                style: AppTextStyles.headline,
              ),
              const SizedBox(height: 8),
              Text(
                'Pays ${widget.operator.name} in Ghana cedis. Your wallet is debited and TransVista is credited. No simulated success.',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 32),
              Text(
                'Operator',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 8),
              Text(
                widget.operator.name,
                style: AppTextStyles.title,
              ),
              Text(
                widget.operator.accountLabel,
                style: AppTextStyles.body,
              ),
              Text(
                widget.accountNumber,
                style: AppTextStyles.body,
              ),
              const Divider(height: 40),
              Text(
                'Amount',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 8),
              Text(
                '${AppCurrencies.home.code} ${widget.amount.toStringAsFixed(2)}',
                style: AppTextStyles.title,
              ),
              const SizedBox(height: 16),
              Text(
                'Reference',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 8),
              Text(
                _paymentReference,
                style: AppTextStyles.body,
              ),
              const Spacer(),
              _paying
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : PrimaryButton(
                      text: 'Pay TransVista',
                      onPressed: _confirm,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
