import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/fx_quote.dart';
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
    return (data as List).map((e) => TransactionModel.fromJson(e)).toList();
  }

  /// Latest pending GHS top-up from any payment gateway, so the Add Funds
  /// screen can resume (or explain) an unfinished payment.
  Future<TransactionModel?> getPendingTopUp() async {
    final user = currentUser;
    if (user == null) throw Exception('No authenticated user.');
    final data = await _supabase
        .from('transactions')
        .select()
        .eq('wallet_id', user.id)
        .eq('type', 'Top Up')
        .eq('status', 'Pending')
        .eq('currency', 'GHS')
        .order('created_at', ascending: false)
        .limit(1);
    if (data.isEmpty) return null;
    return TransactionModel.fromJson(Map<String, dynamic>.from(data.first as Map));
  }

  Future<FxQuote> getFxQuote({required String fromCurrency, required String toCurrency, required double amount}) async {
    final user = currentUser;
    if (user == null) throw Exception('No authenticated user.');
    final data = await _supabase.rpc('get_fx_quote', params: {'p_from_currency': fromCurrency, 'p_to_currency': toCurrency, 'p_from_amount': amount});
    if (data is List && data.isNotEmpty) return FxQuote.fromJson(Map<String, dynamic>.from(data.first as Map));
    if (data is Map) return FxQuote.fromJson(Map<String, dynamic>.from(data));
    throw Exception('Could not load a conversion quote.');
  }

  Future<void> refreshFxRates() async {
    final user = currentUser;
    if (user == null) throw Exception('No authenticated user.');
    final response = await _supabase.functions.invoke('refresh-fx-rates');
    final data = response.data;
    if (data is Map && data['error'] != null) throw Exception(data['error'].toString());
  }

  Future<TransactionModel> convertWalletFunds({required String fromCurrency, required String toCurrency, required double amount, required String reference}) async {
    final user = currentUser;
    if (user == null) throw Exception('No authenticated user.');
    final data = await _supabase.rpc('convert_wallet_funds', params: {'p_from_currency': fromCurrency, 'p_to_currency': toCurrency, 'p_from_amount': amount, 'p_reference': reference.trim()});
    return _transactionFromRpc(data, 'Could not convert funds.');
  }

  Future<TransactionModel> transferFunds({required String receiverWalletId, required double amount, required String currency, required String reference}) async {
    final user = currentUser;
    if (user == null) throw Exception('No authenticated user.');
    final data = await _supabase.rpc('transfer_funds', params: {'p_receiver_wallet_id': receiverWalletId.trim(), 'p_transfer_amount': amount, 'p_reference': reference.trim(), 'p_currency': currency});
    return _transactionFromRpc(data, 'Could not complete the transfer.');
  }

  Future<TransactionModel> payOperatorBill({required String operatorCode, required String accountNumber, required double amount, required String currency, required String reference}) async {
    final user = currentUser;
    if (user == null) throw Exception('No authenticated user.');
    final data = await _supabase.rpc('pay_operator_bill', params: {'p_operator_code': operatorCode.trim(), 'p_account_number': accountNumber.trim(), 'p_amount': amount, 'p_currency': currency, 'p_reference': reference.trim()});
    return _transactionFromRpc(data, 'Could not complete the payment.');
  }

  Future<List<Map<String, String>>> getTourismStellarAccounts() async {
    final user = currentUser;
    if (user == null) throw Exception('No authenticated user.');
    final data = await _supabase.from('tourism_stellar_accounts').select('code, name, stellar_public_key').order('name');
    return (data as List).whereType<Map>().map((row) => {'code': (row['code'] ?? '').toString(), 'name': (row['name'] ?? '').toString(), 'stellar_public_key': (row['stellar_public_key'] ?? '').toString()}).where((row) => row['code']!.isNotEmpty && row['stellar_public_key']!.isNotEmpty).toList();
  }

  Future<TransactionModel> initiateStellarUsdcPayment({required String operatorCode, required String bookingReference, required double amount, required String reference}) async {
    final user = currentUser;
    if (user == null) throw Exception('No authenticated user.');
    final data = await _supabase.rpc('initiate_stellar_usdc_payment', params: {'p_operator_code': operatorCode.trim(), 'p_booking_reference': bookingReference.trim(), 'p_amount': amount, 'p_reference': reference.trim()});
    return _transactionFromRpc(data, 'Could not start the Stellar payment.');
  }

  Future<TransactionModel> verifyStellarUsdcPayment({required String reference, required String txHash}) async {
    final user = currentUser;
    if (user == null) throw Exception('No authenticated user.');
    try {
      final response = await _supabase.functions.invoke('verify-stellar-usdc-payment', body: {'reference': reference.trim(), 'tx_hash': txHash.trim()});
      final data = response.data;
      if (data is Map && data['transaction'] != null) return TransactionModel.fromJson(Map<String, dynamic>.from(data['transaction'] as Map));
      if (data is Map && data['error'] != null) throw Exception(data['error'].toString());
      throw Exception('Horizon did not confirm the USDC payment.');
    } on FunctionException catch (error) {
      final details = error.details;
      if (details is Map && details['error'] != null) throw Exception(details['error'].toString());
      throw Exception(error.reasonPhrase ?? 'Horizon did not confirm the USDC payment.');
    }
  }

  TransactionModel _transactionFromRpc(dynamic data, String fallbackMessage) {
    if (data is List && data.isNotEmpty) return TransactionModel.fromJson(Map<String, dynamic>.from(data.first as Map));
    if (data is Map) return TransactionModel.fromJson(Map<String, dynamic>.from(data));
    throw Exception(fallbackMessage);
  }

  String generateTransactionReference() {
    final timestamp = DateTime.now().microsecondsSinceEpoch.toRadixString(36).toUpperCase();
    final nonce = Random.secure().nextInt(1 << 32).toRadixString(36).toUpperCase();
    return 'KWP-TXN-$timestamp-$nonce';
  }
}
