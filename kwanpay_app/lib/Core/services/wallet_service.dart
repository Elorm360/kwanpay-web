import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/wallet_model.dart';
import '../models/wallet_reconciliation.dart';

class WalletService {
  final _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;

  Future<WalletModel?> getWallet() async {
    final user = currentUser;

    if (user == null) return null;

    final data = await _supabase
        .from('wallets')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (data == null) return null;

    return WalletModel.fromJson(data);
  }

  Future<Map<String, double>> getWalletBalances() async {
    final user = currentUser;

    if (user == null) return {};

    final data = await _supabase
        .from('wallet_balances')
        .select()
        .eq('wallet_id', user.id);

    final balances = <String, double>{};

    for (final row in data as List) {
      final currency = (row['currency'] ?? '').toString();
      if (currency.isEmpty) continue;
      balances[currency.toUpperCase()] = _parseAmount(row['available']);
    }

    return balances;
  }

  Future<Map<String, double>> getDisplayRates({
    required String homeCurrency,
  }) async {
    final user = currentUser;
    final home = homeCurrency.toUpperCase();
    final rates = <String, double>{home: 1};

    if (user == null) return rates;

    try {
      final data = await _supabase
          .from('fx_rates')
          .select('quote_currency, rate')
          .eq('base_currency', home);

      for (final row in data as List) {
        final quote = (row['quote_currency'] ?? '').toString().toUpperCase();
        if (quote.isEmpty || quote == home) continue;
        rates[quote] = _parseAmount(row['rate']);
      }
    } on PostgrestException {
      return rates;
    }

    return rates;
  }

  Future<List<WalletReconciliation>> reconcileWallet() async {
    final user = currentUser;

    if (user == null) return [];

    try {
      final data = await _supabase.rpc('reconcile_wallet');

      if (data is! List) return [];

      return data
          .whereType<Map>()
          .map((row) => WalletReconciliation.fromJson(
                Map<String, dynamic>.from(row),
              ))
          .toList();
    } on PostgrestException {
      return [];
    }
  }

  static double _parseAmount(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value) ?? 0;
    }

    return 0;
  }

  Future<void> createWallet() async {
    final user = currentUser;

    if (user == null) {
      throw Exception("No authenticated user.");
    }

    if (user.emailConfirmedAt == null) {
      throw Exception("Verify your email before creating a wallet.");
    }

    final walletId = generateWalletId();

await _supabase.from('wallets').insert({
      'id': user.id,
      'wallet_id': walletId,
      'balance': 0,
      'status': 'Active',
      'currency': 'USD',
    });
  }

  Future<void> updateBalance(double newBalance) async {
    final user = currentUser;

    if (user == null) {
      throw Exception("No authenticated user.");
    }

    await _supabase
        .from('wallets')
        .update({
          'balance': newBalance,
        })
        .eq('id', user.id);
  }

  Future<void> updateStellarPublicKey(String publicKey) async {
    final user = currentUser;

    if (user == null) {
      throw Exception("No authenticated user.");
    }

    final normalizedPublicKey = publicKey.trim();

    if (normalizedPublicKey.isEmpty) {
      throw Exception("Stellar public key cannot be empty.");
    }

    await _supabase
        .from('wallets')
        .update({
          'stellar_public_key': normalizedPublicKey,
        })
        .eq('id', user.id);
  }

  Future<Map<String, dynamic>?> findWalletById(String walletId) async {
    final user = currentUser;

    if (user == null) {
      throw Exception("No authenticated user.");
    }

    try {
      final data = await _supabase.rpc(
        'resolve_wallet_recipient',
        params: {
          'p_wallet_id': walletId.trim(),
        },
      );

      final row = _firstRpcRow(data);
      if (row == null) return null;

      final resolvedWalletId = (row['wallet_id'] ?? '').toString();
      final fullName = (row['full_name'] ?? '').toString();

      if (resolvedWalletId.isEmpty) return null;

      return {
        'wallet': {
          'wallet_id': resolvedWalletId,
        },
        'profile': {
          'full_name': fullName.isEmpty ? 'KwanPay user' : fullName,
        },
      };
    } on PostgrestException catch (error) {
      final message = error.message.toLowerCase();
      if (message.contains('cannot send to yourself')) {
        throw Exception('You cannot send money to your own wallet.');
      }
      rethrow;
    }
  }

  Map<String, dynamic>? _firstRpcRow(dynamic data) {
    if (data is List && data.isNotEmpty && data.first is Map) {
      return Map<String, dynamic>.from(data.first as Map);
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return null;
  }

  String generateWalletId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final suffix =
        timestamp.toRadixString(36).toUpperCase();

    return "KWP-$suffix";
  }
}
