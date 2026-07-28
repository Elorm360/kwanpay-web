import 'package:flutter/material.dart';

import '../models/category_model.dart';
import '../models/operator_model.dart';

class MockData {
  static const List<CategoryModel> categories = [
    CategoryModel(
      name: "Transport",
      icon: Icons.directions_bus_rounded,
      subtitle: "Bus, taxi & rides",
    ),
    CategoryModel(
      name: "Hotels",
      icon: Icons.bed_rounded,
      subtitle: "Places to stay",
    ),
    CategoryModel(
      name: "Tours",
      icon: Icons.explore_rounded,
      subtitle: "Guided experiences",
    ),
    CategoryModel(
      name: "Airport",
      icon: Icons.flight_rounded,
      subtitle: "Airport services",
    ),
    CategoryModel(
      name: "More",
      icon: Icons.more_horiz_rounded,
      subtitle: "Other services",
    ),
  ];

  static const List<OperatorModel> mockOperators = [
    OperatorModel(
      name: "VIP Jeoun",
      category: "Luxury Transfers",
      location: "Accra",
      rating: 4.9,
      reviewCount: 178,
    ),
    OperatorModel(
      name: "Savannah Trails",
      category: "Tour Operator",
      location: "Kumasi",
      rating: 4.8,
      reviewCount: 142,
    ),
    OperatorModel(
      name: "STC",
      category: "Bus Services",
      location: "Accra",
      rating: 4.6,
      reviewCount: 215,
    ),
    OperatorModel(
      name: "Airport Shuttle",
      category: "Airport Transfers",
      location: "Accra",
      rating: 4.7,
      reviewCount: 98,
    ),
  ];
}

