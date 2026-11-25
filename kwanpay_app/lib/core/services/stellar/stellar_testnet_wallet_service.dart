import 'dart:convert';
import 'dart:typed_data';

import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../wallet_service.dart';
import 'stellar_assets.dart';
import 'stellar_balance_service.dart';
import 'stellar_key_store.dart';
import 'stellar_service.dart';

class StellarTestnetWalletService {
  final _stellar = StellarService();
  final _keys = StellarKeyStore();
  final _balances = StellarBalanceService();
  final _wallets = WalletService();

  Asset get _usdc => Asset.createNonNativeAsset(
        StellarAssets.usdcCode,
        StellarAssets.testnetUsdcIssuer,
      );

  Uint8List memoHashFor(String reference) {
    return Util.hash(Uint8List.fromList(utf8.encode(reference.trim())));
  }

  Future<KeyPair> ensureReady() async {
    if (!_stellar.isTestnet) {
      throw Exception('Stellar USDC Pay is Testnet-only in this sprint.');
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user.');
    }

    final keyPair = await _keys.loadOrCreate(user.id);
    await _wallets.updateStellarPublicKey(keyPair.accountId);
    await _ensureAccount(keyPair);
    await _ensureUsdcTrustline(keyPair);
    return keyPair;
  }

  Future<double> usdcBalance() async {
    final keyPair = await ensureReady();
    return _balances.getUsdcAmount(keyPair.accountId);
  }

  Future<String> publicKey() async {
    final keyPair = await ensureReady();
    return keyPair.accountId;
  }

  Future<String> payUsdc({
    required String destination,
    required double amount,
    required String reference,
  }) async {
    if (amount <= 0) {
      throw Exception('Enter an amount greater than zero.');
    }

    final keyPair = await ensureReady();
    final available = await _balances.getUsdcAmount(keyPair.accountId);
    if (amount > available) {
      throw Exception(
        'Insufficient Testnet USDC. Fund this account from the Circle faucet, then try again.',
      );
    }

    final normalizedReference = reference.trim().toUpperCase();

    final account = await _stellar.server.accounts.account(keyPair.accountId);
    final preconditions = TransactionPreconditions()
      ..timeBounds = TimeBounds.expiresAfter(300);

    final transaction = TransactionBuilder(account)
        .addOperation(
          PaymentOperationBuilder(
            destination,
            _usdc,
            amount.toStringAsFixed(7),
          ).build(),
        )
        .addMemo(Memo.hash(memoHashFor(normalizedReference)))
        .addPreconditions(preconditions)
        .build();

    transaction.sign(keyPair, Network.TESTNET);
    final response = await _stellar.server.submitTransaction(transaction);
    if (!response.success || response.hash == null || response.hash!.isEmpty) {
      throw Exception('Stellar did not accept the USDC payment.');
    }

    return response.hash!;
  }

  Future<void> _ensureAccount(KeyPair keyPair) async {
    try {
      await _stellar.server.accounts.account(keyPair.accountId);
      return;
    } catch (_) {
      final funded = await FriendBot.fundTestAccount(keyPair.accountId);
      if (!funded) {
        throw Exception(
          'Could not fund the Testnet Stellar account. Try again in a moment.',
        );
      }

      for (var attempt = 0; attempt < 5; attempt++) {
        try {
          await _stellar.server.accounts.account(keyPair.accountId);
          return;
        } catch (_) {
          await Future<void>.delayed(const Duration(seconds: 2));
        }
      }

      throw Exception(
        'Stellar Testnet account is not visible on Horizon yet.',
      );
    }
  }

  Future<void> _ensureUsdcTrustline(KeyPair keyPair) async {
    if (await _balances.hasUsdcTrustline(keyPair.accountId)) {
      return;
    }

    final account = await _stellar.server.accounts.account(keyPair.accountId);
    final preconditions = TransactionPreconditions()
      ..timeBounds = TimeBounds.expiresAfter(300);

    final transaction = TransactionBuilder(account)
        .addOperation(
          ChangeTrustOperationBuilder(
            _usdc,
            StellarAssets.maxTrustlineLimit,
          ).build(),
        )
        .addPreconditions(preconditions)
        .build();

    transaction.sign(keyPair, Network.TESTNET);
    final response = await _stellar.server.submitTransaction(transaction);
    if (!response.success) {
      throw Exception('Could not open a Testnet USDC trustline.');
    }
  }
}
