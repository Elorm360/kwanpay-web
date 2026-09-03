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
  static const flutterwave = 'flutterwave';

  // Development blockchain network for Sprint 13.
  // This is not a fake KwanPay funding provider.
  static const stellarTestnet = 'stellar_testnet';

  static bool isDevelopmentNetwork(String? provider) {
    return provider == stellarTestnet;
  }
}
