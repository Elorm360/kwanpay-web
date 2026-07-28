class WalletModel {
  final String id;
  final String walletId;
  final double balance;
  final String status;

  const WalletModel({
    required this.id,
    required this.walletId,
    required this.balance,
    required this.status,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] ?? '',
      walletId: json['wallet_id'] ?? '',
      balance: (json['balance'] ?? 0).toDouble(),
      status: json['status'] ?? 'Active',
    );
  }
}