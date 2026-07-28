class ProfileModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String country;
  final String avatarUrl;
  final String walletAddress;

  const ProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.country,
    required this.avatarUrl,
    required this.walletAddress,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      country: json['country'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      walletAddress: json['wallet_address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'country': country,
      'avatar_url': avatarUrl,
      'wallet_address': walletAddress,
    };
  }
}

