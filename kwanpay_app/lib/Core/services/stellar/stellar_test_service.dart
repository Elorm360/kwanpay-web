import 'stellar_service.dart';

class StellarTestService {
  final StellarService _stellar = StellarService();

  Future<void> testConnection() async {
    const testPublicKey =
        'GC3MPCG7GTQEGRD5Y4OB4URWJ5CAYEXEYF4M25EMCOBO5ZBF25KO6DDN';

    final account = await _stellar.getAccount(
      publicKey: testPublicKey,
    );

    print('STELLAR TESTNET CONNECTION SUCCESS');
    print('Account ID: ${account.accountId}');
    print('Sequence: ${account.sequenceNumber}');
    print('Balances: ${account.balances.length}');
  }
}
