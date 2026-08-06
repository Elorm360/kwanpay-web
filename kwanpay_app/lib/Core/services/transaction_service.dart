import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/transaction_model.dart';

class TransactionService {
  final _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;

  Future<List<TransactionModel>> getTransactions() async {
    final user = currentUser;

    if (user == null) return [];

    final data = await _supabase
        .from('transactions')
        .select()
        .eq('wallet_id', user.id)
        .order('created_at', ascending: false);

    return (data as List)
        .map((e) => TransactionModel.fromJson(e))
        .toList();
  }

Future<void> createTransaction({
    required String type,
    required double amount,
    required String currency,
    required String description,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception("No authenticated user.");
    }

    await _supabase
        .from('transactions')
        .insert({
          'wallet_id': user.id,
          'type': type,
          'amount': amount,
          'currency': currency,
          'description': description,
          'status': 'Completed',
        });
  }

  Future<void> transferFunds({
    required String receiverWalletId,
    required double amount,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception("No authenticated user.");
    }

    await _supabase.rpc(
      'transfer_funds',
      params: {
        'sender_id': user.id,
        'receiver_wallet_id': receiverWalletId,
        'transfer_amount': amount,
      },
    );
  }
}

