import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_currency.dart';
import '../models/payment_method.dart';
import '../models/profile_model.dart';
import '../models/transaction_model.dart';
import '../models/wallet_model.dart';
import '../models/wallet_reconciliation.dart';
import '../services/payment_method_service.dart';
import '../services/profile_service.dart';
import '../services/transaction_service.dart';
import '../services/wallet_service.dart';

class WalletDashboardState {
  final WalletModel? wallet;
  final ProfileModel? profile;
  final List<PaymentMethod> paymentMethods;
  final List<TransactionModel> transactions;
  final Map<String, double> balances;
  final Map<String, double> displayRates;
  final List<WalletReconciliation> reconciliation;
  final String selectedCurrency;
  final bool loading;
  final String? error;

  const WalletDashboardState({
    this.wallet,
    this.profile,
    this.paymentMethods = const [],
    this.transactions = const [],
    this.balances = const {},
    this.displayRates = const {},
    this.reconciliation = const [],
    this.selectedCurrency = 'GHS',
    this.loading = true,
    this.error,
  });

  PaymentMethod? get defaultPaymentMethod {
    for (final method in paymentMethods) {
      if (method.isDefault) return method;
    }
    if (paymentMethods.isEmpty) return null;
    return paymentMethods.first;
  }

  String get homeCurrency => AppCurrencies.home.code;

  double get canonicalBalance => balanceFor(homeCurrency);

  double get availableBalance => convertFromHome(canonicalBalance);

  double balanceFor(String currency) {
    return balances[currency.toUpperCase()] ?? 0;
  }

  double convertFromHome(double amount, [String? currency]) {
    final code = (currency ?? selectedCurrency).toUpperCase();
    if (code == homeCurrency) return amount;

    final rate = displayRates[code];
    if (rate == null || rate <= 0) return 0;

    return (amount * rate * 100).round() / 100;
  }

  bool get hasDisplayRate {
    return selectedCurrency == homeCurrency ||
        (displayRates[selectedCurrency] ?? 0) > 0;
  }

  WalletReconciliation? reconciliationFor(String currency) {
    final code = currency.toUpperCase();
    for (final row in reconciliation) {
      if (row.currency == code) return row;
    }
    return null;
  }

  bool isBalanceMatched([String? currency]) {
    return reconciliationFor(currency ?? homeCurrency)?.matched ?? true;
  }

  double pendingAmountFor([String? currency]) {
    final pending =
        reconciliationFor(currency ?? homeCurrency)?.pendingAmount ?? 0;
    if ((currency ?? selectedCurrency) == homeCurrency) {
      return pending;
    }
    return convertFromHome(pending, currency);
  }

  WalletDashboardState copyWith({
    WalletModel? wallet,
    ProfileModel? profile,
    List<PaymentMethod>? paymentMethods,
    List<TransactionModel>? transactions,
    Map<String, double>? balances,
    Map<String, double>? displayRates,
    List<WalletReconciliation>? reconciliation,
    String? selectedCurrency,
    bool? loading,
    String? error,
    bool clearError = false,
  }) {
    return WalletDashboardState(
      wallet: wallet ?? this.wallet,
      profile: profile ?? this.profile,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      transactions: transactions ?? this.transactions,
      balances: balances ?? this.balances,
      displayRates: displayRates ?? this.displayRates,
      reconciliation: reconciliation ?? this.reconciliation,
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class WalletDashboardNotifier extends StateNotifier<WalletDashboardState> {
  WalletDashboardNotifier() : super(const WalletDashboardState()) {
    Future.microtask(refresh);
  }

  final _profileService = ProfileService();
  final _walletService = WalletService();
  final _transactionService = TransactionService();
  final _paymentMethodService = PaymentMethodService();
  int _refreshEpoch = 0;

  Future<void> refresh() async {
    final epoch = ++_refreshEpoch;
    final showLoading = state.wallet == null && state.transactions.isEmpty;
    if (showLoading) {
      state = state.copyWith(loading: true, clearError: true);
    }

    try {
      final profile = await _profileService.getProfile();
      final wallet = await _walletService.getWallet();
      final paymentMethods = await _paymentMethodService.listMethods();
      final transactions = await _transactionService.getTransactions();
      final balances = await _walletService.getWalletBalances();
      try {
        await _transactionService.refreshFxRates();
      } catch (_) {
        // Keep the last stored rates if the live feed is unreachable.
      }
      final displayRates = await _walletService.getDisplayRates(
        homeCurrency: AppCurrencies.home.code,
      );
      final reconciliation = await _walletService.reconcileWallet();
      if (epoch != _refreshEpoch) return;

      final selectedCurrency = state.profile == null
          ? AppCurrencies.resolve(
              preferredCurrency: profile?.preferredCurrency,
              country: profile?.country,
            ).code
          : state.selectedCurrency;

      state = WalletDashboardState(
        wallet: wallet,
        profile: profile,
        paymentMethods: paymentMethods,
        transactions: transactions,
        balances: balances,
        displayRates: displayRates,
        reconciliation: reconciliation,
        selectedCurrency: selectedCurrency,
        loading: false,
      );
    } catch (_) {
      if (epoch != _refreshEpoch) return;
      state = state.copyWith(
        loading: false,
        error: 'Could not load wallet activity.',
      );
    }
  }

  Future<void> selectCurrency(String code) async {
    final currency = AppCurrencies.byCode(code);
    state = state.copyWith(selectedCurrency: currency.code);

    try {
      await _profileService.updatePreferredCurrency(currency.code);
      final profile = await _profileService.getProfile();
      if (profile != null) {
        state = state.copyWith(profile: profile);
      }
    } catch (_) {
      // Keep the in-app selection even if persistence fails.
    }
  }
}

final walletDashboardProvider =
    StateNotifierProvider<WalletDashboardNotifier, WalletDashboardState>(
  (ref) => WalletDashboardNotifier(),
);
