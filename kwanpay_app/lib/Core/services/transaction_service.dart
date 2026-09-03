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

  Future<TransactionModel?> getPendingMoolreTopUp() async {
    final user = currentUser;

    if (user == null) {
      throw Exception('No authenticated user.');
    }

    final data = await _supabase
        .from('transactions')
        .select()
        .eq('wallet_id', user.id)
        .eq('provider', 'moolre')
        .eq('type', 'Top Up')
        .eq('status', 'Pending')
        .eq('currency', 'GHS')
        .order('created_at', ascending: false)
        .limit(1);

    if (data.isEmpty) {
      return null;
    }

    return TransactionModel.fromJson(
      Map<String, dynamic>.from(data.first as Map),
    );
  }

  Future<TransactionModel?> getPendingFincraTopUp() async {
    final user = currentUser;

    if (user == null) {
      throw Exception('No authenticated user.');
    }

    final data = await _supabase
        .from('transactions')
        .select()
        .eq('wallet_id', user.id)
        .eq('provider', 'fincra')
        .eq('type', 'Top Up')
        .eq('status', 'Pending')
        .eq('currency', 'GHS')
        .order('created_at', ascending: false)
        .limit(1);

    if (data.isEmpty) {
      return null;
    }

    return TransactionModel.fromJson(
      Map<String, dynamic>.from(data.first as Map),
    );
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

  Future<MoolreCollectionResult> initiateMoolreCollection({
    required double amount,
    required String reference,
    required String rail,
    required String msisdn,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception('No authenticated user.');
    }

    try {
      final response = await _supabase.functions.invoke(
        'initiate-moolre-collection',
        body: {
          'amount': amount,
          'reference': reference.trim(),
          'rail': rail,
          'msisdn': msisdn,
        },
      );

      final data = response.data;

      if (data is! Map) {
        throw Exception('Payment service returned an invalid response.');
      }

      final payload = Map<String, dynamic>.from(data);

      if (payload['error'] != null) {
        throw Exception(payload['error'].toString());
      }

      final transaction = payload['transaction'];

      if (transaction is! Map) {
        throw Exception('Payment started without a KwanPay transaction.');
      }

      return MoolreCollectionResult(
        transaction: TransactionModel.fromJson(
          Map<String, dynamic>.from(transaction),
        ),
        verificationRequired: payload['verification_required'] == true,
        sessionId: payload['session_id']?.toString(),
        message:
            payload['message']?.toString() ??
            'Payment request sent. Check your phone.',
      );
    } on FunctionException catch (error) {
      final details = error.details;

      if (details is Map && details['error'] != null) {
        throw Exception(details['error'].toString());
      }

      throw Exception(
        error.reasonPhrase ?? 'Could not start the Mobile Money payment.',
      );
    }
  }

  Future<MoolreCollectionResult> continueMoolreCollection({
    required String reference,
    String? otpcode,
    String? sessionId,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception('No authenticated user.');
    }

    try {
      final response = await _supabase.functions.invoke(
        'continue-moolre-collection',
        body: {
          'reference': reference.trim(),
          if (otpcode != null && otpcode.trim().isNotEmpty)
            'otpcode': otpcode.trim(),
          if (sessionId != null && sessionId.trim().isNotEmpty)
            'sessionid': sessionId.trim(),
        },
      );

      final data = response.data;

      if (data is! Map) {
        throw Exception('Payment verification returned an invalid response.');
      }

      final payload = Map<String, dynamic>.from(data);

      if (payload['error'] != null) {
        throw Exception(payload['error'].toString());
      }

      final transaction = payload['transaction'];

      if (transaction is! Map) {
        throw Exception('Payment verification did not return the transaction.');
      }

      return MoolreCollectionResult(
        transaction: TransactionModel.fromJson(
          Map<String, dynamic>.from(transaction),
        ),
        verificationRequired: payload['verification_required'] == true,
        sessionId: payload['session_id']?.toString() ?? sessionId,
        message:
            payload['message']?.toString() ??
            'Payment request sent. Check your phone.',
      );
    } on FunctionException catch (error) {
      final details = error.details;

      if (details is Map && details['error'] != null) {
        throw Exception(details['error'].toString());
      }

      throw Exception(
        error.reasonPhrase ?? 'Could not continue the Mobile Money payment.',
      );
    }
  }

  Future<MoolreVerificationResult> abandonMoolreCollection({
    required String reference,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception('No authenticated user.');
    }

    try {
      final response = await _supabase.functions.invoke(
        'abandon-moolre-collection',
        body: {'reference': reference.trim()},
      );

      final data = response.data;

      if (data is! Map) {
        throw Exception('Could not close the unpaid request.');
      }

      final payload = Map<String, dynamic>.from(data);

      if (payload['error'] != null) {
        throw Exception(payload['error'].toString());
      }

      final transaction = payload['transaction'];

      if (transaction is! Map) {
        throw Exception('Closing the request did not return the transaction.');
      }

      return MoolreVerificationResult(
        transaction: TransactionModel.fromJson(
          Map<String, dynamic>.from(transaction),
        ),
        message:
            payload['message']?.toString() ??
            'This unpaid request was closed. Your wallet was not credited.',
      );
    } on FunctionException catch (error) {
      final details = error.details;

      if (details is Map && details['error'] != null) {
        throw Exception(details['error'].toString());
      }

      throw Exception(
        error.reasonPhrase ?? 'Could not close the unpaid request.',
      );
    }
  }

  Future<MoolreVerificationResult> verifyMoolrePayment({
    required String reference,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception('No authenticated user.');
    }

    try {
      final response = await _supabase.functions.invoke(
        'verify-moolre-payment',
        body: {'reference': reference.trim()},
      );

      final data = response.data;

      if (data is! Map) {
        throw Exception('Moolre verification returned an invalid response.');
      }

      final payload = Map<String, dynamic>.from(data);

      if (payload['error'] != null) {
        throw Exception(payload['error'].toString());
      }

      final transaction = payload['transaction'];

      if (transaction is! Map) {
        throw Exception('Moolre verification did not return the transaction.');
      }

      return MoolreVerificationResult(
        transaction: TransactionModel.fromJson(
          Map<String, dynamic>.from(transaction),
        ),
        message:
            payload['message']?.toString() ??
            'Payment is still pending. Approve the request on your phone.',
      );
    } on FunctionException catch (error) {
      final details = error.details;

      if (details is Map && details['error'] != null) {
        throw Exception(details['error'].toString());
      }

      throw Exception(
        error.reasonPhrase ?? 'Could not verify the Moolre payment.',
      );
    }
  }

  Future<FincraMomoInitiationResult> initiateFincraMomo({
    required double amount,
    required String reference,
    required String rail,
    required String msisdn,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception('No authenticated user.');
    }

    try {
      final response = await _supabase.functions.invoke(
        'initiate-fincra-momo',
        body: {
          'amount': amount,
          'reference': reference.trim(),
          'rail': rail,
          'msisdn': msisdn,
        },
      );

      final data = response.data;

      if (data is! Map) {
        throw Exception('Payment service returned an invalid response.');
      }

      final payload = Map<String, dynamic>.from(data);

      if (payload['error'] != null) {
        throw Exception(payload['error'].toString());
      }

      final transaction = payload['transaction'];

      if (transaction is! Map) {
        throw Exception('Payment started without a KwanPay transaction.');
      }

      return FincraMomoInitiationResult(
        transaction: TransactionModel.fromJson(
          Map<String, dynamic>.from(transaction),
        ),
        authModel: payload['auth_model']?.toString(),
        verificationRequired: payload['verification_required'] == true,
        message: payload['message']?.toString(),
      );
    } on FunctionException catch (error) {
      final details = error.details;

      if (details is Map && details['error'] != null) {
        throw Exception(details['error'].toString());
      }

      throw Exception(
        error.reasonPhrase ?? 'Could not start the Mobile Money payment.',
      );
    }
  }

  Future<FincraMomoVerificationResult> verifyFincraMomo({
    required String reference,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception('No authenticated user.');
    }

    try {
      final response = await _supabase.functions.invoke(
        'verify-fincra-momo',
        body: {'reference': reference.trim()},
      );

      final data = response.data;

      if (data is! Map) {
        throw Exception('Payment verification returned an invalid response.');
      }

      final payload = Map<String, dynamic>.from(data);

      if (payload['error'] != null) {
        throw Exception(payload['error'].toString());
      }

      final transaction = payload['transaction'];

      if (transaction is! Map) {
        throw Exception('Payment verification did not return the transaction.');
      }

      return FincraMomoVerificationResult(
        transaction: TransactionModel.fromJson(
          Map<String, dynamic>.from(transaction),
        ),
        message:
            payload['message']?.toString() ??
            'Payment is still pending. Approve the request on your phone.',
        authModel: payload['auth_model']?.toString(),
      );
    } on FunctionException catch (error) {
      final details = error.details;

      if (details is Map && details['error'] != null) {
        throw Exception(details['error'].toString());
      }

      throw Exception(
        error.reasonPhrase ?? 'Could not verify the Mobile Money payment.',
      );
    }
  }

  Future<FincraMomoVerificationResult> authorizeFincraMomo({
    required String reference,
    required String otp,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception('No authenticated user.');
    }

    try {
      final response = await _supabase.functions.invoke(
        'authorize-fincra-momo',
        body: {'reference': reference.trim(), 'otp': otp.trim()},
      );

      final data = response.data;

      if (data is! Map) {
        throw Exception('Payment authorization returned an invalid response.');
      }

      final payload = Map<String, dynamic>.from(data);

      if (payload['error'] != null) {
        throw Exception(payload['error'].toString());
      }

      final transaction = payload['transaction'];

      if (transaction is! Map) {
        throw Exception(
          'Payment authorization did not return the transaction.',
        );
      }

      return FincraMomoVerificationResult(
        transaction: TransactionModel.fromJson(
          Map<String, dynamic>.from(transaction),
        ),
        message:
            payload['message']?.toString() ??
            'Verification submitted. Checking payment…',
      );
    } on FunctionException catch (error) {
      final details = error.details;

      if (details is Map && details['error'] != null) {
        throw Exception(details['error'].toString());
      }

      throw Exception(
        error.reasonPhrase ?? 'Could not authorize the Mobile Money payment.',
      );
    }
  }

  Future<FincraMomoResendResult> resendFincraMomoOtp({
    required String reference,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception('No authenticated user.');
    }

    try {
      final response = await _supabase.functions.invoke(
        'resend-fincra-momo-otp',
        body: {'reference': reference.trim()},
      );

      final data = response.data;

      if (data is! Map) {
        throw Exception('Could not resend the verification code.');
      }

      final payload = Map<String, dynamic>.from(data);

      if (payload['error'] != null) {
        throw Exception(payload['error'].toString());
      }

      TransactionModel? transaction;
      final rawTransaction = payload['transaction'];

      if (rawTransaction is Map) {
        transaction = TransactionModel.fromJson(
          Map<String, dynamic>.from(rawTransaction),
        );
      }

      return FincraMomoResendResult(
        transaction: transaction,
        message:
            payload['message']?.toString() ??
            'A new verification code was sent to your phone.',
      );
    } on FunctionException catch (error) {
      final details = error.details;

      if (details is Map && details['error'] != null) {
        throw Exception(details['error'].toString());
      }

      throw Exception(
        error.reasonPhrase ?? 'Could not resend the verification code.',
      );
    }
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
        body: {'reference': reference.trim()},
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
        .map(
          (row) => {
            'code': (row['code'] ?? '').toString(),
            'stellar_public_key': (row['stellar_public_key'] ?? '').toString(),
          },
        )
        .where(
          (row) =>
              row['code']!.isNotEmpty && row['stellar_public_key']!.isNotEmpty,
        )
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
        body: {'reference': reference.trim(), 'tx_hash': txHash.trim()},
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
      return TransactionModel.fromJson(Map<String, dynamic>.from(data));
    }

    throw Exception(fallbackMessage);
  }

  String generateTransactionReference() {
    final timestamp = DateTime.now().microsecondsSinceEpoch
        .toRadixString(36)
        .toUpperCase();
    final nonce = Random.secure()
        .nextInt(1 << 32)
        .toRadixString(36)
        .toUpperCase();

    return 'KWP-TXN-$timestamp-$nonce';
  }
}

