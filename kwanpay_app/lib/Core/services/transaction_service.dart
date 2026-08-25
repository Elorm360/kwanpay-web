import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/fx_quote.dart';
import '../models/transaction_model.dart';
import '../models/transaction_status.dart';

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

  Future<TransactionModel> createTransaction({
    required String type,
    required double amount,
    required String currency,
    required String description,
    String? reference,
    String? provider,
    String? providerReference,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception("No authenticated user.");
    }

    final resolvedReference = reference ?? generateTransactionReference();

    try {
      final data = await _supabase
          .from('transactions')
          .insert({
            'wallet_id': user.id,
            'type': type,
            'amount': amount,
            'currency': currency,
            'description': description,
            'status': TransactionStatus.pending,
            'reference': resolvedReference,
            'provider': provider,
            'provider_reference': providerReference,
          })
          .select()
          .single();

      return TransactionModel.fromJson(data);
    } on PostgrestException catch (error) {
      if (error.code != '23505') {
        rethrow;
      }

      final existing = await _supabase
          .from('transactions')
          .select()
          .eq('wallet_id', user.id)
          .eq('reference', resolvedReference)
          .maybeSingle();

      if (existing == null) {
        rethrow;
      }

      return TransactionModel.fromJson(existing);
    }
  }

  Future<TransactionModel> initiateTestFunding({
    required double amount,
    required String currency,
    required String reference,
    required String provider,
    String? providerReference,
    String? description,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception("No authenticated user.");
    }

    final data = await _supabase.rpc(
      'initiate_test_funding',
      params: {
        'p_amount': amount,
        'p_currency': currency,
        'p_reference': reference.trim(),
        'p_provider': provider,
        'p_provider_reference': providerReference,
        'p_description': description,
      },
    );

    return _transactionFromRpc(data, 'Could not start the funding request.');
  }

  Future<TransactionModel> initiateGhanaCollection({
    required double amount,
    required String reference,
    required String rail,
    required String msisdn,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception('No authenticated user.');
    }

    final data = await _supabase.rpc(
      'initiate_ghana_collection',
      params: {
        'p_amount': amount,
        'p_reference': reference.trim(),
        'p_rail': rail,
        'p_msisdn': msisdn,
      },
    );

    return _transactionFromRpc(data, 'Could not start the collection request.');
  }

  Future<FlutterwaveChargeResult> initiateFlutterwaveMomo({
    required String reference,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception('No authenticated user.');
    }

    try {
      final response = await _supabase.functions.invoke(
        'initiate-flutterwave-momo',
        body: {
          'reference': reference.trim(),
        },
      );

      final data = response.data;
      if (data is! Map) {
        throw Exception('Flutterwave did not start the Mobile Money charge.');
      }

      final payload = Map<String, dynamic>.from(data);
      if (payload['error'] != null) {
        throw Exception(payload['error'].toString());
      }

      TransactionModel? transaction;
      if (payload['transaction'] != null) {
        transaction = TransactionModel.fromJson(
          Map<String, dynamic>.from(payload['transaction'] as Map),
        );
      }

      return FlutterwaveChargeResult(
        configured: payload['configured'] == true,
        alreadyInitiated: payload['already_initiated'] == true,
        redirectUrl: payload['redirect_url'] as String?,
        flwId: payload['flw_id'] as String?,
        transaction: transaction,
      );
    } on FunctionException catch (error) {
      final details = error.details;
      if (details is Map && details['error'] != null) {
        throw Exception(details['error'].toString());
      }
      throw Exception(
        error.reasonPhrase ??
            'Flutterwave did not start the Mobile Money charge.',
      );
    }
  }

  Future<TransactionModel> settleGhanaCollection({
    required String reference,
    required String status,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception('No authenticated user.');
    }

    if (!TransactionStatus.isTerminal(status)) {
      throw Exception('Invalid transaction status.');
    }

    try {
      final response = await _supabase.functions.invoke(
        'ghana-collection-webhook',
        body: {
          'reference': reference.trim(),
          'status': status,
        },
      );

      final data = response.data;
      if (data is Map && data['transaction'] != null) {
        return TransactionModel.fromJson(
          Map<String, dynamic>.from(data['transaction'] as Map),
        );
      }

      if (data is Map && data['error'] != null) {
        throw Exception(data['error'].toString());
      }

      throw Exception('Collector did not confirm the settlement.');
    } on FunctionException catch (error) {
      final details = error.details;
      if (details is Map && details['error'] != null) {
        throw Exception(details['error'].toString());
      }
      throw Exception(
        error.reasonPhrase ?? 'Collector did not confirm the settlement.',
      );
    }
  }

  Future<FxQuote> getFxQuote({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception("No authenticated user.");
    }

    final data = await _supabase.rpc(
      'get_fx_quote',
      params: {
        'p_from_currency': fromCurrency,
        'p_to_currency': toCurrency,
        'p_from_amount': amount,
      },
    );

    if (data is List && data.isNotEmpty) {
      return FxQuote.fromJson(Map<String, dynamic>.from(data.first as Map));
    }

    if (data is Map) {
      return FxQuote.fromJson(Map<String, dynamic>.from(data));
    }

    throw Exception('Could not load a conversion quote.');
  }

  Future<void> refreshFxRates() async {
    final user = currentUser;

    if (user == null) {
      throw Exception('No authenticated user.');
    }

    final response = await _supabase.functions.invoke('refresh-fx-rates');
    final data = response.data;
    if (data is Map && data['error'] != null) {
      throw Exception(data['error'].toString());
    }
  }

  Future<TransactionModel> convertWalletFunds({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
    required String reference,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception("No authenticated user.");
    }

    final data = await _supabase.rpc(
      'convert_wallet_funds',
      params: {
        'p_from_currency': fromCurrency,
        'p_to_currency': toCurrency,
        'p_from_amount': amount,
        'p_reference': reference.trim(),
      },
    );

    return _transactionFromRpc(data, 'Could not convert funds.');
  }

  Future<TransactionModel> applyFundingStatus({
    required String transactionId,
    required String status,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception("No authenticated user.");
    }

    if (!TransactionStatus.isTerminal(status)) {
      throw Exception("Invalid transaction status.");
    }

    final data = await _supabase.rpc(
      'apply_funding_status',
      params: {
        'p_transaction_id': transactionId,
        'p_status': status,
      },
    );

    return _transactionFromRpc(data, 'Could not update the test transaction.');
  }

  Future<TransactionModel> transferFunds({
    required String receiverWalletId,
    required double amount,
    required String currency,
    required String reference,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception("No authenticated user.");
    }

    final data = await _supabase.rpc(
      'transfer_funds',
      params: {
        'p_receiver_wallet_id': receiverWalletId.trim(),
        'p_transfer_amount': amount,
        'p_reference': reference.trim(),
        'p_currency': currency,
      },
    );

    return _transactionFromRpc(data, 'Could not complete the transfer.');
  }

  Future<TransactionModel> payOperatorBill({
    required String operatorCode,
    required String accountNumber,
    required double amount,
    required String currency,
    required String reference,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception('No authenticated user.');
    }

    final data = await _supabase.rpc(
      'pay_operator_bill',
      params: {
        'p_operator_code': operatorCode.trim(),
        'p_account_number': accountNumber.trim(),
        'p_amount': amount,
        'p_currency': currency,
        'p_reference': reference.trim(),
      },
    );

    return _transactionFromRpc(data, 'Could not complete the payment.');
  }

  Future<List<Map<String, String>>> getTourismStellarAccounts() async {
    final user = currentUser;
    if (user == null) {
      throw Exception('No authenticated user.');
    }

    final data = await _supabase
        .from('tourism_stellar_accounts')
        .select('code, stellar_public_key');

    return (data as List)
        .whereType<Map>()
        .map((row) => {
              'code': (row['code'] ?? '').toString(),
              'stellar_public_key': (row['stellar_public_key'] ?? '').toString(),
            })
        .where((row) =>
            row['code']!.isNotEmpty && row['stellar_public_key']!.isNotEmpty)
        .toList();
  }

  Future<TransactionModel> initiateStellarUsdcPayment({
    required String operatorCode,
    required String bookingReference,
    required double amount,
    required String reference,
  }) async {
    final user = currentUser;
    if (user == null) {
      throw Exception('No authenticated user.');
    }

    final data = await _supabase.rpc(
      'initiate_stellar_usdc_payment',
      params: {
        'p_operator_code': operatorCode.trim(),
        'p_booking_reference': bookingReference.trim(),
        'p_amount': amount,
        'p_reference': reference.trim(),
      },
    );

    return _transactionFromRpc(data, 'Could not start the Stellar payment.');
  }

  Future<TransactionModel> verifyStellarUsdcPayment({
    required String reference,
    required String txHash,
  }) async {
    final user = currentUser;
    if (user == null) {
      throw Exception('No authenticated user.');
    }

    try {
      final response = await _supabase.functions.invoke(
        'verify-stellar-usdc-payment',
        body: {
          'reference': reference.trim(),
          'tx_hash': txHash.trim(),
        },
      );

      final data = response.data;
      if (data is Map && data['transaction'] != null) {
        return TransactionModel.fromJson(
          Map<String, dynamic>.from(data['transaction'] as Map),
        );
      }

      if (data is Map && data['error'] != null) {
        throw Exception(data['error'].toString());
      }

      throw Exception('Horizon did not confirm the USDC payment.');
    } on FunctionException catch (error) {
      final details = error.details;
      if (details is Map && details['error'] != null) {
        throw Exception(details['error'].toString());
      }
      throw Exception(
        error.reasonPhrase ?? 'Horizon did not confirm the USDC payment.',
      );
    }
  }

  TransactionModel _transactionFromRpc(dynamic data, String fallbackMessage) {
    if (data is List && data.isNotEmpty) {
      return TransactionModel.fromJson(
        Map<String, dynamic>.from(data.first as Map),
      );
    }

    if (data is Map) {
      return TransactionModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    throw Exception(fallbackMessage);
  }

  String generateTransactionReference() {
    final timestamp = DateTime.now().microsecondsSinceEpoch
        .toRadixString(36)
        .toUpperCase();
    final nonce = Random.secure().nextInt(1 << 32).toRadixString(36).toUpperCase();

    return 'KWP-TXN-$timestamp$nonce';
  }
}

class FlutterwaveChargeResult {
  final bool configured;
  final bool alreadyInitiated;
  final String? redirectUrl;
  final String? flwId;
  final TransactionModel? transaction;

  const FlutterwaveChargeResult({
    required this.configured,
    this.alreadyInitiated = false,
    this.redirectUrl,
    this.flwId,
    this.transaction,
  });
}
