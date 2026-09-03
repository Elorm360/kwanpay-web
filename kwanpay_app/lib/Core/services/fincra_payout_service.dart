import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/transaction_model.dart';

class FincraPayoutService {
  final _supabase = Supabase.instance.client;

  Future<TransactionModel> initiate({
    required double amount,
    required String paymentMethodId,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user.');
    }

    try {
      final response = await _supabase.functions.invoke(
        'initiate-fincra-payout',
        body: {
          'amount': amount,
          'payment_method_id': paymentMethodId,
        },
      );

      final data = response.data;
      if (data is! Map) {
        throw Exception('Withdrawal service returned an invalid response.');
      }

      final payload = Map<String, dynamic>.from(data);
      if (payload['error'] != null) {
        throw Exception(payload['error'].toString());
      }

      final rawTransaction = payload['transaction'];
      if (rawTransaction is! Map) {
        throw Exception('Withdrawal started without a KwanPay transaction.');
      }

      return TransactionModel.fromJson(
        Map<String, dynamic>.from(rawTransaction),
      );
    } on FunctionException catch (error) {
      final details = error.details;
      if (details is Map && details['error'] != null) {
        throw Exception(details['error'].toString());
      }
      throw Exception(
        error.reasonPhrase ?? 'Could not start the withdrawal.',
      );
    }
  }
}
