import 'package:flutter_test/flutter_test.dart';
import 'package:kwanpay_app/core/models/ghana_funding_rail.dart';
import 'package:kwanpay_app/core/models/payment_method.dart';

void main() {
  group('normalizeMsisdn', () {
    test('accepts local, short and international forms', () {
      expect(GhanaFundingRail.normalizeMsisdn('024 412 3456'), '233244123456');
      expect(GhanaFundingRail.normalizeMsisdn('244123456'), '233244123456');
      expect(GhanaFundingRail.normalizeMsisdn('+233 24 412 3456'), '233244123456');
    });

    test('rejects numbers that are not Ghanaian mobiles', () {
      expect(GhanaFundingRail.normalizeMsisdn('12345'), isNull);
      expect(GhanaFundingRail.normalizeMsisdn('+234 803 123 4567'), isNull);
    });
  });

  group('fromMsisdn', () {
    test('detects the network from the prefix', () {
      expect(GhanaFundingRail.fromMsisdn('0244123456'), GhanaFundingRail.mtn);
      expect(GhanaFundingRail.fromMsisdn('0204123456'), GhanaFundingRail.telecel);
      expect(GhanaFundingRail.fromMsisdn('0264123456'), GhanaFundingRail.airtelTigo);
    });

    test('returns null for an unknown prefix', () {
      expect(GhanaFundingRail.fromMsisdn('0304123456'), isNull);
    });
  });

  test('displayMsisdn formats as 0XX XXX XXXX', () {
    expect(GhanaFundingRail.displayMsisdn('233244123456'), '024 412 3456');
  });

  test('PaymentMethod exposes network and display number', () {
    final method = PaymentMethod.fromJson({
      'id': 'pm-1',
      'rail': 'telecel',
      'msisdn': '233204123456',
      'is_default': true,
    });

    expect(method.network.name, 'Telecel Cash');
    expect(method.displayNumber, '020 412 3456');
    expect(method.isDefault, isTrue);
    expect(method.kind, 'momo');
  });
}
