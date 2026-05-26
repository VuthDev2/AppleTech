part of '../main.dart';

/// Helper utilities for responsive layout calculations.
class ResponsiveUtils {
  /// Returns the number of columns for grid layouts based on screen width.
  ///
  /// - < 600 px → 1 column (mobile portrait)
  /// - 600 – 899 px → 2 columns (tablet / small phone landscape)
  /// - >= 900 px → 3 columns (large tablet / desktop)
  static int calculateCrossAxisCount(double width) {
    if (width < 600) return 1;
    if (width < 900) return 2;
    return 3;
  }

  /// Returns an appropriate childAspectRatio for grid items based on width and column count.
  /// This keeps cards roughly the same height regardless of the number of columns.
  static double calculateAspectRatio(double width, int crossAxisCount) {
    // Aim for a base item width of ~300 px.
    final baseItemWidth = 300.0;
    final itemWidth = width / crossAxisCount;
    // Slightly adjust height to maintain visual balance.
    return itemWidth / (baseItemWidth * 0.72);
  }
}
