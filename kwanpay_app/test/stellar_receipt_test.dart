import 'package:flutter_test/flutter_test.dart';
import 'package:kwanpay_app/core/models/transaction_model.dart';
import 'package:kwanpay_app/core/services/stellar/stellar_assets.dart';
import 'package:kwanpay_app/features/receipts/receipt_details.dart';

TransactionModel usdc({String status = 'Completed', String? providerRef}) =>
    TransactionModel(
      id: 'id-1',
      type: 'Payment',
      amount: 12.5,
      currency: 'USDC',
      status: status,
      description: 'Cape Coast Tours · BK2026TEST',
      createdAt: DateTime.utc(2026, 11, 27, 10),
      reference: 'KWP-TXN-ABC',
      provider: 'stellar_testnet',
      providerReference: providerRef,
    );

String? value(ReceiptDetails d, String label) =>
    d.lines.where((l) => l.label == label).firstOrNull?.value;

void main() {
  test('completed Stellar payment shows business, booking and hash', () {
    final d = ReceiptDetails.from(usdc(providerRef: 'abc123hash'));
    expect(d.title, 'Paid Cape Coast Tours');
    expect(d.amount, '- USDC 12.50');
    expect(value(d, 'Business'), 'Cape Coast Tours');
    expect(value(d, 'Booking reference'), 'BK2026TEST');
    expect(value(d, 'Stellar transaction'), 'abc123hash');
    expect(value(d, 'Network'), contains('test network'));
  });

  test('pending Stellar payment does not show the merchant key as a hash', () {
    final d = ReceiptDetails.from(
      usdc(status: 'Pending', providerRef: 'GDVBOPN3QGTH4ASDHPOW2WF2D3E55AREL7UCYBFMNNBBPEFD2DUFACX2'),
    );
    expect(d.title, 'Payment to Cape Coast Tours');
    expect(value(d, 'Stellar transaction'), isNull);
  });

  test('explorer link points at the Testnet transaction', () {
    expect(
      stellarExplorerUrl(' ABC123 '),
      'https://stellar.expert/explorer/testnet/tx/abc123',
    );
  });
}
