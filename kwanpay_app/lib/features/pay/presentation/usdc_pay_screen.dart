import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/providers/wallet_dashboard_provider.dart';
import '../../../core/services/stellar/stellar_assets.dart';
import '../../../core/services/stellar/stellar_testnet_wallet_service.dart';
import '../../../core/services/transaction_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/money_error.dart';
import '../../../core/widgets/kwan_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import 'payment_success_screen.dart';

/// Where a USDC payment is in its life. Each step is safe to retry: the
/// KwanPay record and the Stellar memo share one reference, and once a hash
/// exists only the verification is repeated, never the payment.
enum _Step { idle, recording, submitting, verifying }

/// Pay a tourism business in Testnet USDC from the user's own Stellar
/// account, then have the server confirm it on Horizon.
class UsdcPayScreen extends ConsumerStatefulWidget {
  const UsdcPayScreen({super.key});

  @override
  ConsumerState<UsdcPayScreen> createState() => _UsdcPayScreenState();
}

class _UsdcPayScreenState extends ConsumerState<UsdcPayScreen> {
  final _wallet = StellarTestnetWalletService();
  final _transactions = TransactionService();
  final _bookingController = TextEditingController();
  final _amountController = TextEditingController();

  // Account
  bool _preparing = true;
  String? _accountError;
  String? _publicKey;
  double _usdc = 0;
  bool _refreshingBalance = false;

  // Businesses
  List<Map<String, String>> _businesses = const [];
  String? _businessCode;

  // Payment attempt
  _Step _step = _Step.idle;
  String? _reference;
  String? _pendingHash;
  String? _error;

  bool get _busy => _step != _Step.idle;

  @override
  void initState() {
    super.initState();
    _prepare();
    for (final c in [_bookingController, _amountController]) {
      c.addListener(_inputsChanged);
    }
  }

  @override
  void dispose() {
    _bookingController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  /// A new amount or booking needs a new reference, unless a payment was
  /// already submitted: then the inputs are locked until it is verified.
  void _inputsChanged() {
    if (_pendingHash == null && _reference != null) _reference = null;
  }

  Future<void> _prepare() async {
    setState(() {
      _preparing = true;
      _accountError = null;
    });
    try {
      // Creates and funds the Testnet account and opens the USDC trustline
      // the first time; quick after that.
      final key = await _wallet.publicKey();
      final results = await Future.wait([
        _wallet.usdcBalance(),
        _transactions.getTourismStellarAccounts(),
      ]);
      if (!mounted) return;
      setState(() {
        _publicKey = key;
        _usdc = results[0] as double;
        _businesses = results[1] as List<Map<String, String>>;
        _businessCode ??= _businesses.isEmpty
            ? null
            : _businesses.first['code'];
        _preparing = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _preparing = false;
        _accountError = moneyErrorMessage(error);
      });
    }
  }

  Future<void> _refreshBalance() async {
    setState(() => _refreshingBalance = true);
    try {
      final balance = await _wallet.usdcBalance();
      if (mounted) setState(() => _usdc = balance);
    } catch (_) {
      // Keep the last known balance; the pay step re-checks it anyway.
    } finally {
      if (mounted) setState(() => _refreshingBalance = false);
    }
  }

  void _copyAddress() {
    final key = _publicKey;
    if (key == null) return;
    Clipboard.setData(ClipboardData(text: key));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Stellar address copied')));
  }

  Future<void> _openFaucet() async {
    final opened = await launchUrl(
      Uri.parse(StellarAssets.circleFaucetUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the faucet.')),
      );
    }
  }

  Map<String, String>? get _business {
    for (final b in _businesses) {
      if (b['code'] == _businessCode) return b;
    }
    return null;
  }

  String? _problem() {
    if (_business == null) return 'Choose a business to pay.';
    final booking = _bookingController.text.replaceAll(
      RegExp(r'[^A-Za-z0-9]'),
      '',
    );
    if (booking.length < 6 || booking.length > 24) {
      return 'Enter the booking reference (6 to 24 letters or numbers).';
    }
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      return 'Enter an amount greater than zero.';
    }
    if (amount != double.parse(amount.toStringAsFixed(2))) {
      return 'Use at most two decimal places.';
    }
    if (_pendingHash == null && amount > _usdc) {
      return 'You have ${_usdc.toStringAsFixed(2)} Testnet USDC. Get more from the faucet first.';
    }
    return null;
  }

