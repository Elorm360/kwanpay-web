import 'package:flutter/foundation.dart';

import 'stellar_balance_service.dart';

class StellarBalanceTestService {
  final StellarBalanceService _balanceService = StellarBalanceService();

  Future<void> testBalanceSync(String publicKey) async {
    final balances = await _balanceService.getWalletBalances(publicKey);
    final xlm = await _balanceService.getXlmBalance(publicKey);
    final usdc = await _balanceService.getUsdcBalance(publicKey);

    debugPrint('STELLAR BALANCE SYNC SUCCESS');
    debugPrint('Balance count: ${balances.length}');

    for (final balance in balances) {
      debugPrint(
        'Asset: ${balance['assetCode'] ?? 'XLM'} '
        '| Issuer: ${balance['assetIssuer'] ?? 'NATIVE'} '
        '| Balance: ${balance['balance']}',
      );
    }

    debugPrint(
      'XLM identified as native: ${xlm != null && xlm['assetType'] == 'native'}',
    );
    debugPrint(
      'USDC present: ${usdc != null}',
    );
  }
}
