import 'dart:developer' as developer;

import 'stellar_service.dart';

class StellarTestService {
  final StellarService _stellar = StellarService();

  Future<void> testConnection() async {
    const testPublicKey =
        'GC3MPCG7GTQEGRD5Y4OB4URWJ5CAYEXEYF4M25EMCOBO5ZBF25KO6DDN';

    final account = await _stellar.getAccount(
      publicKey: testPublicKey,
    );

    developer.log('STELLAR TESTNET CONNECTION SUCCESS');
    developer.log('Account ID: ${account.accountId}');
    developer.log('Sequence: ${account.sequenceNumber}');
    developer.log('Balances: ${account.balances.length}');
  }
}
