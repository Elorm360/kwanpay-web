import 'package:flutter_test/flutter_test.dart';

import 'package:kwanpay_app/Core/models/wallet_reconciliation.dart';
import 'package:kwanpay_app/Core/providers/wallet_dashboard_provider.dart';

void main() {
  group('WalletDashboardState reconciliation', () {
    test('reports unavailable when no reconciliation result exists', () {
      const state = WalletDashboardState();

      expect(state.isBalanceMatched(), isNull);
    });

    test('reports a confirmed matching balance', () {
      const state = WalletDashboardState(
        reconciliation: [
          WalletReconciliation(
            currency: 'GHS',
            ledgerAvailable: 100,
            expectedAvailable: 100,
            pendingAmount: 0,
            matched: true,
          ),
        ],
      );

      expect(state.isBalanceMatched('GHS'), isTrue);
    });

    test('reports a mismatch without treating it as unavailable', () {
      const state = WalletDashboardState(
        reconciliation: [
          WalletReconciliation(
            currency: 'GHS',
            ledgerAvailable: 90,
            expectedAvailable: 100,
            pendingAmount: 0,
            matched: false,
          ),
        ],
      );

      expect(state.isBalanceMatched('GHS'), isFalse);
    });

    test('matches currency codes case-insensitively', () {
      const state = WalletDashboardState(
        reconciliation: [
          WalletReconciliation(
            currency: 'GHS',
            ledgerAvailable: 100,
            expectedAvailable: 100,
            pendingAmount: 0,
            matched: true,
          ),
        ],
      );

      expect(state.isBalanceMatched('ghs'), isTrue);
    });
  });
}
