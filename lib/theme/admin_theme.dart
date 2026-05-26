import 'dart:ui';
import 'package:flutter/material.dart';

/// Centralised design system for the admin portal.
class AdminColors {
  static const Color primary = Color(0xFF0055CC);
  static const Color secondary = Color(0xFF00A8E8);
  static const Color success = Color(0xFF00C853);
  static const Color error = Color(0xFFFF5252);
  static const Color accent = Color(0xFF8E24AA);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color darkSurface0 = Color(0xFF111111);
  static const Color darkSurface1 = Color(0xFF1C1C1E);
  static const Color darkSurface2 = Color(0xFF2C2C2E);
}

class AdminGradients {
  static const Gradient glassLight = LinearGradient(
    colors: [Colors.white70, Colors.white30],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient glassDark = LinearGradient(
    colors: [Colors.black54, Colors.black26],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AdminRadius {
  static const double xl = 24.0;
  static const double lg = 16.0;
  static const double md = 12.0;
  static const double full = 9999.0;
}

/// A reusable glass‑morphism container.
class GlassMorphism extends StatelessWidget {
  final Widget child;
  final bool? darkMode;
  final double blurSigma;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  const GlassMorphism({
    super.key,
    required this.child,
    this.darkMode,
    this.blurSigma = 20.0,
    this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = darkMode ?? Theme.of(context).brightness == Brightness.dark;
    final gradient = isDark ? AdminGradients.glassDark : AdminGradients.glassLight;
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(AdminRadius.xl),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: gradient,
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
            ),
            borderRadius: borderRadius ?? BorderRadius.circular(AdminRadius.xl),
          ),
          child: child,
        ),
      ),
    );
  }
}
