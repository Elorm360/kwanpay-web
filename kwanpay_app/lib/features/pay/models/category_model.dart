import 'package:flutter/material.dart';

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

