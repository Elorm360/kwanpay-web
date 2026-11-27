import 'package:flutter/material.dart';

class TourismOperator {
  final String code;
  final String name;
  final String category;
  final String location;
  final String accountLabel;
  final IconData icon;
  final String? stellarPublicKey;

  const TourismOperator({
    required this.code,
    required this.name,
    required this.category,
    required this.location,
    required this.accountLabel,
    required this.icon,
    this.stellarPublicKey,
  });

  TourismOperator withStellarPublicKey(String publicKey) {
    return TourismOperator(
      code: code,
      name: name,
      category: category,
      location: location,
      accountLabel: accountLabel,
      icon: icon,
      stellarPublicKey: publicKey,
    );
  }
}

class TourismOperators {
  static const transport = 'Transport';
  static const hotels = 'Hotels';
  static const tours = 'Tours';
  static const airport = 'Airport';

  static const transvistaAfrica = TourismOperator(
    code: 'transvista_africa',
    name: 'TransVista Africa Ltd',
    category: transport,
    location: 'Accra',
    accountLabel: 'Booking reference',
    icon: Icons.directions_bus_rounded,
  );

  static const List<TourismOperator> all = [
    transvistaAfrica,
  ];

  static TourismOperator? byCode(String code) {
    for (final operator in all) {
      if (operator.code == code) return operator;
    }
    return null;
  }
}
