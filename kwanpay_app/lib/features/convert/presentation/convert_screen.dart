import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/app_currency.dart';
import '../../../core/providers/wallet_dashboard_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class ConvertScreen extends ConsumerStatefulWidget {
  const ConvertScreen({super.key});

  @override
  ConsumerState<ConvertScreen> createState() => _ConvertScreenState();
}

class _ConvertScreenState extends ConsumerState<ConvertScreen> {
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final balance = ref.read(walletDashboardProvider).canonicalBalance;
      if (balance > 0) {
        _amountController.text = balance.toStringAsFixed(2);
      } else {
        _amountController.text = '100';
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get _amount {
    return double.tryParse(_amountController.text.trim()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = ref.watch(walletDashboardProvider);
    final amount = _amount;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Rates'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            'What your cedis are worth',
            style: AppTextStyles.headline,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Your wallet stays in Ghana cedis. These are live estimates for travel, not a currency exchange.',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('If you hold', style: AppTextStyles.caption),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              prefixText: 'GHS  ',
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
          ...AppCurrencies.display.where((currency) {
            return currency.code != AppCurrencies.home.code;
          }).map((currency) {
            final hasRate = (dashboard.displayRates[currency.code] ?? 0) > 0;
            final converted = dashboard.convertFromHome(amount, currency.code);
            final rate = dashboard.displayRates[currency.code] ?? 0;

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currency.name,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hasRate
                              ? '1 GHS = ${rate.toStringAsFixed(rate >= 1 ? 2 : 4)} ${currency.code}'
                              : 'Rate unavailable',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    hasRate
                        ? '${currency.code} ${converted.toStringAsFixed(2)}'
                        : '—',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: AppSpacing.md),
          Text(
            'When you pay an operator in another country, KwanPay will convert internally at the quoted rate. You still pay in cedis.',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
