class StellarAssets {
  static const String usdcCode = 'USDC';

  /// Circle USDC on Stellar Testnet.
  static const String testnetUsdcIssuer =
      'GBBD47IF6LWK7P7MDEVSCWR7DPUWV3NY3DTQEVFL4NAT4AQH3ZLLFLA5';

  static const String circleFaucetUrl = 'https://faucet.circle.com';

  static const String maxTrustlineLimit = '922337203685.4775807';

  static bool isUsdc({
    required String? assetCode,
    required String? assetIssuer,
    required bool testnet,
  }) {
    if (assetCode != usdcCode) {
      return false;
    }

    if (testnet) {
      return assetIssuer == testnetUsdcIssuer;
    }

    return assetIssuer != null && assetIssuer.isNotEmpty;
  }
}
