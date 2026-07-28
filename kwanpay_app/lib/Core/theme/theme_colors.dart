import 'package:flutter/material.dart';

/// Context-aware theme colour shortcuts.
///
/// Use these instead of raw AppColors.* so that switching between
/// light / dark mode automatically picks the correct colour.
extension ThemeColors on BuildContext {
  /// Page / scaffold background.
  Color get colorPaper {
    final isDark = Theme.of(this).brightness == Brightness.dark;
    return isDark ? const Color(0xFF111318) : const Color(0xFFEDEFF0);
  }

  /// Card / surface background.
  Color get colorSurface {
    final isDark = Theme.of(this).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1C1F26) : Colors.white;
  }

  /// Primary text colour.
  Color get colorTextPrimary {
    final isDark = Theme.of(this).brightness == Brightness.dark;
    return isDark ? const Color(0xFFF1F1F6) : const Color(0xFF24262B);
  }

  /// Secondary / caption text colour.
  Color get colorTextSecondary {
    final isDark = Theme.of(this).brightness == Brightness.dark;
    return isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
  }

  /// Divider / border colour.
  Color get colorBorder {
    final isDark = Theme.of(this).brightness == Brightness.dark;
    return isDark ? const Color(0xFF2D3142) : const Color(0xFFE5E7EB);
  }
}

