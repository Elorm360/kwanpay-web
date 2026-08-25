import 'stellar_assets.dart';
import 'stellar_service.dart';

class StellarBalanceService {
  final StellarService _stellarService = StellarService();

  Future<List<Map<String, dynamic>>> getWalletBalances(
    String publicKey,
  ) async {
    if (publicKey.trim().isEmpty) {
      throw Exception('Stellar public key cannot be empty.');
    }

    return _stellarService.getBalances(
      publicKey: publicKey.trim(),
    );
  }

  Future<Map<String, dynamic>?> getXlmBalance(
    String publicKey,
  ) async {
    final balances = await getWalletBalances(publicKey);

    for (final balance in balances) {
      if (balance['assetType'] == 'native') {
        return balance;
      }
    }

    return null;
  }

  Future<Map<String, dynamic>?> getUsdcBalance(
    String publicKey,
  ) async {
    final balances = await getWalletBalances(publicKey);
    final testnet = _stellarService.isTestnet;

    for (final balance in balances) {
      if (StellarAssets.isUsdc(
        assetCode: balance['assetCode'] as String?,
        assetIssuer: balance['assetIssuer'] as String?,
        testnet: testnet,
      )) {
        return balance;
      }
    }

    return null;
  }

  Future<double> getUsdcAmount(String publicKey) async {
    final usdc = await getUsdcBalance(publicKey);
    if (usdc == null) return 0;
    return double.tryParse(usdc['balance']?.toString() ?? '') ?? 0;
  }

  Future<bool> hasUsdcTrustline(String publicKey) async {
    return await getUsdcBalance(publicKey) != null;
  }
}
