import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';

class StellarKeyStore {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  String _secretKey(String userId) => 'kwanpay.stellar.testnet.secret.$userId';

  Future<KeyPair> loadOrCreate(String userId) async {
    final existing = await _storage.read(key: _secretKey(userId));
    if (existing != null && existing.startsWith('S')) {
      return KeyPair.fromSecretSeed(existing);
    }

    final keyPair = KeyPair.random();
    await _storage.write(key: _secretKey(userId), value: keyPair.secretSeed);
    return keyPair;
  }

  Future<KeyPair?> read(String userId) async {
    final existing = await _storage.read(key: _secretKey(userId));
    if (existing == null || !existing.startsWith('S')) {
      return null;
    }
    return KeyPair.fromSecretSeed(existing);
  }
}
