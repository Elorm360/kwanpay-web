import 'package:flutter/material.dart';

import 'operator_model.dart';

class CategoryModel {
  final String name;
  final IconData icon;
  final String? subtitle;

  const CategoryModel({
    required this.name,
    required this.icon,
    this.subtitle,
  });
}

class TourismCategories {
  static const List<CategoryModel> all = [
    CategoryModel(
      name: TourismOperators.transport,
      icon: Icons.directions_bus_rounded,
      subtitle: 'Tourism transport',
    ),
  ];
}
