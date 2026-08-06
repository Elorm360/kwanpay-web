class TransactionModel {
  final String id;
  final String type;
  final double amount;
  final String currency;
  final String status;
  final String description;
  final DateTime createdAt;

  const TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    required this.status,
    required this.description,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      status: json['status'] ?? 'Completed',
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

