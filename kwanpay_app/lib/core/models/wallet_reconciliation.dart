class WalletReconciliation {
  final String currency;
  final double ledgerAvailable;
  final double expectedAvailable;
  final double pendingAmount;
  final bool matched;

  const WalletReconciliation({
    required this.currency,
    required this.ledgerAvailable,
    required this.expectedAvailable,
    required this.pendingAmount,
    required this.matched,
  });

  factory WalletReconciliation.fromJson(Map<String, dynamic> json) {
    return WalletReconciliation(
      currency: (json['currency'] ?? '').toString().toUpperCase(),
      ledgerAvailable: _parseAmount(json['ledger_available']),
      expectedAvailable: _parseAmount(json['expected_available']),
      pendingAmount: _parseAmount(json['pending_amount']),
      matched: json['matched'] == true,
    );
  }

  static double _parseAmount(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value) ?? 0;
    }

    return 0;
  }
}
