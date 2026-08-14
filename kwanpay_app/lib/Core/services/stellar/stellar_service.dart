import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';

class StellarService {
  static final StellarService instance = StellarService._internal();

  StellarService._internal();

  factory StellarService() {
    return instance;
  }

  String get network {
    return dotenv.env['STELLAR_NETWORK'] ?? 'testnet';
  }

  String get horizonUrl {
    return dotenv.env['STELLAR_HORIZON_URL'] ??
        'https://horizon-testnet.stellar.org';
  }

  bool get isTestnet {
    return network.toLowerCase() == 'testnet';
  }

  bool get isMainnet {
    return network.toLowerCase() == 'mainnet';
  }

  StellarSDK get server {
    if (isTestnet) {
      return StellarSDK(horizonUrl);
    }

    if (isMainnet) {
      return StellarSDK(horizonUrl);
    }

    throw Exception(
      'Invalid Stellar network configuration: $network',
    );
  }

  void validateConfiguration() {
    if (horizonUrl.isEmpty) {
      throw Exception(
        'Stellar Horizon URL is not configured.',
      );
    }

    if (!isTestnet && !isMainnet) {
      throw Exception(
        'Invalid Stellar network configuration: $network',
      );
    }
  }

  Future<AccountResponse> getAccount({
    required String publicKey,
  }) async {
    try {
      return await server.accounts.account(publicKey);
    } catch (e) {
      throw Exception(
        'Unable to retrieve Stellar account: $e',
      );
    }
  }
}