class MoolreVerificationResult {
  final TransactionModel transaction;
  final String message;

  const MoolreVerificationResult({
    required this.transaction,
    required this.message,
  });
}

class MoolreCollectionResult {
  final TransactionModel transaction;
  final bool verificationRequired;
  final String? sessionId;
  final String message;

  const MoolreCollectionResult({
    required this.transaction,
    required this.verificationRequired,
    this.sessionId,
    required this.message,
  });
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

class FincraMomoInitiationResult {
  final TransactionModel transaction;
  final String? authModel;
  final String? message;
  final bool verificationRequired;

  const FincraMomoInitiationResult({
    required this.transaction,
    this.authModel,
    this.message,
    required this.verificationRequired,
  });

  bool get otpRequired =>
      verificationRequired || (authModel ?? '').toUpperCase() == 'OTP';
}

class FincraMomoVerificationResult {
  final TransactionModel transaction;
  final String message;
  final String? authModel;

  const FincraMomoVerificationResult({
    required this.transaction,
    required this.message,
    this.authModel,
  });

  bool get otpRequired => (authModel ?? '').toUpperCase() == 'OTP';
}

class FincraMomoResendResult {
  final TransactionModel? transaction;
  final String message;

  const FincraMomoResendResult({this.transaction, required this.message});
}
