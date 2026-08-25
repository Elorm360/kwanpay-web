import 'ghana_funding_rail.dart';

class PaymentMethod {
  final String id;
  final String kind;
  final String rail;
  final String msisdn;
  final bool isDefault;

  const PaymentMethod({
    required this.id,
    required this.kind,
    required this.rail,
    required this.msisdn,
    required this.isDefault,
  });

  GhanaFundingRail get network => GhanaFundingRail.byId(rail);

  String get displayNumber => GhanaFundingRail.displayMsisdn(msisdn);

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] ?? '',
      kind: json['kind'] ?? 'momo',
      rail: json['rail'] ?? '',
      msisdn: json['msisdn'] ?? '',
      isDefault: json['is_default'] == true,
    );
  }
}
