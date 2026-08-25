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
  static const kwanpayTest = 'kwanpay_test';
  static const ghanaMomoTest = 'ghana_momo_test';
  static const kwanpayFxTest = 'kwanpay_fx_test';
  static const kwanpayFx = 'kwanpay_fx';
  static const kwanpayTransfer = 'kwanpay_transfer';
  static const kwanpayOperatorTest = 'kwanpay_operator_test';
  static const ghanaCollectorTest = 'ghana_collector_test';
  static const kwanpayMerchant = 'kwanpay_merchant';
  static const flutterwave = 'flutterwave';
  static const stellarTestnet = 'stellar_testnet';

  static bool isTest(String? provider) {
    return provider == kwanpayTest ||
        provider == ghanaMomoTest ||
        provider == kwanpayFxTest ||
        provider == kwanpayOperatorTest ||
        provider == ghanaCollectorTest ||
        provider == stellarTestnet;
  }
}
