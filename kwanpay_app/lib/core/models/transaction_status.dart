class TransactionStatus {
  static const pending = 'Pending';
  static const completed = 'Completed';
  static const failed = 'Failed';
  static const cancelled = 'Cancelled';

  static const outcomes = [completed, failed, cancelled];

  static bool isTerminal(String status) {
    return outcomes.contains(status);
  }
}

class TransactionProviders {
  static const kwanpayFx = 'kwanpay_fx';
  static const kwanpayTransfer = 'kwanpay_transfer';
  static const kwanpayMerchant = 'kwanpay_merchant';

  // Development blockchain network for Sprint 13.
  // This is not a fake KwanPay funding provider.
  static const stellarTestnet = 'stellar_testnet';

  static bool isDevelopmentNetwork(String? provider) {
    return provider == stellarTestnet;
  }
}

/// Values of `transactions.type` written by the database functions.
class TransactionTypes {
  static const topUp = 'Top Up';
  static const withdrawal = 'Withdrawal';
  static const send = 'Send';
  static const receive = 'Receive';
  static const payment = 'Payment';
  static const convertIn = 'Convert In';
  static const convertOut = 'Convert Out';

  /// Legacy type still found on older rows.
  static const exchange = 'Exchange';

  static const outgoing = {withdrawal, send, payment, convertOut, exchange};
}
