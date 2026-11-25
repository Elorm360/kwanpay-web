import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction_model.dart';

/// Provider-neutral contract for moving money in and out of a KwanPay wallet.
///
/// No payment gateway is chosen yet. When one is, implement this interface
/// (backed by that gateway's Supabase Edge Functions) and return it from
/// [paymentGatewayProvider]. The Add Funds and Withdraw screens only talk to
/// this interface, so they need no changes when a gateway is plugged in.
///
/// Rules every implementation must keep:
/// - The wallet is credited or debited only by the server after the gateway
///   confirms the payment; the app never adjusts balances itself.
/// - [reference] is a `KWP-TXN-...` idempotency key: retrying with the same
///   reference must return the same transaction, never create a second one.
abstract class PaymentGateway {
  /// Stable identifier stored in `transactions.provider`, e.g. `acme`.
  String get id;

  /// Name shown to users, e.g. "Acme Pay".
  String get displayName;

  /// Starts a Mobile Money top-up and returns the pending transaction.
  Future<FundingSession> startTopUp({
    required double amount,
    required String reference,
    required String rail,
    required String msisdn,
  });

  /// Re-checks a pending top-up with the gateway.
  Future<FundingSession> checkTopUp({required String reference});

  /// Starts a withdrawal to a saved payment method. The server reserves the
  /// amount immediately and returns it if the payout fails.
  Future<TransactionModel> startWithdrawal({
    required double amount,
    required String paymentMethodId,
  });

  /// Re-checks a pending withdrawal with the gateway.
  Future<TransactionModel> checkWithdrawal({required String reference});
}

/// Result of starting or checking a top-up.
class FundingSession {
  final TransactionModel transaction;

  /// Hosted payment page to open, when the gateway uses one.
  final String? checkoutUrl;

  /// User-facing status message from the server, if any.
  final String? message;

  const FundingSession({
    required this.transaction,
    this.checkoutUrl,
    this.message,
  });
}

/// The active payment gateway, or `null` while none is configured.
///
/// While this is `null`, Add Funds and Withdraw show an "unavailable" state
/// instead of starting payments.
final paymentGatewayProvider = Provider<PaymentGateway?>((ref) => null);
