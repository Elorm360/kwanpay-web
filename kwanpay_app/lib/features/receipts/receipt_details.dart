import '../../core/models/transaction_model.dart';
import '../../core/models/transaction_status.dart';

/// One labelled line on a receipt.
class ReceiptLine {
  final String label;
  final String value;

  /// Values worth copying (references, wallet IDs) get a copy button.
  final bool copyable;

  const ReceiptLine(this.label, this.value, {this.copyable = false});
}

/// What a receipt says about one transaction. Built once and drawn twice:
/// on screen and in the PDF, so the two never disagree.
class ReceiptDetails {
  final String title;
  final String amount;

  /// Failed or cancelled: show the amount struck through, with no sign.
  final bool noMoneyMoved;
  final bool outgoing;
  final String status;
  final String? statusNote;
  final List<ReceiptLine> lines;

  const ReceiptDetails({
    required this.title,
    required this.amount,
    required this.noMoneyMoved,
    required this.outgoing,
    required this.status,
    required this.statusNote,
    required this.lines,
  });

  factory ReceiptDetails.from(
    TransactionModel tx, {
    String? ownerName,
    String? ownWalletId,
    String? counterpartyName,
  }) {
    final lines = <ReceiptLine>[
      ReceiptLine('Date', formatReceiptDate(tx.createdAt)),
      if ((tx.reference ?? '').isNotEmpty)
        ReceiptLine('Reference', tx.reference!, copyable: true),
    ];

    // Past tense ("Paid", "Sent") only once it really happened; a pending or
    // failed one is described, not claimed.
    final done = tx.isCompleted;

    String title;
    switch (tx.type) {
      case TransactionTypes.send:
        final to = tx.providerReference ?? '';
        final who = counterpartyName ?? (to.isEmpty ? 'a KwanPay wallet' : to);
        title = done ? 'Sent to $who' : 'Transfer to $who';
        if (counterpartyName != null) {
          lines.add(ReceiptLine('To', counterpartyName));
        }
        if (to.isNotEmpty) {
          lines.add(ReceiptLine('To wallet', to, copyable: true));
        }
      case TransactionTypes.receive:
        title = 'Received from a KwanPay wallet';
      case TransactionTypes.payment:
        // Stellar payments store "Business · BOOKING" in the description and,
        // once confirmed, the Stellar transaction hash as provider reference.
        final stellar = TransactionProviders.isDevelopmentNetwork(tx.provider);
        final parts = tx.description.split(' · ');
        final name = stellar ? parts.first : tx.description;
        final business = name.isEmpty ? 'a business' : name;
        title = done ? 'Paid $business' : 'Payment to $business';
        if (name.isNotEmpty) lines.add(ReceiptLine('Business', name));
        final booking = stellar
            ? (parts.length > 1 ? parts.last : null)
            : _afterColon(tx.providerReference);
        if (booking != null && booking.isNotEmpty) {
          lines.add(ReceiptLine('Booking reference', booking, copyable: true));
        }
        if (stellar && done && (tx.providerReference ?? '').isNotEmpty) {
          lines.add(
            ReceiptLine(
              'Stellar transaction',
              tx.providerReference!,
              copyable: true,
            ),
          );
        }
      case TransactionTypes.withdrawal:
        title = 'Withdrawal';
        if (tx.description.isNotEmpty) {
          lines.add(ReceiptLine('Details', tx.description));
        }
      case TransactionTypes.topUp:
        title = done ? 'Money added' : 'Adding money';
      case TransactionTypes.convertOut:
      case TransactionTypes.exchange:
        final to = _beforeColon(tx.providerReference);
        title = to == null
            ? 'Converted ${tx.currency}'
            : 'Converted ${tx.currency} to $to';
        final got = _conversionAmount(tx.providerReference);
        if (got != null) lines.add(ReceiptLine('You got', got));
      case TransactionTypes.convertIn:
        final from = _beforeColon(tx.providerReference);
        title = from == null
            ? 'Converted into ${tx.currency}'
            : 'Converted $from to ${tx.currency}';
        final paid = _conversionAmount(tx.providerReference);
        if (paid != null) lines.add(ReceiptLine('You paid', paid));
      default:
        title = tx.type.isEmpty ? 'Transaction' : tx.type;
    }

    if (ownerName != null && ownerName.isNotEmpty) {
      lines.add(ReceiptLine('Account holder', ownerName));
    }
    if (ownWalletId != null && ownWalletId.isNotEmpty) {
      lines.add(ReceiptLine('Your wallet', ownWalletId, copyable: true));
    }
    if (TransactionProviders.isDevelopmentNetwork(tx.provider)) {
      lines.add(
        const ReceiptLine('Network', 'Stellar test network (not real money)'),
      );
    }

    final outgoing = tx.isOutgoing;
    final noMoneyMoved = transactionMovedNoMoney(tx);
    final money = formatMoney(tx.amount, tx.currency);
    return ReceiptDetails(
      title: title,
      // No sign when nothing moved: "- GHS 250" on a failed payment reads as
      // money that left the account.
      amount: noMoneyMoved ? money : '${outgoing ? '-' : '+'} $money',
      noMoneyMoved: noMoneyMoved,
      outgoing: outgoing,
      status: tx.status,
      statusNote: switch (tx.status) {
        TransactionStatus.pending =>
          'This is still in progress. The receipt updates when it completes.',
        TransactionStatus.failed => 'This did not go through. No money moved.',
        TransactionStatus.cancelled => 'This was cancelled. No money moved.',
        _ => null,
      },
      lines: lines,
    );
  }

  static String? _beforeColon(String? value) {
    if (value == null || !value.contains(':')) return null;
    final part = value.split(':').first.trim();
    return part.isEmpty ? null : part;
  }

  static String? _afterColon(String? value) {
    if (value == null || !value.contains(':')) return null;
    final part = value.substring(value.indexOf(':') + 1).trim();
    return part.isEmpty ? null : part;
  }

  /// "GHS:12.50" → "GHS 12.50".
  static String? _conversionAmount(String? value) {
    final code = _beforeColon(value);
    final amount = double.tryParse(_afterColon(value) ?? '');
    if (code == null || amount == null) return null;
    return formatMoney(amount, code);
  }
}

/// Failed and cancelled transactions never moved money.
bool transactionMovedNoMoney(TransactionModel tx) =>
    tx.status == TransactionStatus.failed ||
    tx.status == TransactionStatus.cancelled;

/// "GHS 1,234.50": code first, thousands grouped, always two decimals.
String formatMoney(double amount, String currency) {
  final fixed = amount.abs().toStringAsFixed(2);
  final whole = fixed
      .split('.')
      .first
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  return '$currency $whole.${fixed.split('.').last}';
}

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// "26 Nov 2026, 09:20" in the phone's local time.
String formatReceiptDate(DateTime date) {
  final local = date.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${local.day} ${_months[local.month - 1]} ${local.year}, '
      '${two(local.hour)}:${two(local.minute)}';
}
