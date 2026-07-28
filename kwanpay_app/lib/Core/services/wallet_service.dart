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
}