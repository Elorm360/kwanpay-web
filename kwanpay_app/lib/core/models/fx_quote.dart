class FxQuote {
  final String fromCurrency;
  final String toCurrency;
  final double fromAmount;
  final double toAmount;
  final double rate;
  final String source;
  final bool isTest;
  final DateTime asOf;

  const FxQuote({
    required this.fromCurrency,
    required this.toCurrency,
    required this.fromAmount,
    required this.toAmount,
    required this.rate,
    required this.source,
    required this.isTest,
    required this.asOf,
  });

  factory FxQuote.fromJson(Map<String, dynamic> json) {
    return FxQuote(
      fromCurrency: (json['from_currency'] ?? '').toString().toUpperCase(),
      toCurrency: (json['to_currency'] ?? '').toString().toUpperCase(),
      fromAmount: _parseAmount(json['from_amount']),
      toAmount: _parseAmount(json['to_amount']),
      rate: _parseAmount(json['rate']),
      source: (json['source'] ?? '').toString(),
      isTest: json['is_test'] == true,
      asOf: json['as_of'] == null
          ? DateTime.now().toUtc()
          : DateTime.parse(json['as_of'].toString()),
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
