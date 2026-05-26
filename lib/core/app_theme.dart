part of '../main.dart';

/// Professional Apple-inspired color palette
class AppColors {
  // Primary colors
  static const Color primary = Color(
    0xFF0A84FF,
  ); // Apple Blue (brighter for dark mode readability)
  static const Color primaryLight = Color(
    0xFF0071E3,
  ); // Apple Blue (light mode)
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
  static const Color ultraLightGray = Color(0xFFFAFAFC);

  // Dark‐mode surface elevations (Apple HIG inspired)
  static const Color darkSurface0 = Color(0xFF000000); // pure black base
  static const Color darkSurface1 = Color(0xFF1C1C1E); // cards, sheets
  static const Color darkSurface2 = Color(0xFF2C2C2E); // elevated cards
  static const Color darkSurface3 = Color(0xFF3A3A3C); // highest elevation
  static const Color darkSeparator = Color(0xFF38383A); // dividers/borders

  // Error & Warning
  static const Color error = Color(0xFFFF453A); // brighter red for dark
  static const Color warning = Color(0xFFFF9F0A);

  // Gradients
  static const LinearGradient appleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A84FF), Color(0xFF30D5C8)],
  );

  static const LinearGradient productGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A84FF), Color(0xFF5AC8FA)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1C1C1E), Color(0xFF2C2C2E)],
  );
}

/// Smooth animations and transitions
class AppAnimations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve easeIn = Curves.easeInCubic;
  static const Curve smooth = Curves.fastOutSlowIn;
}

/// Professional spacing constants
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
}

/// Border radius constants
class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double full = 100.0;
}

/// Professional theme builder
class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryLight,
        secondary: AppColors.secondary,
        tertiary: AppColors.accent,
        surface: AppColors.white,
        error: Color(0xFFFF3B30),
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.black,
        outline: AppColors.lightGray,
      ),
      scaffoldBackgroundColor: AppColors.ultraLightGray,
      fontFamily: 'Inter',

      // AppBar styling
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0.5,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Button styling
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Outlined button styling
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          side: const BorderSide(color: AppColors.primaryLight, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Text styling
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: AppColors.black,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.black,
          letterSpacing: -0.3,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.black,
          letterSpacing: -0.2,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.black,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.mediumGray,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.mediumGray,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.lightGray, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.lightGray, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: Color(0xFFFF3B30), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: Color(0xFFFF3B30), width: 2),
        ),
        hintStyle: const TextStyle(
          color: AppColors.mediumGray,
          fontWeight: FontWeight.w500,
        ),
        labelStyle: const TextStyle(
          color: AppColors.black,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Card styling
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: const BorderSide(color: AppColors.lightGray, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Chip styling
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightGray,
        disabledColor: AppColors.lightGray,
        selectedColor: AppColors.primaryLight,
        secondarySelectedColor: AppColors.primaryLight,
        labelPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        brightness: Brightness.light,
      ),

      // Navigation bar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.white,
        elevation: 0.5,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primaryLight, size: 24);
          }
          return const IconThemeData(color: AppColors.mediumGray, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: AppColors.primaryLight,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            );
          }
          return const TextStyle(
            color: AppColors.mediumGray,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          );
        }),
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.black,
        ),
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.black,
        contentTextStyle: const TextStyle(
          color: AppColors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),

      // Bottom sheet theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.white,
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xxl),
          ),
        ),
        showDragHandle: true,
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.accent,
        surface: AppColors.darkSurface1,
        surfaceContainerHighest: AppColors.darkSurface3,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.white,
        outline: AppColors.darkSeparator,
      ),
      scaffoldBackgroundColor: AppColors.darkSurface0,
      fontFamily: 'Inter',

      // AppBar — pure black with subtle border
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface0,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        surfaceTintColor: Colors.transparent,
      ),

      // Filled buttons keep the blue accent
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Outlined buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.darkSeparator, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Text styling with higher contrast
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: AppColors.white,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
          letterSpacing: -0.3,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
          letterSpacing: -0.2,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFFE5E5EA), // slightly softened white
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF98989D), // mid-tone for secondary text
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Color(0xFF98989D),
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),

      // Input decoration for dark mode
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface2,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(
            color: AppColors.darkSeparator,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(
            color: AppColors.darkSeparator,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: const TextStyle(
          color: AppColors.mediumGray,
          fontWeight: FontWeight.w500,
        ),
        labelStyle: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Card styling — elevated dark surfaces
      cardTheme: CardThemeData(
        color: AppColors.darkSurface1,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: const BorderSide(color: AppColors.darkSeparator, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),

      // Chip styling
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurface2,
        disabledColor: AppColors.darkSurface2,
        selectedColor: AppColors.primary,
        secondarySelectedColor: AppColors.primary,
        labelPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        brightness: Brightness.dark,
      ),

      // Navigation bar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface1,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        indicatorColor: AppColors.primary.withAlpha(30),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 24);
          }
          return const IconThemeData(color: AppColors.mediumGray, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            );
          }
          return const TextStyle(
            color: AppColors.mediumGray,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          );
        }),
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface2,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkSurface3,
        contentTextStyle: const TextStyle(
          color: AppColors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),

      // Bottom sheet theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface1,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xxl),
          ),
        ),
        showDragHandle: true,
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: AppColors.darkSeparator,
        thickness: 0.5,
      ),
    );
  }
}

/// Card shadow — adapts by being used conditionally
const BoxShadow appCardShadow = BoxShadow(
  color: Color(0x1A000000),
  blurRadius: 8,
  offset: Offset(0, 2),
);

const List<BoxShadow> appShadowSm = [
  BoxShadow(color: Color(0x0F000000), blurRadius: 4, offset: Offset(0, 1)),
];

const List<BoxShadow> appShadowMd = [
  BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2)),
];

const List<BoxShadow> appShadowLg = [
  BoxShadow(color: Color(0x1A000000), blurRadius: 16, offset: Offset(0, 4)),
];

// Extension for withValues compatibility
extension ColorWithValues on Color {
  Color withValues({double? alpha, double? red, double? green, double? blue}) {
    if (alpha != null) return withOpacity(alpha);
    return this;
  }
}
