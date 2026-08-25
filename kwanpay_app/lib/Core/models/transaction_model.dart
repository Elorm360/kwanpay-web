import 'transaction_status.dart';

class TransactionModel {
  final String id;
  final String type;
  final double amount;
  final String currency;
  final String status;
  final String description;
  final DateTime createdAt;
  final String? reference;
  final String? provider;
  final String? providerReference;

  const TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    required this.status,
    required this.description,
    required this.createdAt,
    this.reference,
    this.provider,
    this.providerReference,
  });

  bool get isOutgoing {
    return type == 'Send' ||
        type == 'Payment' ||
        type == 'Exchange' ||
        type == 'Convert Out';
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      amount: _parseAmount(json['amount']),
      currency: json['currency'] ?? 'USD',
      status: json['status'] ?? 'Pending',
      description: json['description'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'],
      ),
      reference: json['reference'],
      provider: json['provider'],
      providerReference: json['provider_reference'],
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

  bool get isPending => status == TransactionStatus.pending;

  bool get isCompleted => status == TransactionStatus.completed;

  TransactionModel copyWith({
    String? status,
    String? providerReference,
  }) {
    return TransactionModel(
      id: id,
      type: type,
      amount: amount,
      currency: currency,
      status: status ?? this.status,
      description: description,
      createdAt: createdAt,
      reference: reference,
      provider: provider,
      providerReference: providerReference ?? this.providerReference,
    );
  }
}
