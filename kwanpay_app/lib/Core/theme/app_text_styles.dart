import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const headline = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const title = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const body = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static const caption = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static const button = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
  );
}

