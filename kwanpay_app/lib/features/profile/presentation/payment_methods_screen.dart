import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/ghana_funding_rail.dart';
import '../../../core/providers/wallet_dashboard_provider.dart';
import '../../../core/services/payment_method_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';

class PaymentMethodsScreen extends ConsumerStatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  ConsumerState<PaymentMethodsScreen> createState() =>
      _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends ConsumerState<PaymentMethodsScreen> {
  final _phoneController = TextEditingController();
  final _service = PaymentMethodService();
  GhanaFundingRail? _detectedRail;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onNumberChanged);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onNumberChanged);
    _phoneController.dispose();
    super.dispose();
  }

  void _onNumberChanged() {
    setState(() {
      _detectedRail = GhanaFundingRail.fromMsisdn(_phoneController.text);
    });
  }

  Future<void> _save() async {
    final rail = GhanaFundingRail.fromMsisdn(_phoneController.text);
    if (rail == null) {
      setState(() {
        _error = 'Enter a valid Ghana Mobile Money number.';
      });
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await _service.saveMomo(
        msisdn: _phoneController.text,
        rail: rail.id,
      );
      await ref.read(walletDashboardProvider.notifier).refresh();
      if (!mounted) return;
      _phoneController.clear();
      setState(() {
        _saving = false;
        _detectedRail = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _makeDefault(String id) async {
    await _service.makeDefault(id);
    await ref.read(walletDashboardProvider.notifier).refresh();
  }

  Future<void> _delete(String id) async {
    await _service.deleteMethod(id);
    await ref.read(walletDashboardProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final methods = ref.watch(walletDashboardProvider).paymentMethods;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Payment methods'),
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
            'Save the Ghana MoMo number you will use to add funds and, later, withdraw. KwanPay does not credit your wallet until a payment is confirmed.',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          if (methods.isEmpty)
            Text(
              'No Mobile Money number is linked yet.',
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            )
          else
            ...methods.map((method) {
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
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
                          if (method.isDefault) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Default',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (!method.isDefault)
                      TextButton(
                        onPressed: () => _makeDefault(method.id),
                        child: const Text('Make default'),
                      ),
                    IconButton(
                      onPressed: () => _delete(method.id),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: AppSpacing.xl),
          Text('Add a number', style: AppTextStyles.caption),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]')),
            ],
            decoration: InputDecoration(
              hintText: '024 123 4567',
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
          if (_detectedRail != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Detected: ${_detectedRail!.name}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              _error!,
              style: AppTextStyles.body.copyWith(color: AppColors.error),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          IgnorePointer(
            ignoring: _saving,
            child: Opacity(
              opacity: _saving ? 0.6 : 1,
              child: PrimaryButton(
                text: _saving ? 'Saving...' : 'Save Mobile Money',
                onPressed: _save,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
