import 'package:flutter/material.dart';

/// Centralized color palette for the app.
class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF0A84FF); // Apple Blue (brighter for dark mode readability)
  static const Color primaryLight = Color(0xFF0071E3); // Apple Blue (light mode)
  static const Color secondary = Color(0xFF30D5C8); // Teal
  static const Color accent = Color(0xFFFF9F0A); // Orange

  // Success / Semantic
  static const Color success = Color(0xFF30D158); // Apple Green

  // Neutrals
  static const Color black = Color(0xFF1D1D1F);
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkGray = Color(0xFF2C2C2E);
  static const Color mediumGray = Color(0xFF8E8E93);
  static const Color lightGray = Color(0xFFF5F5F7);
  static const Color darkSurface1 = Color(0xFF1C1C1E); // dark surface for sheets

  // Error & Warning
  static const Color error = Color(0xFFFF453A); // bright red for dark mode
  static const Color warning = Color(0xFFFF9F0A);
}
