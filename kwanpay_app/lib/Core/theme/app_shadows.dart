import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  static List<BoxShadow> card = [
    BoxShadow(
      color: Colors.black.withValues(alpha: .04),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ];
}

