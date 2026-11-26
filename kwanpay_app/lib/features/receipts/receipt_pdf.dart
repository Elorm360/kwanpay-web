import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/models/transaction_model.dart';
import 'receipt_details.dart';

const _indigo = PdfColor.fromInt(0xFF1E2340);
const _amber = PdfColor.fromInt(0xFFD98E3B);
const _ink = PdfColor.fromInt(0xFF24262B);
const _muted = PdfColor.fromInt(0xFF6B7280);
const _line = PdfColor.fromInt(0xFFE5E7EB);
const _success = PdfColor.fromInt(0xFF1E8E5A);
const _error = PdfColor.fromInt(0xFFD14343);

Future<pw.Font> _font(String file) async =>
    pw.Font.ttf(await rootBundle.load('assets/fonts/geist/$file'));

/// A one-page A5 receipt in the app's typeface and colours.
Future<Uint8List> buildReceiptPdf(
  TransactionModel tx,
  ReceiptDetails details, {
  DateTime? generatedAt,
}) async {
  final regular = await _font('Geist-Regular.ttf');
  final semibold = await _font('Geist-SemiBold.ttf');
  final bold = await _font('Geist-Bold.ttf');

  final statusColor = switch (details.status) {
    'Completed' => _success,
    'Failed' || 'Cancelled' => _error,
    _ => _muted,
  };

  final doc = pw.Document(
    title: 'KwanPay receipt ${tx.reference ?? tx.id}',
    author: 'KwanPay',
    creator: 'KwanPay',
  );

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a5,
      margin: const pw.EdgeInsets.all(36),
      theme: pw.ThemeData.withFont(base: regular, bold: bold),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'KwanPay',
                style: pw.TextStyle(font: bold, fontSize: 22, color: _indigo),
              ),
              pw.Text(
                'RECEIPT',
                style: pw.TextStyle(
                  font: semibold,
                  fontSize: 9,
                  letterSpacing: 2,
                  color: _amber,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Container(height: 2, width: 40, color: _amber),
          pw.SizedBox(height: 28),
          pw.Text(
            details.title,
            style: pw.TextStyle(font: semibold, fontSize: 12, color: _muted),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            details.amount,
            style: pw.TextStyle(
              font: bold,
              fontSize: 28,
              color: details.noMoneyMoved ? _muted : _ink,
              decoration: details.noMoneyMoved
                  ? pw.TextDecoration.lineThrough
                  : null,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: statusColor, width: 0.8),
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Text(
              details.status,
              style: pw.TextStyle(
                font: semibold,
                fontSize: 9,
                color: statusColor,
              ),
            ),
          ),
          if (details.statusNote != null) ...[
            pw.SizedBox(height: 8),
            pw.Text(
              details.statusNote!,
              style: pw.TextStyle(fontSize: 9, color: _muted),
            ),
          ],
          pw.SizedBox(height: 24),
          for (final line in details.lines)
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 8),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: _line, width: 0.6),
                ),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(
                    width: 110,
                    child: pw.Text(
                      line.label,
                      style: pw.TextStyle(fontSize: 9.5, color: _muted),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      line.value,
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        font: semibold,
                        fontSize: 9.5,
                        color: _ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          pw.Spacer(),
          pw.Text(
            'Transaction ID ${tx.id}',
            style: pw.TextStyle(fontSize: 7.5, color: _muted),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Generated from your KwanPay account on '
            '${formatReceiptDate(generatedAt ?? DateTime.now())}. '
            'KwanPay, in partnership with TransVista Africa Ltd.',
            style: pw.TextStyle(fontSize: 7.5, color: _muted),
          ),
        ],
      ),
    ),
  );

  return doc.save();
}

/// File name people see when they share or save it.
String receiptFileName(TransactionModel tx) {
  final ref = (tx.reference ?? tx.id).replaceAll(RegExp(r'[^A-Za-z0-9-]'), '');
  return 'KwanPay-receipt-$ref.pdf';
}
