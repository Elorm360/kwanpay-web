import '../wallet_service.dart';

class StellarWalletIdentityService {
  final WalletService _walletService = WalletService();

  Future<void> attachStellarPublicKey(String publicKey) async {
    final normalizedPublicKey = publicKey.trim();

    if (normalizedPublicKey.isEmpty) {
      throw Exception('Stellar public key cannot be empty.');
    }

    await _walletService.updateStellarPublicKey(normalizedPublicKey);
  }
}