  Future<void> _pay() async {
    final problem = _problem();
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    final business = _business!;
    final amount = double.parse(_amountController.text.trim());
    _reference ??= _transactions.generateTransactionReference();
    final reference = _reference!;

    setState(() => _error = null);
    try {
      var hash = _pendingHash;
      if (hash == null) {
        setState(() => _step = _Step.recording);
        await _transactions.initiateStellarUsdcPayment(
          operatorCode: business['code']!,
          bookingReference: _bookingController.text,
          amount: amount,
          reference: reference,
        );

        setState(() => _step = _Step.submitting);
        hash = await _wallet.payUsdc(
          destination: business['stellar_public_key']!,
          amount: amount,
          reference: reference,
        );
        _pendingHash = hash;
      }

      setState(() => _step = _Step.verifying);
      final transaction = await _transactions.verifyStellarUsdcPayment(
        reference: reference,
        txHash: hash,
      );

      await ref.read(walletDashboardProvider.notifier).refresh();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentSuccessScreen(
            operatorName: business['name']!,
            amount: amount,
            currency: 'USDC',
            txHash: hash,
            transaction: transaction,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _step = _Step.idle;
        _error = _pendingHash == null
            ? moneyErrorMessage(error)
            : 'Your payment was sent but is not confirmed yet. '
                  'Tap Check again in a moment. (${moneyErrorMessage(error)})';
      });
    }
  }

  String get _buttonLabel => switch (_step) {
    _Step.recording => 'Recording payment…',
    _Step.submitting => 'Sending on Stellar…',
    _Step.verifying => 'Confirming on Horizon…',
    _Step.idle => _pendingHash != null ? 'Check again' : 'Pay with USDC',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(title: const Text('Pay with USDC')),
      body: SafeArea(
        child: _preparing
            ? const _Preparing()
            : _accountError != null
            ? _AccountError(message: _accountError!, onRetry: _prepare)
            : ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                children: [
                  const _TestNetworkNote(),
                  const SizedBox(height: AppSpacing.md),
                  _AccountCard(
                    publicKey: _publicKey!,
                    usdc: _usdc,
                    refreshing: _refreshingBalance,
                    onCopy: _copyAddress,
                    onRefresh: _refreshBalance,
                    onFaucet: _openFaucet,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'PAY',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _BusinessPicker(
                    businesses: _businesses,
                    selected: _businessCode,
                    enabled: !_busy && _pendingHash == null,
                    onChanged: (code) => setState(() {
                      _businessCode = code;
                      _inputsChanged();
                    }),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  IgnorePointer(
                    ignoring: _busy || _pendingHash != null,
                    child: Column(
                      children: [
                        KwanTextField(
                          label: 'Booking reference',
                          icon: Icons.confirmation_number_outlined,
                          controller: _bookingController,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        KwanTextField(
                          label: 'Amount (USDC)',
                          icon: Icons.attach_money,
                          controller: _amountController,
                        ),
                      ],
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _error!,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  IgnorePointer(
                    ignoring: _busy,
                    child: Opacity(
                      opacity: _busy ? 0.6 : 1,
                      child: PrimaryButton(text: _buttonLabel, onPressed: _pay),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'The payment goes straight from your Stellar account to the business. KwanPay then checks it on Stellar before marking it paid.',
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

class _Preparing extends StatelessWidget {
  const _Preparing();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Setting up your Stellar account',
              style: AppTextStyles.title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'The first time takes a few seconds: we open a Testnet account and let it hold USDC.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _AccountError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "We couldn't reach Stellar",
              style: AppTextStyles.title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(text: 'Try again', onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}

class _TestNetworkNote extends StatelessWidget {
  const _TestNetworkNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.science_outlined, color: AppColors.accent, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Stellar test network. This is test USDC with no real value, and your GHS balance is not used.',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final String publicKey;
  final double usdc;
  final bool refreshing;
  final VoidCallback onCopy;
  final VoidCallback onRefresh;
  final VoidCallback onFaucet;

  const _AccountCard({
    required this.publicKey,
    required this.usdc,
    required this.refreshing,
    required this.onCopy,
    required this.onRefresh,
    required this.onFaucet,
  });

  @override
  Widget build(BuildContext context) {
    final short =
        '${publicKey.substring(0, 6)}…${publicKey.substring(publicKey.length - 6)}';
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Testnet USDC',
                  style: AppTextStyles.body.copyWith(color: Colors.white70),
                ),
              ),
              IconButton(
                tooltip: 'Refresh balance',
                onPressed: refreshing ? null : onRefresh,
                icon: refreshing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.refresh_rounded, color: Colors.white),
              ),
            ],
          ),
          Text(
            usdc.toStringAsFixed(2),
            style: AppTextStyles.headline.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.md),
          InkWell(
            onTap: onCopy,
            borderRadius: BorderRadius.circular(AppRadius.small),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                children: [
                  Text(
                    'Your Stellar address  ',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      short,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(
                    Icons.copy_rounded,
                    size: 16,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
          ),
          if (usdc <= 0) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              'No test USDC yet. Copy your address, open the Circle faucet, choose Stellar Testnet, and paste it. Then refresh.',
              style: AppTextStyles.caption.copyWith(color: Colors.white),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: onFaucet,
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: const Text('Open Circle faucet'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BusinessPicker extends StatelessWidget {
  final List<Map<String, String>> businesses;
  final String? selected;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  const _BusinessPicker({
    required this.businesses,
    required this.selected,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (businesses.isEmpty) {
      return Text(
        'No businesses accept USDC yet.',
        style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
      );
    }
    return DropdownButtonFormField<String>(
      initialValue: selected,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Business',
        prefixIcon: const Icon(Icons.storefront_outlined),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
      items: [
        for (final b in businesses)
          DropdownMenuItem(value: b['code'], child: Text(b['name']!)),
      ],
      onChanged: enabled ? onChanged : null,
    );
  }
}
