import 'package:flutter_test/flutter_test.dart';
import 'package:kwanpay_app/core/models/transaction_model.dart';
import 'package:kwanpay_app/core/models/transaction_status.dart';

TransactionModel _tx(String type, {Object? amount = 10, String status = 'Completed'}) {
  return TransactionModel.fromJson({
    'id': 'id-$type',
    'type': type,
    'amount': amount,
    'currency': 'GHS',
    'status': status,
    'description': type,
    'created_at': '2026-11-25T10:00:00Z',
  });
}

void main() {
  group('direction', () {
    test('money leaving the wallet is outgoing', () {
      for (final type in [
        TransactionTypes.withdrawal,
        TransactionTypes.send,
        TransactionTypes.payment,
        TransactionTypes.convertOut,
      ]) {
        expect(_tx(type).isOutgoing, isTrue, reason: type);
        expect(_tx(type).isIncoming, isFalse, reason: type);
      }
    });

    test('money arriving in the wallet is incoming', () {
      for (final type in [
        TransactionTypes.topUp,
        TransactionTypes.receive,
        TransactionTypes.convertIn,
      ]) {
        expect(_tx(type).isIncoming, isTrue, reason: type);
      }
    });
  });

  group('categories', () {
    test('transfers cover both directions', () {
      expect(_tx(TransactionTypes.send).isTransfer, isTrue);
      expect(_tx(TransactionTypes.receive).isTransfer, isTrue);
      expect(_tx(TransactionTypes.withdrawal).isTransfer, isFalse);
    });

    test('payments are only Payment rows', () {
      expect(_tx(TransactionTypes.payment).isPayment, isTrue);
      expect(_tx(TransactionTypes.topUp).isPayment, isFalse);
    });
  });

  group('fromJson', () {
    test('parses numeric strings from Postgres numeric columns', () {
      expect(_tx(TransactionTypes.topUp, amount: '12.50').amount, 12.5);
    });

    test('falls back to zero for unparseable amounts', () {
      expect(_tx(TransactionTypes.topUp, amount: 'abc').amount, 0);
      expect(_tx(TransactionTypes.topUp, amount: null).amount, 0);
    });

    test('exposes pending and completed status helpers', () {
      expect(_tx(TransactionTypes.topUp, status: TransactionStatus.pending).isPending, isTrue);
      expect(_tx(TransactionTypes.topUp).isCompleted, isTrue);
    });
  });

  test('terminal statuses', () {
    expect(TransactionStatus.isTerminal(TransactionStatus.completed), isTrue);
    expect(TransactionStatus.isTerminal(TransactionStatus.failed), isTrue);
    expect(TransactionStatus.isTerminal(TransactionStatus.cancelled), isTrue);
    expect(TransactionStatus.isTerminal(TransactionStatus.pending), isFalse);
  });
}
