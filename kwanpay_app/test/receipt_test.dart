import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kwanpay_app/core/models/transaction_model.dart';
import 'package:kwanpay_app/features/receipts/receipt_details.dart';
import 'package:kwanpay_app/features/receipts/receipt_pdf.dart';

TransactionModel tx({
  String type = 'Send',
  double amount = 1234.5,
  String currency = 'GHS',
  String status = 'Completed',
  String description = '',
  String? reference = 'KWP-TXN-ABC123',
  String? providerReference,
  String? provider,
}) => TransactionModel(
  id: '7d1c-uuid',
  type: type,
  amount: amount,
  currency: currency,
  status: status,
  description: description,
  createdAt: DateTime.utc(2026, 11, 26, 9, 20),
  reference: reference,
  provider: provider,
  providerReference: providerReference,
);

String? value(ReceiptDetails d, String label) =>
    d.lines.where((l) => l.label == label).firstOrNull?.value;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('formatMoney', () {
    test('groups thousands and keeps two decimals', () {
      expect(formatMoney(1234.5, 'GHS'), 'GHS 1,234.50');
      expect(formatMoney(0, 'USD'), 'USD 0.00');
      expect(formatMoney(1000000, 'NGN'), 'NGN 1,000,000.00');
    });
  });

  group('ReceiptDetails', () {
    test('transfer sent names the recipient and wallet', () {
      final d = ReceiptDetails.from(
        tx(providerReference: 'KWP-ABCD1234'),
        counterpartyName: 'Ama Mensah',
        ownWalletId: 'KWP-MINE0001',
        ownerName: 'Elorm Apedoh',
      );
      expect(d.title, 'Sent to Ama Mensah');
      expect(d.amount, '- GHS 1,234.50');
      expect(value(d, 'To wallet'), 'KWP-ABCD1234');
      expect(value(d, 'Your wallet'), 'KWP-MINE0001');
      expect(
        d.lines.firstWhere((l) => l.label == 'Reference').copyable,
        isTrue,
      );
      expect(d.statusNote, isNull);
    });

    test('a transfer opened from Activity falls back to the wallet ID', () {
      final d = ReceiptDetails.from(tx(providerReference: 'KWP-ABCD1234'));
      expect(d.title, 'Sent to KWP-ABCD1234');
    });

    test('payment shows business and booking reference', () {
      final d = ReceiptDetails.from(
        tx(
          type: 'Payment',
          description: 'Cape Coast Castle',
          providerReference: 'cape_coast:BK12345',
          status: 'Pending',
        ),
      );
      // Pending: described, not claimed as paid.
      expect(d.title, 'Payment to Cape Coast Castle');
      expect(value(d, 'Booking reference'), 'BK12345');
      expect(d.statusNote, contains('in progress'));
    });

    test('a completed payment says Paid', () {
      final d = ReceiptDetails.from(
        tx(type: 'Payment', description: 'Cape Coast Castle'),
      );
      expect(d.title, 'Paid Cape Coast Castle');
    });

    test('money in is shown with a plus', () {
      final d = ReceiptDetails.from(tx(type: 'Receive'));
      expect(d.amount, startsWith('+'));
      expect(d.outgoing, isFalse);
    });

    test('conversion shows what came out the other side', () {
      final d = ReceiptDetails.from(
        tx(type: 'Convert Out', amount: 100, providerReference: 'USD:8.42'),
      );
      expect(d.title, 'Converted GHS to USD');
      expect(value(d, 'You got'), 'USD 8.42');
    });

    test('failed transactions say no money moved', () {
      final d = ReceiptDetails.from(
        tx(status: 'Failed', providerReference: 'KWP-ABCD1234'),
      );
      expect(d.statusNote, contains('No money moved'));
      // No minus sign and no "Sent": nothing left the account.
      expect(d.amount, 'GHS 1,234.50');
      expect(d.noMoneyMoved, isTrue);
      expect(d.title, 'Transfer to KWP-ABCD1234');
    });
  });

  group('PDF', () {
    test('builds a PDF with the bundled font', () async {
      final t = tx(providerReference: 'KWP-ABCD1234');
      final bytes = await buildReceiptPdf(
        t,
        ReceiptDetails.from(t, ownerName: 'Elorm Apedoh'),
        generatedAt: DateTime.utc(2026, 11, 26),
      );
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
      expect(bytes.length, greaterThan(1000));
    });

    test('file name is safe to save', () {
      expect(
        receiptFileName(tx(reference: 'KWP-TXN-A/B C')),
        'KwanPay-receipt-KWP-TXN-ABC.pdf',
      );
    });
  });

  // Keeps the rootBundle import meaningful if fonts move.
  test('fonts are bundled', () async {
    final data = await rootBundle.load('assets/fonts/geist/Geist-Regular.ttf');
    expect(data.lengthInBytes, greaterThan(10000));
  });
}
