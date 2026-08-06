import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/wallet_model.dart';

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

  Future<void> createWallet() async {
    final user = currentUser;

    if (user == null) {
      throw Exception("No authenticated user.");
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

  Future<Map<String, dynamic>?> findWalletById(String walletId) async {
    final wallet = await _supabase
        .from('wallets')
        .select()
        .eq('wallet_id', walletId)
        .maybeSingle();

    if (wallet == null) return null;

    final profile = await _supabase
        .from('profiles')
        .select()
        .eq('id', wallet['id'])
        .maybeSingle();

    if (profile == null) return null;

    return {
      'wallet': wallet,
      'profile': profile,
    };
  }

  String generateWalletId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final suffix =
        timestamp.toRadixString(36).toUpperCase();

    return "KWP-$suffix";
  }
}
